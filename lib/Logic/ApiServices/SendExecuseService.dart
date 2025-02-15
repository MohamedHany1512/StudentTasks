import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/Logic/ApiServices/ApiServices.dart';
import 'package:http/http.dart' as http;

class Sendexecuseservice extends ApiService {
  static const String excuseUrl = "${ApiService.baseUrl}/excuses";
  static Future<Map<String, dynamic>> sendExcuse({
    required String reason,
    required String description,
    required String material,
    required String department,
    required List<File> images, // ✅ استلام قائمة صور
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        return {"error": "❌ التوكن غير موجود، يرجى تسجيل الدخول."};
      }

      var request = http.MultipartRequest(
        "POST",
        Uri.parse(excuseUrl), // ✅ API الإرسال
      );

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      request.fields["reason"] = reason;
      request.fields["description"] = description;
      request.fields["material"] = material;
      request.fields["department"] = department;

      // ✅ رفع الصور المتعددة
      for (var i = 0; i < images.length; i++) {
        request.files.add(
            await http.MultipartFile.fromPath("images[$i]", images[i].path));
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("🔹 Response Status Code: ${response.statusCode}");
      print("🔹 Response Body: $responseBody");

      // ✅ التأكد من أن الريسبونس ليس HTML
      if (responseBody.startsWith("<!DOCTYPE html>") ||
          responseBody.startsWith("<html")) {
        return {
          "error": "❌ استجابة غير متوقعة من السيرفر، تأكد من صحة الـ API URL."
        };
      }

      // ✅ محاولة فك JSON
      try {
        final data = json.decode(responseBody);

        if (response.statusCode == 200 && data["success"] == true) {
          return {"success": true, "message": "✅ تم إرسال العذر بنجاح"};
        } else {
          return {
            "error": "❌ فشل الإرسال: ${data["message"] ?? "خطأ غير معروف"}"
          };
        }
      } catch (e) {
        return {
          "error": "❌ فشل تحليل استجابة السيرفر، قد يكون هناك مشكلة في الـ API."
        };
      }
    } catch (e) {
      print("❌ حدث خطأ أثناء إرسال العذر: $e");
      return {"error": "❌ حدث خطأ أثناء إرسال العذر، حاول مرة أخرى."};
    }
  }
}

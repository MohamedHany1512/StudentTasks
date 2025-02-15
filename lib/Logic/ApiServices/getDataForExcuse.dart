import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:task/Logic/ApiServices/ApiServices.dart';

class Getdataforexcuse extends ApiService {
  static const String materialsUrl = "${ApiService.baseUrl}/excuses/create";
  static Future<Map<String, dynamic>> fetchExcuseData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token'); // ✅ استرجاع التوكن

      if (token == null) {
        throw Exception("❌ التوكن غير موجود، يرجى تسجيل الدخول.");
      }

      final response = await http.get(
        Uri.parse(materialsUrl), // 🔹 ضع رابط الـ API هنا
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      print("🔹 Response Status Code: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["success"] == true) {
          return {
            "departments": List<String>.from(data["data"]["departments"]),
            "materials": List<String>.from(data["data"]["materials"]),
          };
        } else {
          throw Exception("❌ فشل في جلب البيانات: ${data["message"]}");
        }
      } else {
        throw Exception(
            "❌ خطأ في الاتصال بالسيرفر، الكود: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ حدث خطأ أثناء الاتصال بالسيرفر: $e");
      throw Exception("❌ حدث خطأ أثناء الاتصال بالسيرفر.");
    }
  }
}

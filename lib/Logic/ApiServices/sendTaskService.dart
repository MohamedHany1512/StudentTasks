import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/Logic/ApiServices/ApiServices.dart';

class Sendtaskservice extends ApiService {
  static Future<Map<String, dynamic>> uploadTaskAnswer({
    required File file,
    required int taskId,
    required int lectureId,
    required Function(double) onProgress,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        return {"error": "❌ التوكن غير موجود، يرجى تسجيل الدخول."};
      }

      if (!file.existsSync()) {
        return {"error": "❌ الملف غير موجود!"};
      }

      // ✅ طباعة بيانات كل عملية رفع
      print("📌 بدء رفع الحل للمهمة ID: $taskId - المحاضرة ID: $lectureId");
      print("📁 اسم الملف: ${file.path.split('/').last}");
      print("📏 حجم الملف: ${await file.length()} بايت");

      String fileName = file.path.split('/').last;
      String? mimeType =
          lookupMimeType(file.path) ?? "application/octet-stream";

      // ✅ تأخير لضمان عدم تداخل عمليات الرفع
      await Future.delayed(Duration(seconds: 2));

      // ✅ إنشاء Dio جديد لكل عملية رفع
      Dio dio = Dio();
      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      };

      FormData formData = FormData.fromMap({
        "task_id": taskId.toString(),
        "lecture_id": lectureId.toString(),
        "unique_key":
            "${taskId}_${lectureId}_${DateTime.now().millisecondsSinceEpoch}", // معرف فريد
        "answer_file": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      });

      Response response = await dio.post(
        "https://www.ain.purple-stingray-51320.zap.cloud/api/task-answer",
        data: formData,
        onSendProgress: (sent, total) {
          double progress = (sent / total) * 100;
          onProgress(progress);
          print("📤 نسبة التقدم: ${progress.toStringAsFixed(2)}%");
        },
      );

      print("🔹 استجابة السيرفر: ${response.data}");

      if (response.statusCode == 200) {
        print("✅ تم إرسال الحل بنجاح للمهمة ID: $taskId");
        return {"success": true, "message": "✅ تم إرسال الحل بنجاح"};
      } else {
        return {
          "error":
              "❌ فشل رفع الحل: ${response.data["message"] ?? "خطأ غير معروف"}"
        };
      }
    } catch (e) {
      if (e is DioException) {
        print(
            "❌ DioException أثناء رفع المهمة ID: $taskId: ${e.response?.data}");
        return {
          "error": "❌ خطأ أثناء رفع الحل: ${e.response?.data ?? e.message}"
        };
      }
      return {"error": "❌ خطأ غير متوقع أثناء رفع المهمة ID: $taskId: $e"};
    }
  }
}

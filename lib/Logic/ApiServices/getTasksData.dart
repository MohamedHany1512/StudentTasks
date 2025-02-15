import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:task/Logic/ApiServices/ApiServices.dart';

class Gettasksdata extends ApiService {
  static Future<Map<String, Map<String, List>>> fetchStudentTasks() async {
    final url = Uri.parse(
        "https://www.ain.purple-stingray-51320.zap.cloud/api/get-student-tasks");

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print("❌ لا يوجد توكن، يرجى تسجيل الدخول.");
        return {};
      }

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("🔹 Status Code: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData["success"] == true) {
          if (responseData["data"] is Map &&
              responseData["data"].containsKey("subjects")) {
            Map<String, Map<String, List>> groupedTasks = {};

            for (var subject in responseData["data"]["subjects"]) {
              String subjectName = subject["name"] ?? "مادة غير معروفة";

              if (!groupedTasks.containsKey(subjectName)) {
                groupedTasks[subjectName] = {};
              }

              if (subject.containsKey("lectures")) {
                for (var lecture in subject["lectures"]) {
                  String lectureName = lecture["name"] ?? "محاضرة غير معروفة";

                  if (!groupedTasks[subjectName]!.containsKey(lectureName)) {
                    groupedTasks[subjectName]![lectureName] = [];
                  }

                  if (lecture.containsKey("tasks")) {
                    groupedTasks[subjectName]![lectureName]!
                        .addAll(lecture["tasks"]);
                  }
                }
              }
            }

            print("📌 بيانات المهام: ${json.encode(groupedTasks)}");
            return groupedTasks;
          } else {
            print("❌ لم يتم العثور على `subjects` داخل `data`.");
            return {};
          }
        } else {
          print(
              "❌ الطلب فشل، رسالة الخطأ: ${responseData["message"] ?? "غير معروفة"}");
          return {};
        }
      } else {
        print("❌ فشل في تحميل البيانات: ${response.statusCode}");
        return {};
      }
    } catch (e) {
      print("❌ خطأ أثناء جلب البيانات: $e");
      return {};
    }
  }
}

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

        if (responseData["success"] == true &&
            responseData.containsKey("data") &&
            responseData["data"].containsKey("subjects")) {
          Map<String, Map<String, List>> groupedTasks = {};
          String taskPath = responseData["data"]["task_path"] ?? "";

          for (var subject in responseData["data"]["subjects"]) {
            String subjectName = subject["name"] ?? "مادة غير معروفة";
            groupedTasks.putIfAbsent(subjectName, () => {});

            if (subject.containsKey("lectures")) {
              for (var lecture in subject["lectures"]) {
                String lectureName = lecture["name"] ?? "محاضرة غير معروفة";
                groupedTasks[subjectName]!.putIfAbsent(lectureName, () => []);

                if (lecture.containsKey("tasks")) {
                  for (var task in lecture["tasks"]) {
                    if (!task.containsKey("file_url") || task["file_url"] == null) {
                      if (task["name"] != null && task["name"].toString().isNotEmpty) {
                        String fileName = Uri.encodeComponent(task["name"]);
                        task["file_url"] =
                            "https://www.ain.purple-stingray-51320.zap.cloud/$taskPath/$fileName";
                        print("📥 رابط الملف المولد: ${task["file_url"]}");
                      } else {
                        print("❌ اسم الملف غير موجود أو غير صالح: ${task["name"]}");
                      }
                    }
                    groupedTasks[subjectName]![lectureName]!.add(task);
                  }
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
        print("❌ فشل في تحميل البيانات: ${response.statusCode}");
        return {};
      }
    } catch (e) {
      print("❌ خطأ أثناء جلب البيانات: ${e.toString()}");
      return {};
    }
  }
}

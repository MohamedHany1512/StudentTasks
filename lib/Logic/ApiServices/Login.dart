import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/Logic/ApiServices/ApiServices.dart';
import 'package:http/http.dart' as http;

abstract class Login extends ApiService {
  /// ✅ تسجيل الدخول
  static const String loginUrl = "${ApiService.baseUrl}/login";
  static Future<Map<String, dynamic>> login(
      String studentCode, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        body: json.encode({'student_code': studentCode, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true &&
            data['data'] is List &&
            data['data'].isNotEmpty) {
          final token = data['data'][0]['token'];
          final departmentId = data['data'][0]['department_id']; // ✅ رقم القسم

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setInt(
              'department_id', departmentId); // ✅ تخزين `department_id` كـ int

          return data;
        } else {
          return {'error': 'لم يتم العثور على التوكن في الاستجابة'};
        }
      } else {
        return {'error': 'فشل تسجيل الدخول: ${response.body}'};
      }
    } catch (e) {
      return {'error': 'تعذر الاتصال بالخادم'};
    }
  }
}

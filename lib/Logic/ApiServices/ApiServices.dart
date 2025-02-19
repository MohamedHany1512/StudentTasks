import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://www.ain.purple-stingray-51320.zap.cloud/api";
  static const String changePasswordUrl = "$baseUrl/change-password";

 static Future<Map<String, dynamic>> changePassword(
    String currentPassword, String newPassword, String confirmPassword) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print("❌ لا يوجد توكن مخزن");
      return {'error': '❌ المستخدم غير مسجل الدخول'};
    }

    print("🔹 إرسال طلب تغيير كلمة المرور...");
    print("🔹 Header: Authorization: Bearer $token");

    final response = await http.post(
      Uri.parse(changePasswordUrl),
      body: json.encode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("🔹 Status Code: ${response.statusCode}");
    print("🔹 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'error': '❌ فشل تغيير كلمة المرور: ${response.body}'};
    }
  } catch (e) {
    print("❌ خطأ أثناء الاتصال بالسيرفر: $e");
    return {'error': '❌ تعذر الاتصال بالخادم'};
  }
}

}

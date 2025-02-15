import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/Logic/ApiServices/ApiServices.dart';
import 'package:http/http.dart' as http;

abstract class Logout {
  static const String logoutUrl = "${ApiService.baseUrl}/logout";

  /// ✅ تسجيل الخروج
  static Future<Map<String, dynamic>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {'error': 'لم يتم العثور على التوكن'};
      }

      final response = await http.post(
        Uri.parse(logoutUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await prefs.clear(); // ✅ مسح جميع بيانات المستخدم وليس التوكن فقط
        return {'success': true, 'message': 'تم تسجيل الخروج بنجاح'};
      } else {
        return {'error': 'فشل تسجيل الخروج: ${response.body}'};
      }
    } catch (e) {
      return {'error': 'تعذر الاتصال بالخادم'};
    }
  }
}

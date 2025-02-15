
class ApiService {
  // ✅ تعريف الروابط
  static const String baseUrl =
      "https://www.ain.purple-stingray-51320.zap.cloud/api";
 



  static const String changePasswordUrl =
      "http://ain.infinityfreeapp.com/api/changepassword";

  // /// ✅ تغيير كلمة المرور
  // static Future<Map<String, dynamic>> changePassword(
  //     String oldPassword, String newPassword) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse(changePasswordUrl),
  //       body: json
  //           .encode({'old_password': oldPassword, 'new_password': newPassword}),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (response.statusCode == 200) {
  //       return json.decode(response.body);
  //     } else {
  //       return {'error': 'فشل تغيير كلمة المرور: ${response.body}'};
  //     }
  //   } catch (e) {
  //     return {'error': 'تعذر الاتصال بالخادم'};
  //   }
  // }




}
import 'package:flutter/material.dart';
import 'package:task/Logic/ApiServices/LogOut.dart';
import 'package:task/features/login/loginView.dart';

class Logoutbody {
  static Future<void> logoutt(BuildContext context) async {
    final result = await Logout.logout();

    if (!context.mounted) return; // ✅ تحقق من أن الـ context لا يزال متاحًا

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error']),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout Successful'),
          backgroundColor: Colors.green,
        ),
      );

      // ✅ نقل المستخدم إلى صفحة تسجيل الدخول مع التحقق من `mounted`
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Loginview()),
          (route) => false, // يمنع الرجوع للخلف
        );
      }
    }
  }
}

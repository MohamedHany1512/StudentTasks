import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/Logic/ApiServices/ApiServices.dart';
import 'package:task/features/HomePage/logOutbody.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newPasswordConfirmationController = TextEditingController();

  Future<void> changePassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ لا يوجد توكن مخزن")),
      );
      return;
    }

    final oldPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmNewPassword = _newPasswordConfirmationController.text;

    if (newPassword != confirmNewPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ كلمات المرور الجديدة غير متطابقة")),
      );
      return;
    }

    try {
      Map<String, dynamic> response = await ApiService.changePassword(
        oldPassword,
        newPassword,
        confirmNewPassword,
      );

      if (response.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ تم تغيير كلمة المرور بنجاح")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ فشل في الاتصال بالخادم")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: [
          IconButton(

            onPressed: () {Logoutbody.logoutt(context);} ,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
        centerTitle: true,
        title: Text("تغيير كلمة المرور",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            SizedBox(height: 16),
        
         
            SizedBox(height: 16),
        TextField(
  controller: _currentPasswordController,
  obscureText: true,
  decoration: InputDecoration(
    labelText: "كلمة المرور الحالية",
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2.0),
    ),
  ),
),

            SizedBox(height: 16),
           TextField(
  controller: _newPasswordController,
  obscureText: true,
  decoration: InputDecoration(
    
    labelText: "كلمة المرور الجديدة",
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2.0),
    ),
  ),
),

            SizedBox(height: 16),
       TextField(
  controller: _newPasswordConfirmationController,
  obscureText: true,
  decoration: InputDecoration(
    labelText: "تأكيد كلمة المرور الجديدة",
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2.0),
    ),
  ),
),

            SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.blue),
              ),
              onPressed: () async {
                await changePassword();
              },
              child: Text("تغيير كلمة المرور", style: TextStyle(color: Colors.white)),
            ),
          ),

          ],
        ),
      ),
    );
  }
}

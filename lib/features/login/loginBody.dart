import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:task/Logic/ApiServices/Login.dart';
import 'package:task/core/utils/CustomButton.dart';
import 'package:task/core/utils/CustomTextField.dart';
import 'package:task/features/HomePage/HomePageView.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  State<LoginBody> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginBody> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // ✅ التحقق من حالة تسجيل الدخول
  }

  /// ✅ التحقق مما إذا كان المستخدم مسجل دخول مسبقًا
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      // ✅ المستخدم مسجل دخول مسبقًا، انتقل مباشرة إلى الصفحة الرئيسية
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  /// ✅ تنفيذ عملية تسجيل الدخول
  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      final result = await Login.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      setState(() => isLoading = false);

      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error']), backgroundColor: Colors.red),
        );
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('rememberMe', rememberMe);
        if (result['token'] != null) {
          await prefs.setString('token', result['token']!);
          print("✅ Token Saved: ${result['token']}");
        } else {
          print("❌ فشل حفظ التوكن، القيمة NULL");
        } // ✅ حفظ التوكن

        print("✅ Token Saved: ${result['token']}");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم تسجيل الدخول بنجاح'),
              backgroundColor: Colors.green),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Center(
                    child: Text("تسجيل الدخول",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                  ),
                  const SizedBox(height: 40),

                  // ✅ حقل كود الطالب
                  CustomTextField(
                    label: ":كود الطالب  ",
                    hint: "أدخل كودك",
                    controller: emailController,
                    validator: (value) => value == null || value.isEmpty
                        ? "الرجاء إدخال كود الطالب"
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // ✅ حقل كلمة المرور
                  CustomTextField(
                    label: ":كلمة السر",
                    hint: "أدخل كلمة السر",
                    controller: passwordController,
                    isPassword: true,
                    validator: (value) => value == null || value.isEmpty
                        ? "الرجاء إدخال كلمة السر"
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // ✅ خيار "تذكرني"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (bool? newValue) {
                              setState(() => rememberMe = newValue!);
                            },
                          ),
                          const Text("تذكرني"),
                        ],
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     showForgotPasswordSheet(context);
                      //     // ✅ منطق "نسيت كلمة السر؟"
                      //   },
                      //   child: const Text(
                      //     "نسيت كلمة السر؟",
                      //     style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // ✅ زر تسجيل الدخول
                  CustomButton(
                    text: isLoading ? "جاري تسجيل الدخول..." : "تسجيل الدخول",
                    onPressed: () {
                      _login(context);
                    },
                  ),
                  const SizedBox(height: 20),

                  // ✅ الشروط والأحكام
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        text:
                            "من خلال إنشاء حساب أو تسجيل الدخول، أنت توافق على\n",
                        style: TextStyle(color: Colors.black, fontSize: 12),
                        children: [
                          TextSpan(
                              text: "الشروط والأحكام",
                              style: TextStyle(color: Colors.blue)),
                          TextSpan(text: " و "),
                          TextSpan(
                              text: "بيان الخصوصية",
                              style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  VerifyEmailScreenState createState() => VerifyEmailScreenState();
}

class VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final Color labelColor = const Color(0xFFA8A8A8);
  final Color linkColor = const Color(0xFF51E0B3);

  bool _isLoading = false;
  String? _errorMessage;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('temp_email');
    });
  }

  Future<void> _checkEmailVerification() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // إعادة تحميل بيانات المستخدم
      await FirebaseAuth.instance.currentUser?.reload();
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        // إذا تم التحقق، استعدي البيانات المؤقتة
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? email = prefs.getString('temp_email');
        String? firstName = prefs.getString('temp_first_name');
        String? lastName = prefs.getString('temp_last_name');
        String? studentId = prefs.getString('temp_student_id');
        String? password = prefs.getString('temp_password');
        String? phone = prefs.getString('temp_phone');

        // حفظ بيانات المستخدم في SharedPreferences
        await prefs.setString('email', email!);
        await prefs.setString('first_name', firstName!);
        await prefs.setString('last_name', lastName!);
        await prefs.setString('student_id', studentId!);
        await prefs.setString('password', password!);
        await prefs.setString('phone', phone!);
        await prefs.setBool('isLoggedIn', false);

        // إزالة البيانات المؤقتة
        await prefs.remove('temp_email');
        await prefs.remove('temp_first_name');
        await prefs.remove('temp_last_name');
        await prefs.remove('temp_student_id');
        await prefs.remove('temp_password');
        await prefs.remove('temp_phone');

        // الانتقال إلى شاشة تسجيل الدخول
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        setState(() {
          _errorMessage = 'Please verify your email by clicking the link sent to your inbox.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        setState(() {
          _errorMessage = 'A new verification email has been sent to your inbox.';
        });
      } else {
        setState(() {
          _errorMessage = 'Error: User not found or already verified.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error resending email: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _goBackAndDeleteAccount() async {
    try {
      // حذف الحساب غير المكتمل التحقق
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }

      // إزالة البيانات المؤقتة من SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('temp_email');
      await prefs.remove('temp_first_name');
      await prefs.remove('temp_last_name');
      await prefs.remove('temp_student_id');
      await prefs.remove('temp_password');
      await prefs.remove('temp_phone');

      // العودة إلى صفحة التسجيل
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error deleting account: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 46,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/email.png',
                width: 227,
                height: 227,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 46 + 227 + 15,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Positioned(
            top: 46 + 227 + 50 + 28,
            left: 16,
            right: 16,
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 15, color: labelColor),
                  children: [
                    const TextSpan(
                      text: 'A verification email has been sent to ',
                    ),
                    TextSpan(
                      text: _email ?? 'ju0210000@ju.edu.jo',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFBA8A05),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: '. Please click the link to verify your email.'),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 430,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _checkEmailVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE44E4E),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.1125,
                        vertical: screenSize.height * 0.0135,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : Text(
                            'I have verified my email',
                            style: TextStyle(
                              fontSize: screenSize.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 17),
                  GestureDetector(
                    onTap: _isLoading ? null : _resendVerificationEmail,
                    child: Text(
                      'Resend Verification Email',
                      style: TextStyle(
                        color: linkColor,
                        fontSize: screenSize.width * 0.04,
                        decoration: TextDecoration.underline,
                        decorationColor: linkColor,
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    SizedBox(height: screenSize.height * 0.015),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            top: 575,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              bottom: true,
              child: Center(
                child: GestureDetector(
                  onTap: _isLoading ? null : _goBackAndDeleteAccount, // استدعاء الدالة المعدلة
                  child: Text(
                    'Go Back',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.04,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
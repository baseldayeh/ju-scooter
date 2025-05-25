import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' show log;
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // إضافة Firestore
import 'package:ju_scooter/session_manager.dart';

class BackgroundPainter extends CustomPainter {
  final Color gradientTop;
  final Color gradientBottom;
  final double iconCenterY;
  final double iconRadius;

  BackgroundPainter({
    required this.gradientTop,
    required this.gradientBottom,
    required this.iconCenterY,
    required this.iconRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        [gradientTop, gradientBottom],
      );
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.9);
    double controlPointY = iconCenterY + iconRadius * 1.2;
    controlPointY = controlPointY.clamp(size.height * 0.5, size.height * 0.9);
    final double endPointY = size.height * 0.9;
    path.quadraticBezierTo(
        size.width * 0.75, controlPointY - iconRadius * 0.5, size.width * 0.5, controlPointY);
    path.quadraticBezierTo(size.width * 0.25, controlPointY + iconRadius * 0.5, 0, endPointY);
    path.lineTo(0, endPointY);
    path.lineTo(0, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is BackgroundPainter) {
      return oldDelegate.gradientTop != gradientTop ||
             oldDelegate.gradientBottom != gradientBottom ||
             oldDelegate.iconCenterY != iconCenterY ||
             oldDelegate.iconRadius != iconRadius;
    }
    return false;
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isLoginCooldown = false;
  bool _rememberMe = false;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  late List<FocusNode> _focusNodes;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _resetEmailController = TextEditingController();
  String? _errorMessage;
  final _storage = const FlutterSecureStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // إضافة Firestore

  final Color gradientTop = const Color(0xFF80F1B3);
  final Color gradientBottom = const Color(0xFF26D1A4);
  final Color iconColor = Colors.grey.shade500;
  final Color labelColor = const Color(0xFFA8A8A8);
  final Color buttonColor = const Color(0xFF26D1A4);
  final Color linkColor = const Color(0xFF26D1A4);
  final Color defaultSignInBorderColor = const Color(0xFF26D1A4);
  final Color emailFocusColor = const Color(0xFF1DFF97);
  final Color passwordFocusColor = const Color(0xFF1BFEE3);
  final Color inactiveBorderColor = Colors.grey.shade300;

  @override
  void initState() {
    super.initState();
    _focusNodes = [_emailFocus, _passwordFocus];
    for (var node in _focusNodes) {
      node.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.removeListener(_onFocusChange);
      node.dispose();
    }
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _errorMessage = null;
    });
    for (var node in _focusNodes) {
      if (node.hasFocus) {
        _ensureVisible(node);
      }
    }
  }

  void _ensureVisible(FocusNode focusNode) {
    final context = focusNode.context;
    if (context != null) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      final screenHeight = MediaQuery.of(context).size.height;

      final offset = position.dy + size.height - (screenHeight - keyboardHeight - 80);
      if (offset > 0) {
        _scrollController.animateTo(
          _scrollController.offset + offset,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> _signIn() async {
  if (_isLoginCooldown) {
    setState(() {
      _errorMessage = 'Please wait a moment before trying again.';
    });
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    String email = _emailController.text.trim();
    if (!email.endsWith('@ju.edu.jo')) {
      setState(() {
        _errorMessage = 'Please use a valid university email (@ju.edu.jo)';
      });
      return;
    }
    log('Attempting login with email: $email');

    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: _passwordController.text,
    );
    User? user = userCredential.user;

    if (user != null) {
      await user.reload();
      user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        // جلب بيانات المستخدم من Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          // إنشاء قاموس ببيانات المستخدم
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          userData['email'] = email;
          if (_rememberMe) {
            userData['password'] = _passwordController.text;
          }

          // استخدام SessionManager لحفظ بيانات الجلسة مع بيانات المستخدم
          await SessionManager.setActiveSession(userData: userData);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('remember_me', _rememberMe);

          if (_rememberMe) {
            await _storage.write(key: 'email', value: email);
            await _storage.write(key: 'password', value: _passwordController.text);
          } else {
            await _storage.delete(key: 'email');
            await _storage.delete(key: 'password');
          }
          log('Login successful for email: $email');
          _navigateToHome();
        } else {
          setState(() {
            _errorMessage = 'User data not found. Please sign up again.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Please verify your email first';
        });
      }
    }
  } on FirebaseAuthException catch (e) {
    log('Firebase login error: ${e.code} - ${e.message}');
    String errorMsg = 'Invalid email or password';
    if (e.code == 'wrong-password') {
      errorMsg = 'Incorrect password. Please try again.';
    } else if (e.code == 'user-not-found') {
      errorMsg = 'No user found with this email.';
    } else if (e.code == 'too-many-requests') {
      errorMsg = 'Too many attempts. Please wait 15 minutes and try again, or reset your password.';
      setState(() {
        _isLoginCooldown = true;
      });
      await Future.delayed(const Duration(seconds: 30));
      setState(() {
        _isLoginCooldown = false;
      });
    }
    setState(() {
      _errorMessage = errorMsg;
    });
    await Future.delayed(const Duration(seconds: 2));
  } catch (e) {
    log('Unexpected login error: $e');
    setState(() {
      _errorMessage = 'An unexpected error occurred: $e';
    });
    await Future.delayed(const Duration(seconds: 2));
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _handlePasswordReset(String email, StateSetter setDialogState, Function(bool) onResult) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        _errorMessage = 'Password reset email sent. Check your inbox.';
      });
      onResult(true);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error sending reset email: $e';
      });
      onResult(false);
    } finally {
      setDialogState(() {});
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showResetPasswordDialog() {
    bool dialogLoading = false;
    String? dialogError;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext dialogContext, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('Reset Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _resetEmailController,
                    decoration: const InputDecoration(labelText: 'Enter your university email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      dialogError!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: dialogLoading
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: dialogLoading
                      ? null
                      : () async {
                          if (_resetEmailController.text.isNotEmpty &&
                              _resetEmailController.text.endsWith('@ju.edu.jo')) {
                            setDialogState(() {
                              dialogLoading = true;
                            });
                            await _handlePasswordReset(
                              _resetEmailController.text,
                              setDialogState,
                              (success) {
                                setDialogState(() {
                                  dialogLoading = false;
                                });
                                Navigator.of(dialogContext).pop();
                                if (success && mounted) {
                                  FirebaseAuth.instance.signOut();
                                  _showLoginPrompt();
                                }
                              },
                            );
                          } else {
                            setDialogState(() {
                              dialogError = 'Please enter a valid @ju.edu.jo email';
                            });
                          }
                        },
                  child: dialogLoading
                      ? const CircularProgressIndicator()
                      : const Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLoginPrompt() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Login Required'),
            content: const Text('Please log in with your new password.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _emailController.clear();
                  _passwordController.clear();
                  FocusScope.of(context).unfocus();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double iconWidgetSize = screenSize.width * 0.18;
    final double iconPadding = screenSize.width * 0.05;
    final double iconContainerRadius = (iconWidgetSize / 2) + iconPadding;
    final double topSpacerHeight = screenSize.height * 0.03;
    final double iconCenterY = topSpacerHeight + iconContainerRadius;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: iconCenterY + iconContainerRadius * 0.8,
              child: CustomPaint(
                painter: BackgroundPainter(
                  gradientTop: gradientTop,
                  gradientBottom: gradientBottom,
                  iconCenterY: iconCenterY,
                  iconRadius: iconContainerRadius,
                ),
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SafeArea(
                      top: true,
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: topSpacerHeight),
                          Container(
                            padding: EdgeInsets.all(iconPadding),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(230),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withAlpha(26),
                                    blurRadius: 10,
                                    spreadRadius: 2)
                              ],
                            ),
                            child: Icon(
                              Icons.person_outline,
                              size: iconWidgetSize,
                              color: iconColor,
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.01),
                          Text(
                            'Sign In',
                            style: TextStyle(
                                fontSize: screenSize.width * 0.08,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF949494)),
                          ),
                          SizedBox(height: screenSize.height * 0.015),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          SizedBox(height: screenSize.height * 0.05),
                          _buildTextFieldSignIn(
                            label: 'University Email',
                            icon: Icons.email_outlined,
                            focusNode: _emailFocus,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            focusColor: emailFocusColor,
                            defaultBorderColor: defaultSignInBorderColor,
                            defaultIconColor: iconColor,
                            defaultLabelColor: labelColor,
                          ),
                          SizedBox(height: screenSize.height * 0.012),
                          _buildPasswordFieldSignIn(
                            label: 'Password',
                            focusNode: _passwordFocus,
                            controller: _passwordController,
                            isVisible: _isPasswordVisible,
                            onToggleVisibility: () =>
                                setState(() => _isPasswordVisible = !_isPasswordVisible),
                            focusColor: passwordFocusColor,
                            defaultBorderColor: defaultSignInBorderColor,
                            defaultIconColor: iconColor,
                            defaultLabelColor: labelColor,
                          ),
                          SizedBox(height: screenSize.height * 0.015),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    activeColor: buttonColor,
                                  ),
                                  const Text(
                                    'Remember Me',
                                    style: TextStyle(color: Color(0xFFA8A8A8)),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: _showResetPasswordDialog,
                                child: Text(
                                  'Forget Your Password ?',
                                  style: TextStyle(
                                    color: labelColor,
                                    fontSize: screenSize.width * 0.03,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_errorMessage != null) ...[
                            SizedBox(height: screenSize.height * 0.015),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ],
                          SizedBox(height: screenSize.height * 0.02),
                          ElevatedButton(
                            onPressed: (_isLoading || _isLoginCooldown) ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenSize.width * 0.3,
                                vertical: screenSize.height * 0.018,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                : Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: screenSize.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          SizedBox(height: screenSize.height * 0.015),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFFA59F9F),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text(
                                  'Or',
                                  style: TextStyle(
                                    color: const Color(0xFF8D8D8D),
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFFA59F9F),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenSize.height * 0.015),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const RealMicrosoftIcon(size: 20),
                            label: Text(
                              'Sign in with Microsoft',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenSize.width * 0.035,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenSize.width * 0.1,
                                vertical: screenSize.height * 0.015,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              elevation: 2,
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.015),
                        ],
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                bottom: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Dont Have an Account ? ',
                      style: TextStyle(
                          color: labelColor, fontSize: screenSize.width * 0.03),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: linkColor,
                          fontSize: screenSize.width * 0.03,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: linkColor,
                          decorationThickness: 1.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldSignIn({
    required String label,
    required IconData icon,
    required FocusNode focusNode,
    required TextEditingController controller,
    required Color focusColor,
    required Color defaultBorderColor,
    required Color defaultIconColor,
    required Color defaultLabelColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final bool hasFocus = focusNode.hasFocus;
    final Color currentLabelColor = hasFocus ? focusColor : defaultLabelColor;
    final Color currentIconColor = hasFocus ? focusColor : defaultIconColor;
    const double borderWidth = 1.0;

    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: currentLabelColor, fontSize: 14),
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: Icon(icon, color: currentIconColor, size: 20),
        filled: false,
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: inactiveBorderColor, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: focusColor, width: borderWidth),
        ),
        floatingLabelStyle: TextStyle(
          color: currentLabelColor,
          fontSize: 14,
          backgroundColor: Colors.white,
        ),
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }

  Widget _buildPasswordFieldSignIn({
    required String label,
    required FocusNode focusNode,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required Color focusColor,
    required Color defaultBorderColor,
    required Color defaultIconColor,
    required Color defaultLabelColor,
  }) {
    final bool hasFocus = focusNode.hasFocus;
    final Color currentLabelColor = hasFocus ? focusColor : defaultLabelColor;
    final Color currentIconColor = hasFocus ? focusColor : defaultIconColor;
    const double borderWidth = 1.0;

    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: currentLabelColor, fontSize: 14),
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: currentIconColor,
            size: 20,
          ),
          onPressed: onToggleVisibility,
        ),
        filled: false,
        contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: inactiveBorderColor, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: focusColor, width: borderWidth),
        ),
        floatingLabelStyle: TextStyle(
          color: currentLabelColor,
          fontSize: 14,
          backgroundColor: Colors.white,
        ),
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }
}

class RealMicrosoftIcon extends StatelessWidget {
  final double size;
  const RealMicrosoftIcon({required this.size, super.key});

  static const Color red = Color(0xFFF25022);
  static const Color green = Color(0xFF7FBA00);
  static const Color blue = Color(0xFF00A4EF);
  static const Color yellow = Color(0xFFFFB900);

  @override
  Widget build(BuildContext context) {
    final double squareSize = size * 0.45;
    final double spacing = size * 0.1;

    return SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: squareSize, height: squareSize, color: red),
              SizedBox(width: spacing),
              Container(width: squareSize, height: squareSize, color: green),
            ],
          ),
          SizedBox(height: spacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: squareSize, height: squareSize, color: blue),
              SizedBox(width: spacing),
              Container(width: squareSize, height: squareSize, color: yellow),
            ],
          ),
        ],
      ),
    );
  }
}
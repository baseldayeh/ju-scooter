import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';

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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _studentIdFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  late List<FocusNode> _focusNodes;
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final Color gradientTop = const Color(0xFF80F1B3);
  final Color gradientBottom = const Color(0xFF26D1A4);
  final Color iconColor = Colors.grey.shade500;
  final Color labelColor = const Color(0xFFA8A8A8);
  final Color buttonColor = const Color(0xFF26D1A4);
  final Color linkColor = const Color(0xFF26D1A4);
  final Color defaultBorderColor = Colors.grey.shade400;

  final Color emailFocusColor = const Color(0xFFED3333);
  final Color nameFocusColor = Colors.amber;
  final Color studentIdFocusColor = const Color(0xFF1DFF97);
  final Color passwordFocusColor = const Color(0xFF1BFEE3);
  final Color phoneFocusColor = const Color(0xFF635E5B);

  String? _emailError;
  String? _firstNameError;
  String? _lastNameError;
  String? _studentIdError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _phoneError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    _focusNodes = [
      _emailFocus,
      _firstNameFocus,
      _lastNameFocus,
      _studentIdFocus,
      _passwordFocus,
      _confirmPasswordFocus,
      _phoneFocus
    ];
    for (var node in _focusNodes) {
      node.addListener(_onFocusChange);
    }
    _signOutIfLoggedIn(); // تسجيل الخروج عند تحميل الصفحة
  }

  // دالة لتسجيل الخروج إذا كان هناك مستخدم حالي
  Future<void> _signOutIfLoggedIn() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.removeListener(_onFocusChange);
      node.dispose();
    }
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _emailError = null;
      _firstNameError = null;
      _lastNameError = null;
      _studentIdError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _phoneError = null;
      _generalError = null;
    });
    for (var node in _focusNodes) {
      if (node.hasFocus) {
        _ensureVisible(node);
      }
    }
  }

  void _ensureVisible(FocusNode focusNode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = focusNode.context;
      if (context != null) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final screenHeight = MediaQuery.of(context).size.height;

        final offset = position.dy + size.height - (screenHeight - keyboardHeight - 100);
        if (offset > 0) {
          _scrollController.animateTo(
            _scrollController.offset + offset,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  bool areFieldsValid() {
    setState(() {
      _emailError = null;
      _firstNameError = null;
      _lastNameError = null;
      _studentIdError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _phoneError = null;
      _generalError = null;
    });

    bool isValid = true;

    // التحقق من البريد الإلكتروني
    final email = _emailController.text;
    if (email.isEmpty) {
      _emailError = 'Email is required';
      isValid = false;
    } else if (!email.contains('@')) {
      _emailError = 'Invalid email format';
      isValid = false;
    } else if (!email.endsWith('@ju.edu.jo')) {
      _emailError = 'Only University of Jordan emails (@ju.edu.jo) are allowed';
      isValid = false;
    }

    // التحقق من الاسم الأول
    final firstName = _firstNameController.text;
    if (firstName.isEmpty) {
      _firstNameError = 'First name is required';
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z\u0621-\u064A\s]+$').hasMatch(firstName)) {
      _firstNameError = 'First name must contain Arabic or English letters only';
      isValid = false;
    }

    // التحقق من الاسم الأخير
    final lastName = _lastNameController.text;
    if (lastName.isEmpty) {
      _lastNameError = 'Last name is required';
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z\u0621-\u064A\s]+$').hasMatch(lastName)) {
      _lastNameError = 'Last name must contain Arabic or English letters only';
      isValid = false;
    }

    // التحقق من رقم الطالب
    final studentId = _studentIdController.text;
    if (studentId.isEmpty) {
      _studentIdError = 'Student ID is required';
      isValid = false;
    } else if (!RegExp(r'^\d{7}$').hasMatch(studentId)) {
      _studentIdError = 'Student ID must be 7 digits';
      isValid = false;
    }

    // التحقق من كلمة المرور
    final password = _passwordController.text;
    if (password.isEmpty) {
      _passwordError = 'Password is required';
      isValid = false;
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(password)) {
      _passwordError = 'Password must be at least 8 characters, include uppercase, lowercase, and a number';
      isValid = false;
    }

    // التحقق من تأكيد كلمة المرور
    final confirmPassword = _confirmPasswordController.text;
    if (confirmPassword.isEmpty) {
      _confirmPasswordError = 'Confirm password is required';
      isValid = false;
    } else if (confirmPassword != password) {
      _confirmPasswordError = 'Passwords do not match';
      isValid = false;
    }

    // التحقق من رقم الهاتف
    final phone = _phoneController.text;
    if (phone.isEmpty) {
      _phoneError = 'Phone number is required';
      isValid = false;
    } else if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      _phoneError = 'Phone number must be 10 digits';
      isValid = false;
    }

    // التحقق من الموافقة على الشروط
    if (!_agreeToTerms) {
      _generalError = 'You must agree to the Terms of Service & Privacy Policy';
      isValid = false;
    }

    return isValid;
  }

  Future<void> _createAccount() async {
    if (!areFieldsValid()) return;

    setState(() {
      _isLoading = true;
      _generalError = null;
    });

    try {
      // إنشاء حساب جديد
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // الحصول على المستخدم الحالي
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        // إرسال رابط التحقق عبر البريد الإلكتروني
        await user.sendEmailVerification();

        // حفظ بيانات المستخدم مؤقتًا
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('temp_email', _emailController.text);
        await prefs.setString('temp_first_name', _firstNameController.text);
        await prefs.setString('temp_last_name', _lastNameController.text);
        await prefs.setString('temp_student_id', _studentIdController.text);
        await prefs.setString('temp_password', _passwordController.text);
        await prefs.setString('temp_phone', _phoneController.text);

        // الانتقال إلى شاشة التحقق
        if (mounted) {
          Navigator.pushNamed(context, '/verify-email');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          _generalError = 'This email is already registered. Please verify your email or use a different email.';
        });
      } else {
        setState(() {
          _generalError = 'Error: ${e.message}';
        });
      }
    } catch (e) {
      setState(() {
        _generalError = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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

    final double termsHeight = 40.0;
    final double spaceBeforeTerms = screenSize.height * 0.02;
    final double spaceAfterTerms = screenSize.height * 0.015;
    final double buttonHeight = screenSize.height * 0.018 * 2 + 20;
    final double spaceAfterButton = screenSize.height * 0.045;
    final double bottomSectionHeight = termsHeight +
        spaceBeforeTerms +
        spaceAfterTerms +
        buttonHeight +
        spaceAfterButton;

    return Scaffold(
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
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
                    child: Icon(Icons.person_add_alt_1_outlined,
                        size: iconWidgetSize, color: gradientBottom),
                  ),
                  SizedBox(height: screenSize.height * 0.015),
                  Text(
                    'Sign Up',
                    style: TextStyle(
                        fontSize: screenSize.width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF949494)),
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                ],
              ),
            ),
          ),
          Positioned(
            top: topSpacerHeight +
                iconContainerRadius * 2 +
                screenSize.height * 0.015 +
                screenSize.width * 0.07 +
                screenSize.height * 0.03 +
                MediaQuery.of(context).padding.top,
            bottom: bottomSectionHeight,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTextField(
                      label: 'Email',
                      icon: Icons.email_outlined,
                      focusNode: _emailFocus,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      specificFocusColor: emailFocusColor,
                      errorText: _emailError,
                    ),
                    SizedBox(height: screenSize.height * 0.015),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'First Name',
                            icon: Icons.person_outline,
                            focusNode: _firstNameFocus,
                            controller: _firstNameController,
                            specificFocusColor: nameFocusColor,
                            errorText: _firstNameError,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildTextField(
                            label: 'Last Name',
                            icon: Icons.person_outline,
                            focusNode: _lastNameFocus,
                            controller: _lastNameController,
                            specificFocusColor: nameFocusColor,
                            errorText: _lastNameError,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenSize.height * 0.015),
                    _buildTextField(
                      label: 'Student ID',
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      focusNode: _studentIdFocus,
                      controller: _studentIdController,
                      specificFocusColor: studentIdFocusColor,
                      errorText: _studentIdError,
                    ),
                    SizedBox(height: screenSize.height * 0.015),
                    _buildPasswordField(
                      label: 'Password',
                      focusNode: _passwordFocus,
                      controller: _passwordController,
                      isVisible: _isPasswordVisible,
                      onToggleVisibility: () =>
                          setState(() => _isPasswordVisible = !_isPasswordVisible),
                      specificFocusColor: passwordFocusColor,
                      errorText: _passwordError,
                    ),
                    SizedBox(height: screenSize.height * 0.015),
                    _buildPasswordField(
                      label: 'Confirm Password',
                      focusNode: _confirmPasswordFocus,
                      controller: _confirmPasswordController,
                      isVisible: _isConfirmPasswordVisible,
                      onToggleVisibility: () => setState(
                          () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      specificFocusColor: passwordFocusColor,
                      errorText: _confirmPasswordError,
                    ),
                    SizedBox(height: screenSize.height * 0.015),
                    _buildTextField(
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      focusNode: _phoneFocus,
                      controller: _phoneController,
                      specificFocusColor: phoneFocusColor,
                      errorText: _phoneError,
                    ),
                    if (_generalError != null) ...[
                      SizedBox(height: screenSize.height * 0.015),
                      Text(
                        _generalError!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ],
                    SizedBox(height: screenSize.height * 0.02),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: buttonHeight + spaceAfterButton + 30,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (bool? value) {
                          FocusNode? currentFocus = FocusScope.of(context).focusedChild;
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                          if (currentFocus != null && _focusNodes.contains(currentFocus)) {
                            currentFocus.requestFocus();
                          }
                        },
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return buttonColor;
                          }
                          return Colors.transparent;
                        }),
                        checkColor: Colors.white,
                        side: BorderSide(
                            color: _agreeToTerms ? buttonColor : iconColor),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 14.0, color: labelColor),
                            children: [
                              const TextSpan(text: 'I agree to Terms of '),
                              TextSpan(
                                text: 'Service',
                                style: TextStyle(
                                    color: linkColor,
                                    decoration: TextDecoration.underline),
                              ),
                              const TextSpan(text: ' & '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                    color: linkColor,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spaceAfterTerms),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: spaceAfterButton + 35,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Opacity(
                opacity: _agreeToTerms && !_isLoading ? 1.0 : 0.5,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.15,
                        vertical: screenSize.height * 0.018),
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
                          'Create Account',
                          style: TextStyle(
                              fontSize: screenSize.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
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
                    'Already Have an Account, ',
                    style: TextStyle(
                        color: labelColor, fontSize: screenSize.width * 0.035),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: linkColor,
                        fontSize: screenSize.width * 0.035,
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
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required FocusNode focusNode,
    required TextEditingController controller,
    required Color specificFocusColor,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final bool hasFocus = focusNode.hasFocus;
    final Color currentBorderColor = hasFocus ? specificFocusColor : defaultBorderColor;
    final Color currentLabelColor = hasFocus ? specificFocusColor : labelColor;
    final Color currentIconColor = hasFocus ? specificFocusColor : iconColor;

    final InputBorder enabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(color: defaultBorderColor, width: 1.0),
    );

    final InputBorder focusedSolidBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(color: currentBorderColor, width: 1.5),
    );

    final InputBorder errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: const BorderSide(color: Colors.red, width: 1.0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          focusNode: focusNode,
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: currentLabelColor, fontSize: 14),
            floatingLabelStyle: TextStyle(
              color: currentLabelColor,
              fontSize: 14,
              backgroundColor: Colors.white,
            ),
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            suffixIcon: Icon(icon, color: currentIconColor, size: 20),
            filled: false,
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            enabledBorder: enabledBorder,
            focusedBorder: focusedSolidBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,
            errorText: errorText,
            errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
          ),
          style: const TextStyle(color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required FocusNode focusNode,
    required TextEditingController controller,
    required Color specificFocusColor,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? errorText,
  }) {
    final bool hasFocus = focusNode.hasFocus;
    final Color currentBorderColor = hasFocus ? specificFocusColor : defaultBorderColor;
    final Color currentLabelColor = hasFocus ? specificFocusColor : labelColor;
    final Color currentIconColor = hasFocus ? specificFocusColor : iconColor;

    final InputBorder enabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(color: defaultBorderColor, width: 1.0),
    );

    final InputBorder focusedSolidBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(color: currentBorderColor, width: 1.5),
    );

    final InputBorder errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: const BorderSide(color: Colors.red, width: 1.0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          focusNode: focusNode,
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: currentLabelColor, fontSize: 14),
            floatingLabelStyle: TextStyle(
              color: currentLabelColor,
              fontSize: 14,
              backgroundColor: Colors.white,
            ),
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
            enabledBorder: enabledBorder,
            focusedBorder: focusedSolidBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,
            errorText: errorText,
            errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
          ),
          style: const TextStyle(color: Colors.black87),
        ),
      ],
    );
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
  final FocusNode _studentIdFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  late List<FocusNode> _focusNodes;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  final Color gradientTop = const Color(0xFF80F1B3);
  final Color gradientBottom = const Color(0xFF26D1A4);
  final Color iconColor = Colors.grey.shade500;
  final Color labelColor = const Color(0xFFA8A8A8);
  final Color buttonColor = const Color(0xFF26D1A4);
  final Color linkColor = const Color(0xFF26D1A4);
  final Color defaultSignInBorderColor = const Color(0xFF26D1A4);
  final Color studentIdFocusColor = const Color(0xFF1DFF97);
  final Color passwordFocusColor = const Color(0xFF1BFEE3);
  final Color inactiveBorderColor = Colors.grey.shade300;

  @override
  void initState() {
    super.initState();
    _focusNodes = [_studentIdFocus, _passwordFocus];
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
    _studentIdController.dispose();
    _passwordController.dispose();
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedStudentId = prefs.getString('student_id');
      String? savedPassword = prefs.getString('password');
      String? savedEmail = prefs.getString('email');

      if (_studentIdController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Please fill in all fields';
        });
        return;
      }

      if (_studentIdController.text == savedStudentId && _passwordController.text == savedPassword) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: savedEmail!,
          password: _passwordController.text,
        );
        User? user = FirebaseAuth.instance.currentUser;
        if (user!.emailVerified) {
          await prefs.setBool('isLoggedIn', true);
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() {
            _errorMessage = 'Please verify your email first';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid Student ID or password';
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double iconWidgetSize = screenSize.width * 0.18;
    final double iconPadding = screenSize.width * 0.05;
    final double iconContainerRadius = (iconWidgetSize / 2) + iconPadding;
    final double topSpacerHeight = screenSize.height * 0.03;
    final double iconCenterY = topSpacerHeight + iconContainerRadius;

    return Scaffold(
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
                          label: 'Student ID',
                          icon: Icons.person_outline,
                          focusNode: _studentIdFocus,
                          controller: _studentIdController,
                          keyboardType: TextInputType.number,
                          focusColor: studentIdFocusColor,
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Forget Your Password ?',
                              style: TextStyle(
                                color: labelColor,
                                fontSize: screenSize.width * 0.03,
                              ),
                            ),
                          ),
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
                          onPressed: _isLoading ? null : _signIn,
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
                      Navigator.pushNamed(context, '/');
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
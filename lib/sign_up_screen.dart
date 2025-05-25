import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'session_manager.dart'; // استيراد ملف SessionManager

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
  File? _image;
  final ImagePicker _picker = ImagePicker();

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
  final Color studentIdFocusColor = Colors.orange;
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

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    _signOutIfLoggedIn();
  }

  Future<void> _signOutIfLoggedIn() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await SessionManager.clearSession();
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

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image, String userId) async {
    try {
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('user_files/$userId/$fileName');
      await storageRef.putFile(image);
      final imageUrl = await storageRef.getDownloadURL();
      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
      return null;
    }
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

    final email = _emailController.text;
    if (email.isEmpty) {
      _emailError = 'Email is required';
      isValid = false;
    } else if (!email.endsWith('@ju.edu.jo')) {
      _emailError = 'Only University of Jordan emails (@ju.edu.jo) are allowed';
      isValid = false;
    }

    final firstName = _firstNameController.text;
    if (firstName.isEmpty) {
      _firstNameError = 'First name is required';
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z\u0621-\u064A\s]+$').hasMatch(firstName)) {
      _firstNameError = 'First name must contain Arabic or English letters only';
      isValid = false;
    } else if (firstName.length < 3) {
      _firstNameError = 'First name must be at least 3 characters';
      isValid = false;
    }

    final lastName = _lastNameController.text;
    if (lastName.isEmpty) {
      _lastNameError = 'Last name is required';
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z\u0621-\u064A\s]+$').hasMatch(lastName)) {
      _lastNameError = 'Last name must contain Arabic or English letters only';
      isValid = false;
    }

    final studentId = _studentIdController.text;
    if (studentId.isEmpty) {
      _studentIdError = 'Student ID is required';
      isValid = false;
    } else if (!RegExp(r'^\d+$').hasMatch(studentId)) {
      _studentIdError = 'Student ID must contain numbers only';
      isValid = false;
    } else if (studentId.length != 7) {
      _studentIdError = 'Student ID must be exactly 7 digits';
      isValid = false;
    }

    final password = _passwordController.text;
    if (password.isEmpty) {
      _passwordError = 'Password is required';
      isValid = false;
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(password)) {
      _passwordError = 'Password must be at least 8 characters, include uppercase, lowercase, and a number';
      isValid = false;
    }

    final confirmPassword = _confirmPasswordController.text;
    if (confirmPassword.isEmpty) {
      _confirmPasswordError = 'Confirm password is required';
      isValid = false;
    } else if (confirmPassword != password) {
      _confirmPasswordError = 'Passwords do not match';
      isValid = false;
    }

    final phone = _phoneController.text;
    if (phone.isEmpty) {
      _phoneError = 'Phone number is required';
      isValid = false;
    } else if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      _phoneError = 'Phone number must be 10 digits';
      isValid = false;
    }

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
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        String? imageUrl;
        if (_image != null) {
          imageUrl = await _uploadImage(_image!, user.uid);
        }

        // حفظ بيانات المستخدم في Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': _emailController.text,
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'student_id': _studentIdController.text,
          'phone': _phoneController.text,
          if (imageUrl != null) 'profile_image_url': imageUrl,
        });

        await user.sendEmailVerification();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('temp_email', _emailController.text);
        await prefs.setString('temp_first_name', _firstNameController.text);
        await prefs.setString('temp_last_name', _lastNameController.text);
        await prefs.setString('temp_student_id', _studentIdController.text);
        await prefs.setString('temp_password', _passwordController.text);
        await prefs.setString('temp_phone', _phoneController.text);

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
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
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
                      child: CircleAvatar(
                        radius: iconWidgetSize / 2,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : const AssetImage('assets/user_profile_icon.png') as ImageProvider,
                        child: _image == null
                            ? Icon(Icons.camera_alt, size: iconWidgetSize * 0.5, color: Colors.grey)
                            : null,
                      ),
                    ),
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
                      label: 'University Email',
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
                      focusNode: _studentIdFocus,
                      controller: _studentIdController,
                      keyboardType: TextInputType.number,
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
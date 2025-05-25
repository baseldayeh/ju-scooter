import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ju_scooter/session_manager.dart';
import 'package:logger/logger.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _reauthPasswordController = TextEditingController();
  File? _imageFile;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isPasswordVisible = false;
  String _language = 'English';
  bool _isSaving = false;

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _reauthPasswordFocus = FocusNode();
  late List<FocusNode> _focusNodes;

  static const Color gradientColor1 = Color(0xFF00FF80);
  static const Color gradientColor2 = Color(0xFF65E5D0);
  final Color iconColor = Colors.grey.shade500;
  final Color labelColor = const Color(0xFFA8A8A8);
  final Color buttonColor = const Color(0xFF26D1A4);
  final Color defaultBorderColor = gradientColor1;

  final Color nameFocusColor = Colors.amber;
  final Color passwordFocusColor = const Color(0xFF1BFEE3);
  final Color phoneFocusColor = const Color(0xFF635E5B);

  final Logger _logger = Logger();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Variable to control vertical spacing between form fields
  final double _formFieldVerticalSpacing = 8.0;

  // Variable to control vertical padding inside form fields
  final double _formFieldVerticalPadding = 15.0;

  @override
  void initState() {
    super.initState();
    _focusNodes = [_firstNameFocus, _lastNameFocus, _passwordFocus, _phoneFocus, _reauthPasswordFocus];
    for (var node in _focusNodes) {
      node.addListener(_onFocusChange);
    }
    _loadProfileData();
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.removeListener(_onFocusChange);
      node.dispose();
    }
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _reauthPasswordController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  Future<void> _loadProfileData() async {
    Map<String, dynamic> sessionData = await SessionManager.getSessionData();
    if (sessionData.isNotEmpty) {
      setState(() {
        _firstNameController.text = sessionData['first_name']?.toString() ?? '';
        _lastNameController.text = sessionData['last_name']?.toString() ?? '';
        _phoneController.text = sessionData['phone']?.toString() ?? '';
        _imageUrl = sessionData['profile_image_url']?.toString();
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _deleteImage() async {
    setState(() {
      _imageFile = null;
      _imageUrl = null;
    });
  }

  Future<String?> _uploadImage(File? image) async {
    if (image == null) return null;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _logger.e('No authenticated user found');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No authenticated user found')),
        );
      }
      return null;
    }

    await user.reload();
    if (!user.emailVerified) {
      _logger.e('User email is not verified');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please verify your email before uploading')),
        );
      }
      return null;
    }

    try {
      final ref = _storage.ref().child('profile_images/${user.uid}.jpg');
      await ref.putFile(image);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      _logger.e('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
      return null;
    }
  }

  Future<bool> _reauthenticateUser() async {
    bool reauthSuccess = false;
    String? errorMessage;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext dialogContext, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('Re-authenticate'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Please enter your current password to proceed.'),
                  const SizedBox(height: 10),
                  TextFormField(
                    focusNode: _reauthPasswordFocus,
                    controller: _reauthPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null && user.email != null) {
                      try {
                        final credential = EmailAuthProvider.credential(
                          email: user.email!,
                          password: _reauthPasswordController.text,
                        );
                        await user.reauthenticateWithCredential(credential);
                        reauthSuccess = true;
                        Navigator.of(dialogContext).pop();
                      } catch (e) {
                        setDialogState(() {
                          errorMessage = 'Invalid password. Please try again.';
                        });
                      }
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );

    return reauthSuccess;
  }

  Future<void> _saveProfile() async {
    if (!mounted) return;

    setState(() {
      _isSaving = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isSaving = false;
      });
      return;
    }

    String? newImageUrl;
    if (_imageFile != null) {
      newImageUrl = await _uploadImage(_imageFile);
      if (newImageUrl == null) {
        setState(() {
          _isSaving = false;
        });
        return;
      }
    }

    if (_passwordController.text.isNotEmpty) {
      try {
        bool reauthSuccess = await _reauthenticateUser();
        if (!reauthSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Re-authentication failed. Password not updated.')),
            );
          }
          setState(() {
            _isSaving = false;
          });
          return;
        }
        await user.updatePassword(_passwordController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully')),
          );
        }
      } catch (e) {
        _logger.e('Error updating password: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating password: $e')),
          );
        }
      }
    }

    Map<String, dynamic> updatedData = {};
    if (_firstNameController.text.isNotEmpty) {
      updatedData['first_name'] = _firstNameController.text;
    }
    if (_lastNameController.text.isNotEmpty) {
      updatedData['last_name'] = _lastNameController.text;
    }
    if (_phoneController.text.isNotEmpty) {
      updatedData['phone'] = _phoneController.text;
    }
    if (newImageUrl != null) {
      updatedData['profile_image_url'] = newImageUrl;
    }

    if (updatedData.isNotEmpty) {
      await _firestore.collection('users').doc(user.uid).update(updatedData);

      Map<String, dynamic> sessionData = await SessionManager.getSessionData();
      sessionData['first_name'] = updatedData['first_name'] ?? sessionData['first_name'];
      sessionData['last_name'] = updatedData['last_name'] ?? sessionData['last_name'];
      sessionData['phone'] = updatedData['phone'] ?? sessionData['phone'];
      if (newImageUrl != null) {
        sessionData['profile_image_url'] = newImageUrl;
      }
      await SessionManager.setActiveSession(userData: sessionData);
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
        if (newImageUrl != null) _imageUrl = newImageUrl;
      });
      Navigator.pop(context, newImageUrl);
    }
  }

  Future<void> _signOut() async {
    try {
      await SessionManager.clearSession();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      _logger.e('Error signing out: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        bool reauthSuccess = await _reauthenticateUser();
        if (!reauthSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Re-authentication failed. Account not deleted.')),
            );
          }
          return;
        }

        Map<String, dynamic> sessionData = await SessionManager.getSessionData();
        String? imageUrl = sessionData['profile_image_url'];
        if (imageUrl != null) {
          try {
            await _storage.refFromURL(imageUrl).delete();
          } catch (e) {
            _logger.e('Error deleting profile image: $e');
          }
        }

        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
        await SessionManager.clearSession();

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        _logger.e('Error deleting account: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting account: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        Navigator.pop(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Gradient Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: screenSize.height * 0.1,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gradientColor1, gradientColor2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 5,
                        left: 10,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Avatar and Email (Separated from Gradient Header)
            Positioned(
              top: screenSize.height * 0.13,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : _imageUrl != null
                                  ? NetworkImage(_imageUrl!)
                                  : const AssetImage('assets/user_profile_icon2.png') as ImageProvider,
                          onBackgroundImageError: (e, stackTrace) {
                            _logger.e('Error loading profile image: $e');
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        if (_imageFile != null || _imageUrl != null) // Show delete button only if there's an image
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: GestureDetector(
                              onTap: _deleteImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          colors: [gradientColor1, gradientColor2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      child: Text(
                        FirebaseAuth.instance.currentUser?.email ?? 'No email',
                        style: const TextStyle(
                          color: Colors.white, // Base color, will be overridden by gradient
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Form Fields
            Positioned(
              top: screenSize.height * 0.33,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'First Name',
                          controller: _firstNameController,
                          focusNode: _firstNameFocus,
                          focusColor: nameFocusColor,
                          defaultBorderColor: defaultBorderColor,
                          defaultLabelColor: labelColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTextField(
                          label: 'Last Name',
                          controller: _lastNameController,
                          focusNode: _lastNameFocus,
                          focusColor: nameFocusColor,
                          defaultBorderColor: defaultBorderColor,
                          defaultLabelColor: labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _formFieldVerticalSpacing),
                  _buildPasswordField(
                    label: 'Password',
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    focusColor: passwordFocusColor,
                    defaultBorderColor: defaultBorderColor,
                    defaultLabelColor: labelColor,
                  ),
                  SizedBox(height: _formFieldVerticalSpacing),
                  _buildTextField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    focusColor: phoneFocusColor,
                    defaultBorderColor: defaultBorderColor,
                    defaultLabelColor: labelColor,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: _formFieldVerticalSpacing),
                  DropdownButtonFormField<String>(
                    value: _language,
                    decoration: InputDecoration(
                      labelText: 'Language',
                      labelStyle: TextStyle(color: labelColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    items: ['English', 'Arabic'].map((String language) {
                      return DropdownMenuItem<String>(
                        value: language,
                        child: Text(language),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _language = newValue ?? 'English';
                      });
                    },
                  ),
                ],
              ),
            ),
            // Save Changes Button
            Positioned(
              bottom: 200,
              left: 0,
              right: 0,
              child: Center(
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.22,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
            // Sign Out and Delete Account Buttons
            Positioned(
              bottom: 120,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _signOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF44336),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Color focusColor,
    required Color defaultBorderColor,
    required Color defaultLabelColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final bool hasFocus = focusNode.hasFocus;
    final Color currentLabelColor = hasFocus ? focusColor : defaultLabelColor;

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
        filled: false,
        contentPadding: EdgeInsets.fromLTRB(20.0, _formFieldVerticalPadding, 20.0, _formFieldVerticalPadding),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: focusColor, width: 1.0),
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Color focusColor,
    required Color defaultBorderColor,
    required Color defaultLabelColor,
  }) {
    final bool hasFocus = focusNode.hasFocus;
    final Color currentLabelColor = hasFocus ? focusColor : defaultLabelColor;

    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: currentLabelColor, fontSize: 14),
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: currentLabelColor,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        filled: false,
        contentPadding: EdgeInsets.fromLTRB(20.0, _formFieldVerticalPadding, 20.0, _formFieldVerticalPadding),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: focusColor, width: 1.0),
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
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ju_scooter/session_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

// Top-level _launchURL function for shared use
Future<void> _launchURL(String url, {String? fallbackUrl}) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (fallbackUrl != null) {
      final Uri fallbackUri = Uri.parse(fallbackUrl);
      if (!await launchUrl(fallbackUri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url or $fallbackUrl';
      }
    } else {
      throw 'Could not launch $url';
    }
  }
}

// NotificationsPage
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 90,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFED5021), Color(0xFFED3333), Color(0xFFDA1E53)],
                stops: [0.16, 0.46, 0.81],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    top: 0,
                    width: 48,
                    height: 60,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Positioned(
                    top: 15,
                    left: (screenWidth - 200) / 2,
                    width: 200,
                    height: 30,
                    child: Center(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.notifications, color: Colors.red, size: 24),
                            title: Text(
                              'New Scooter Available',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'Check out our latest electric scooter model!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Divider(color: Colors.grey[300], thickness: 1),
                          ListTile(
                            leading: const Icon(Icons.notifications, color: Colors.red, size: 24),
                            title: Text(
                              'Maintenance Reminder',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'Schedule your scooter maintenance',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Divider(color: Colors.grey[300], thickness: 1),
                          ListTile(
                            leading: const Icon(Icons.notifications, color: Colors.red, size: 24),
                            title: Text(
                              'Promotion Offer',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'Get 20% off your next ride!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Divider(color: Colors.grey[300], thickness: 1),
                        ],
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
}

// SocialChannelsPage
class SocialChannelsPage extends StatelessWidget {
  const SocialChannelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 90,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFED5021), Color(0xFFED3333), Color(0xFFDA1E53)],
                stops: [0.16, 0.46, 0.81],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    top: 0,
                    width: 48,
                    height: 60,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Positioned(
                    top: 15,
                    left: 80,
                    width: 250,
                    height: 30,
                    child: Center(
                      child: Text(
                        'Connect with JuScooter',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const FaIcon(FontAwesomeIcons.instagram, color: Color(0xFFE1306C), size: 24),
                            title: Text(
                              'Instagram',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              '@ju_scooter',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.red, size: 20),
                            onTap: () => _launchURL(
                              'instagram://user?username=ju_scooter',
                              fallbackUrl: 'https://www.instagram.com/ju_scooter?igsh=Zm5yaGk1Z2pyZGE1',
                            ),
                          ),
                          Divider(color: Colors.grey[300], thickness: 1),
                          ListTile(
                            leading: const FaIcon(FontAwesomeIcons.facebook, color: Color(0xFF1877F2), size: 24),
                            title: Text(
                              'Facebook',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'JuScooter',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.red, size: 20),
                            onTap: () => _launchURL(
                              'fb://facewebmodal/f?href=https://www.facebook.com/share/1YZShYdKeK/',
                              fallbackUrl: 'https://www.facebook.com/share/1YZShYdKeK/',
                            ),
                          ),
                          Divider(color: Colors.grey[300], thickness: 1),
                          ListTile(
                            leading: const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366), size: 24),
                            title: Text(
                              'WhatsApp',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'JuScooter Support',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.red, size: 20),
                            onTap: () => _launchURL('https://wa.me/+96277666421'),
                          ),
                          Divider(color: Colors.grey[300], thickness: 1),
                          ListTile(
                            leading: const FaIcon(FontAwesomeIcons.youtube, color: Color(0xFFFF0000), size: 24),
                            title: Text(
                              'YouTube',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'JuScooter Channel',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.red, size: 20),
                            onTap: () => _launchURL('https://www.youtube.com/@juscooter'),
                          ),
                          Divider(color: Colors.grey[300], thickness: 1),
                          ListTile(
                            leading: const FaIcon(FontAwesomeIcons.xTwitter, color: Color(0xFF000000), size: 24),
                            title: Text(
                              'X',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              '@ju_scooter',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.red, size: 20),
                            onTap: () => _launchURL(
                              'twitter://user?screen_name=dayeh_base51191',
                              fallbackUrl: 'https://x.com/dayeh_base51191?t=-vmgIkLS_mw1eu5Vzm11IQ&s=09',
                            ),
                          ),
                          Divider(color: Colors.grey[300], thickness: 1),
                          const SizedBox(height: 20),
                          CachedNetworkImage(
                            imageUrl: 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/menu%2Fundraw_social-dashboard_81sv%201.png?alt=media&token=d216f9ef-3c00-40fd-8e82-733634995894',
                            width: 500,
                            height: 200,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
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
          ),
        ],
      ),
    );
  }
}

// RidingHistoryScreen
class RidingHistoryScreen extends StatelessWidget {
  const RidingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 90,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFED5021), Color(0xFFED3333), Color(0xFFDA1E53)],
                stops: [0.16, 0.46, 0.81],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    top: 0,
                    width: 48,
                    height: 60,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    left: (screenWidth - 200) / 2,
                    width: 200,
                    height: 30,
                    child: Center(
                      child: Text(
                        'Riding history',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Get riding!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Once you end your first ride,\nit\'ll show up here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// SpeedModeScreen
class SpeedModeScreen extends StatefulWidget {
  const SpeedModeScreen({super.key});

  @override
  State<SpeedModeScreen> createState() => _SpeedModeScreenState();
}

class _SpeedModeScreenState extends State<SpeedModeScreen> {
  String _selectedSpeed = 'Standard speed';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _loadSpeedMode();
  }

  Future<void> _loadSpeedMode() async {
    try {
      // Try SessionManager first
      Map<String, dynamic> sessionData = await SessionManager.getSessionData();
      String? savedSpeed = sessionData['speed_mode']?.toString();
      if (savedSpeed != null && (savedSpeed == 'Standard speed' || savedSpeed == 'Reduced speed')) {
        setState(() {
          _selectedSpeed = savedSpeed;
        });
        return;
      }

      // Fallback to Firestore
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        final data = doc.data();
        if (data != null && data['speed_mode'] != null) {
          String firestoreSpeed = data['speed_mode'];
          if (firestoreSpeed == 'Standard speed' || firestoreSpeed == 'Reduced speed') {
            setState(() {
              _selectedSpeed = firestoreSpeed;
            });
            // Update SessionManager
            sessionData['speed_mode'] = firestoreSpeed;
            await SessionManager.setActiveSession(userData: sessionData);
          }
        }
      }
    } catch (e) {
      _logger.e('Error loading speed mode: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading speed mode: $e')),
        );
      }
    }
  }

  Future<void> _saveSpeedMode() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _logger.e('No authenticated user found');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No authenticated user found')),
          );
        }
        return;
      }

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'speed_mode': _selectedSpeed,
      });

      // Update SessionManager
      Map<String, dynamic> sessionData = await SessionManager.getSessionData();
      sessionData['speed_mode'] = _selectedSpeed;
      await SessionManager.setActiveSession(userData: sessionData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speed mode saved successfully')),
        );
      }
    } catch (e) {
      _logger.e('Error saving speed mode: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving speed mode: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Header
          Positioned(
            top: 0,
            left: 0,
            width: screenWidth,
            height: 90,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFED5021), Color(0xFFED3333), Color(0xFFDA1E53)],
                  stops: [0.16, 0.46, 0.81],
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      top: 0,
                      width: 48,
                      height: 60,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      left: (screenWidth - 200) / 2,
                      width: 200,
                      height: 30,
                      child: Center(
                        child: Text(
                          'Speed mode',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Image
          Positioned(
            top: 90,
            left: -50,
            width: 500,
            height: 250,
            child: CachedNetworkImage(
              imageUrl: 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/menu%2FGroup%2072.png?alt=media&token=a5e83fca-c815-4f5a-a075-bc029050859a',
              fit: BoxFit.contain,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            ),
          ),
          // Ride mode Text
          Positioned(
            top: 330,
            left: (screenWidth - 200) / 2,
            width: 200,
            height: 30,
            child: Center(
              child: Text(
                'Ride mode',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // Subtitle
          Positioned(
            top: 370,
            left: 40,
            width: 300,
            height: 50,
            child: Center(
              child: Text(
                '"Select one of the following speed levels, according to your experience"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          // Standard Speed Option
          Positioned(
            top: 450,
            left: 20,
            width: 350,
            height: 80,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSpeed = 'Standard speed';
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedSpeed == 'Standard speed' ? Colors.red : Colors.grey[300]!,
                    width: _selectedSpeed == 'Standard speed' ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 8.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      left: 16,
                      width: 200,
                      height: 25,
                      child: Text(
                        'Standard speed',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 16,
                      width: 200,
                      height: 20,
                      child: Text(
                        'Speed up to 20km/h',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 25,
                      left: 290,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedSpeed == 'Standard speed' ? Colors.red : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: _selectedSpeed == 'Standard speed'
                            ? Container(
                                margin: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Reduced Speed Option
          Positioned(
            top: 560,
            left: 20,
            width: 350,
            height: 80,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSpeed = 'Reduced speed';
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedSpeed == 'Reduced speed' ? Colors.red : Colors.grey[300]!,
                    width: _selectedSpeed == 'Reduced speed' ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 8.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      left: 16,
                      width: 200,
                      height: 25,
                      child: Text(
                        'Reduced speed',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 16,
                      width: 200,
                      height: 20,
                      child: Text(
                        'Speed up to 15km/h',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 25,
                      left: 290,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedSpeed == 'Reduced speed' ? Colors.red : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: _selectedSpeed == 'Reduced speed'
                            ? Container(
                                margin: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Okay, got it Button
          Positioned(
            top: 710,
            left: (screenWidth - 300) / 2,
            width: 300,
            height: 54,
            child: ElevatedButton(
              onPressed: () async {
                await _saveSpeedMode();
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFFED5021), Color(0xFFED3333), Color(0xFFDA1E53)],
                    stops: [0.16, 0.46, 0.81],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Okay, got it',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

// LegalScreen
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 90,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFED5021), Color(0xFFED3333), Color(0xFFDA1E53)],
                stops: [0.16, 0.46, 0.81],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    top: 0,
                    width: 48,
                    height: 60,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    left: (screenWidth - 200) / 2,
                    width: 200,
                    height: 30,
                    child: Center(
                      child: Text(
                        'Legal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildLegalItem(context, 'Terms of Use'),
                const Divider(height: 1, color: Colors.grey),
                _buildLegalItem(context, 'Privacy Policy'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem(BuildContext context, String title) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.red),
      onTap: () {
        if (title == 'Terms of Use') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TermsScreen()),
          );
        } else if (title == 'Privacy Policy') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrivacyScreen()),
          );
        }
      },
    );
  }
}

// TermsScreen
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  final String _termsText = '''
Terms of Use – ju-scooter

Last Updated: May 23, 2025

Please read these Terms of Use carefully before using the ju-scooter application. By using this app, you agree to be bound by these terms.

1. Introduction:
ju-scooter is a mobile application for renting electric scooters within the University of Jordan campus.

2. Eligibility:
- You must be a student or staff member at the University of Jordan.
- You must be at least 18 years old.

3. Registration:
- Requires a valid university email address.
- You are responsible for keeping your account secure.

4. Proper Use:
- Scooters must be used only within campus boundaries.
- Reckless driving or carrying passengers is prohibited.

5. Responsibility:
- You are responsible for any damage during your rental session.
- We are not liable for injuries caused by improper use.

6. Pricing:
- Pricing is based on usage duration.
- Late return fees may apply.

7. Cancellation:
- No refunds after starting a session.
- Report issues for possible compensation.

8. User Conduct:
- Respect university rules and community standards.
- Do not use the app for illegal purposes.

9. Updates:
- We may update these terms at any time. Users will be notified.

10. Contact:
For inquiries or support: juscooter.support@gmail.com
  ''';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 90,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFED5021), Color(0xFFED3333), Color(0xFFDA1E53)],
                stops: [0.16, 0.46, 0.81],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    top: 0,
                    width: 48,
                    height: 60,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    left: (screenWidth - 200) / 2,
                    width: 200,
                    height: 30,
                    child: Center(
                      child: Text(
                        'Terms of Use',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                _termsText,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// PrivacyScreen
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  final String _privacyText = '''
Privacy Policy – ju-scooter

Last Updated: May 23, 2025

We value your privacy and are committed to protecting your personal data. By using the app, you agree to the practices described in this policy.

1. Data We Collect:
- Name, university email, university ID.
- Scooter usage history and in-campus location data.
- Technical info such as IP address and device type.

2. How We Use Data:
- To create and manage user accounts.
- To provide scooter rental services.
- To improve app performance and contact you when needed.

3. Data Sharing:
- We do not share your data except with your consent or as required by law.

4. Data Security:
- Data is encrypted and securely stored.
- Access is limited to authorized team members only.

5. Your Rights:
- You may request to access, correct, or delete your data.
- Contact us at: juscooter.support@gmail.com

6. Cookies:
- We currently do not use cookies.

7. Updates:
- We may update this policy and will notify users of major changes.

8. Contact:
For any questions regarding privacy:
📧 juscooter.support@gmail.com
  ''';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 90,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFED5021), Color(0xFFED3333), Color(0xFFDA1E53)],
                stops: [0.16, 0.46, 0.81],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    top: 0,
                    width: 48,
                    height: 60,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    left: (screenWidth - 200) / 2,
                    width: 200,
                    height: 30,
                    child: Center(
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                _privacyText,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// MenuContent
class MenuContent extends StatefulWidget {
  const MenuContent({super.key});

  @override
  State<MenuContent> createState() => _MenuContentState();
}

class _MenuContentState extends State<MenuContent> {
  String _greeting = 'Hi, User';
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      Map<String, dynamic> sessionData = await SessionManager.getSessionData();
      String? firstName = sessionData['first_name']?.toString();
      String? lastName = sessionData['last_name']?.toString();
      setState(() {
        if (firstName != null && firstName.isNotEmpty && lastName != null && lastName.isNotEmpty) {
          _greeting = 'Hi, $firstName $lastName';
        } else if (firstName != null && firstName.isNotEmpty) {
          _greeting = 'Hi, $firstName';
        } else {
          _greeting = 'Hi, User';
        }
      });
    } catch (e) {
      _logger.e('Error loading user name: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user name: $e')),
        );
      }
    }
  }

  Future<void> _showLogoutSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent, // للسماح برؤية المستطيل
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Stack(
        children: [
          Positioned(
            top: 230,
            left: 2,
            width: 380,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // شريط السحب
                  Positioned(
                    top: 10,
                    left: 138, // توسيط داخل المستطيل
                    width: 100,
                    height: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  // النص
                  Positioned(
                    top: 40,
                    left: 25,
                    width: 350,
                    height: 35,
                    child: const Text(
                      'Are you sure you want to sign out?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // زر Sign out
                  Positioned(
                    top: 120,
                    left: 45,
                    width: 300,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await SessionManager.clearSession();
                          if (context.mounted) {
                            // ignore: use_build_context_synchronously
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        } catch (e) {
                          debugPrint('Error during logout: $e');
                          if (context.mounted) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error logging out: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFED5021), Color(0xFFED3333), Color(0xFFDA1E53)],
                            stops: [0.16, 0.46, 0.81],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'Sign out',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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

  Widget _buildGradientIconButton(IconData icon, VoidCallback onPressed) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF012D37), Color(0xFF635E5B), Color(0xFF001637)],
      ).createShader(bounds),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 35,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFFED5021), Color(0xFFED3333), Color(0xFFDA1E53)],
                    stops: [0.16, 0.46, 0.81],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 28,
                        left: 20,
                        child: Text(
                          _greeting,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFF012D37), Color(0xFF635E5B), Color(0xFF001637)],
                              stops: [0.0, 0.495, 1.0],
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildGradientIconButton(Icons.brightness_4, () {}),
                                _buildGradientIconButton(Icons.language, () {}),
                                _buildGradientIconButton(Icons.power_settings_new, () => _showLogoutSheet(context)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 100,
                        left: -10,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LegalScreen()),
                            );
                          },
                          child: CachedNetworkImage(
                            imageUrl: 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/menu%2FGroup%2048.png?alt=media&token=3bc288bd-be10-4e8a-8215-07f958526817',
                            width: 130,
                            height: 90,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 100,
                        left: 128,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NotificationsPage()),
                            );
                          },
                          child: CachedNetworkImage(
                            imageUrl: 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/menu%2FGroup%2049.png?alt=media&token=d98aef6f-c67e-44a4-9b88-815250d7b240',
                            width: 130,
                            height: 90,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 100,
                        left: 260,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SocialChannelsPage()),
                            );
                          },
                          child: CachedNetworkImage(
                            imageUrl: 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/menu%2FGroup%2050.png?alt=media&token=1b967074-4e03-4840-91b3-84ff8710fac5',
                            width: 130,
                            height: 90,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 100,
                        left: 390,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LegalScreen()),
                            );
                          },
                          child: CachedNetworkImage(
                            imageUrl: 'https://via.placeholder.com/130x90',
                            width: 130,
                            height: 90,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 220,
                        left: 20,
                        right: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(26),
                                blurRadius: 8.0,
                                spreadRadius: 2.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const SpeedModeScreen()),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 10),
                                      const Icon(Icons.speed, color: Colors.black, size: 30),
                                      const SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Speed mode',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            'Reduced speed',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.chevron_right, color: Colors.red),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(color: Colors.grey[300], thickness: 1, indent: 20, endIndent: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _launchURL('https://forms.gle/qivL57KRvcRsyRus5'),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 10),
                                      const Icon(Icons.feedback, color: Colors.black, size: 30),
                                      const SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Give us some feedback',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            'Help us make a better service',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.chevron_right, color: Colors.red),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(color: Colors.grey[300], thickness: 1, indent: 20, endIndent: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const RidingHistoryScreen()),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 10),
                                      const Icon(Icons.history, color: Colors.black, size: 30),
                                      const SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Riding history',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.chevron_right, color: Colors.red),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(color: Colors.grey[300], thickness: 1, indent: 20, endIndent: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    // Navigate to FAQs (placeholder)
                                  },
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 10),
                                      const Icon(Icons.help, color: Colors.black, size: 30),
                                      const SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'FAQs',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.chevron_right, color: Colors.red),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 520,
                        left: 45,
                        child: Text(
                          'App version juscooter-1.0',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey[300]!.withAlpha(51),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(26),
                                blurRadius: 8.0,
                                spreadRadius: 2.0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.home),
                                onPressed: () {},
                                color: Colors.blue,
                              ),
                              IconButton(
                                icon: const Icon(Icons.payment),
                                onPressed: () {},
                                color: Colors.blue,
                              ),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [Color(0xFF00FF00), Color(0xFFFF0000)],
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(Icons.qr_code, color: Colors.white),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.directions_bike),
                                onPressed: () {},
                                color: Colors.blue,
                              ),
                              IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: () {},
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

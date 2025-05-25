import 'package:flutter/material.dart';
import 'package:ju_scooter/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  // دالة لفتح Google Form
  Future<void> _launchContactForm() async {
    final Uri url = Uri.parse('https://forms.gle/9zCPRS93BeW8VY6X8');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 90,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF012D37),
                  Color(0xFF635E5B),
                  Color(0xFF001637),
                ],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 45,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 45),
                    child: const Text(
                      'Help',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Card with content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Still need help?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Send us a message and we will find the best way to support you',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF9B9B9B),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Contact support button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _launchContactForm,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF012D37),
                                Color(0xFF635E5B),
                                Color(0xFF001637),
                              ],
                              stops: [0.0, 0.5, 1.0],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Container(
                            height: 52,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.support_agent, color: Colors.white, size: 26),
                                const SizedBox(width: 12),
                                const Text(
                                  'Contact support',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // FAQs
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFE9E9E9), width: 1),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F0F3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.help_outline,
                            color: Color(0xFF012D37),
                            size: 22,
                          ),
                        ),
                        title: const Text(
                          'FAQs',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFF012D37), size: 28),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('FAQs tapped')),
                          );
                        },
                      ),
                    ),
                    // Riding Guide
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFE9E9E9), width: 1),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F0F3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.electric_scooter,
                            color: Color(0xFF012D37),
                            size: 22,
                          ),
                        ),
                        title: const Text(
                          'Riding Guide',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFF012D37), size: 28),
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(initialTab: 3), // 3 هو رقم تاب Riding Guide
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Phone Image with Chat
          const SizedBox(height: 50),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Image.network(
                'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/menu%2Fundraw_chatting_2b1g%201.png?alt=media&token=ec0d1abf-c60d-4e07-b52c-dce99a5c12f8',
                width: 300,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Error loading image'));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
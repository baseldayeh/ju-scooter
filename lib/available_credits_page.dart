import 'package:flutter/material.dart';

class AvailableCreditsPage extends StatelessWidget {
  const AvailableCreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back arrow
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF50FDD5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF50FDD5), Color(0xFF00D9FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // صورة البطاقة
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Image.network(
                        "https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/payment%2FGroup%2073.png?alt=media&token=ea611a86-a9df-4e8f-be69-601f923caaef",
                        width: 110,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                    // النصوص
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "AVAILABLE CREDITS",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            "\$ 0.00",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Active & History
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _UnderlineButton(text: "Active"),
                  _UnderlineButton(text: "History"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnderlineButton extends StatelessWidget {
  final String text;
  const _UnderlineButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF00D9FF),
            fontSize: 22,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.underline,
            decorationColor: Color(0xFF00D9FF),
            decorationThickness: 2,
          ),
        ),
      ],
    );
  }
}
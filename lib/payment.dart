import 'package:flutter/material.dart';
import 'promo_code.dart';
import 'add_card_page.dart'; // تأكد أن اسم الملف صحيح
import 'available_credits_page.dart';

class PaymentContent extends StatelessWidget {
  const PaymentContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Header بتدرج اللون بدون صورة
          Container(
            height: 30,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF50FDD5),
                  Color(0xFF1BFEE3),
                  Color(0xFF00D9FF),
                ],
                stops: [0.0, 0.48, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // المحتوى الرئيسي
          Stack(
            children: [
              // الصورة الأولى (مستقلة)
              Positioned(
                top: 50,
                left: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AvailableCreditsPage()),
                    );
                  },
                  child: Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/payment%2FGroup%2073.png?alt=media&token=ea611a86-a9df-4e8f-be69-601f923caaef',
                    height: 203,
                    width: 350,
                  ),
                ),
              ),
              // نص $0.00 (مستقل)
              Positioned(
                top: 123,
                left: 32,
                child: const Text(
                  '\$ 0.00',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
              // صورة VISA (مستقلة)
              Positioned(
                top: 305,
                left: 20,
                child: Image.network(
                  'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/payment%2Fimage%2011.png?alt=media&token=aaad7993-df44-470b-a361-aac0b719f7d5',
                  height: 18,
                  width: 20,
                ),
              ),
              // صورة MasterCard (مستقلة)
              Positioned(
                top: 305,
                left: 40,
                child: Image.network(
                  'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/payment%2Fimage%2012.png?alt=media&token=1ffc7f80-2def-48a4-8f2a-1beb1cfb887b',
                  height: 18,
                  width: 30,
                ),
              ),
              // الجزء الرئيسي من الصفحة
              Padding(
                padding: const EdgeInsets.only(top: 270, left: 16.0, right: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment method',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      height: 60,
                      alignment: Alignment.center,
                      child: const Text(
                        'You can also add payment method to pay for every ride',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 0),
                    // زر إضافة وسيلة دفع (Add payment method)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddCardPage()),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 0, left: 0),
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, color: Color(0xFF00D9FF), size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Add payment method',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF00D9FF),
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios, color: Color(0xFF00D9FF), size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Promotion',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PromoCodePage()),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 5, left: 0),
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.percent, color: Color(0xFF00D9FF), size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Add credit code / gift card',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF00D9FF),
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios, color: Color(0xFF00D9FF), size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
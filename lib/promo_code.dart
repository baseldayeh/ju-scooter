import 'package:flutter/material.dart';

class PromoCodePage extends StatefulWidget {
  const PromoCodePage({super.key});

  @override
  PromoCodePageState createState() => PromoCodePageState();
}

class PromoCodePageState extends State<PromoCodePage> {
  final FocusNode _promoCodeFocusNode = FocusNode();

  // ألوان للحقل
  static const Color gradientColor1 = Color(0xFF50FDD5);
  static const Color gradientColor2 = Color(0xFF00D9FF);
  final Color defaultBorderColor = Colors.grey;
  final Color defaultLabelColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _promoCodeFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _promoCodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Header بلون أبيض فقط
          Container(
            height: 30,
            color: Colors.white,
          ),
          // الصورة بموقع محدد
          Positioned(
            top: 60,
            left: -30,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.network(
                'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/payment%2FGroup%2073%20(1).png?alt=media&token=ce207514-242c-4996-9ec1-d44026f9f5b4',
                height: 50,
                width: 100,
              ),
            ),
          ),
          // المحتوى الفرعي
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 160), // حتى لا تتداخل مع الصورة
                const Text(
                  'Promo code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                _buildPromoCodeField(
                  label: 'Enter promo code',
                  focusNode: _promoCodeFocusNode,
                  defaultBorderColor: defaultBorderColor,
                  defaultLabelColor: defaultLabelColor,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // يمكنك إضافة منطق الادّعاء هنا لاحقًا
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF50FDD5),
                            Color(0xFF00D9FF),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: const Center(
                        child: Text(
                          'Claim',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
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
        ],
      ),
    );
  }

  Widget _buildPromoCodeField({
    required String label,
    required FocusNode focusNode,
    required Color defaultBorderColor,
    required Color defaultLabelColor,
  }) {
    final bool hasFocus = focusNode.hasFocus;
    final Color currentLabelColor = hasFocus ? gradientColor2 : defaultLabelColor;

    return TextFormField(
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: currentLabelColor, fontSize: 14),
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: defaultBorderColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(
            width: 1.0,
            color: hasFocus
                ? Colors.transparent // للسماح للتدرج بالظهور
                : defaultBorderColor,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(
            width: 1.0,
            color: hasFocus
                ? Colors.transparent
                : defaultBorderColor,
          ),
        ),
        floatingLabelStyle: TextStyle(
          color: currentLabelColor,
          fontSize: 14,
          backgroundColor: Colors.white,
        ),
        prefixStyle: const TextStyle(color: Colors.black87),
      ),
      style: const TextStyle(color: Colors.black87),
      cursorColor: gradientColor2,
    );
  }
}
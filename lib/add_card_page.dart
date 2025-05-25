import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final FocusNode _cardNumberFocus = FocusNode();
  final FocusNode _expiryFocus = FocusNode();
  final FocusNode _cvvFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();

  final Color labelColor = const Color(0xFFA8A8A8);
  final Color focusColor = Color(0xFF00D9FF);
  final Color borderColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _cardNumberFocus.addListener(() => setState(() {}));
    _expiryFocus.addListener(() => setState(() {}));
    _cvvFocus.addListener(() => setState(() {}));
    _nameFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _cardNumberFocus.dispose();
    _expiryFocus.dispose();
    _cvvFocus.dispose();
    _nameFocus.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double verticalPadding = 18;
    final double fieldSpacing = 18;
    final double fieldRadius = 15;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // مهم جداً لجعل كل شيء ثابت
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back arrow
              GestureDetector(
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
              const SizedBox(height: 24),
              const Text(
                "Add your credit or debit card",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _CustomTextField(
                      controller: cardNumberController,
                      label: "Card number",
                      focusNode: _cardNumberFocus,
                      labelColor: labelColor,
                      focusColor: focusColor,
                      borderColor: borderColor,
                      radius: fieldRadius,
                      verticalPadding: verticalPadding,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    SizedBox(height: fieldSpacing),
                    Row(
                      children: [
                        Expanded(
                          child: _CustomTextField(
                            controller: expiryController,
                            label: "MM/YY",
                            focusNode: _expiryFocus,
                            labelColor: labelColor,
                            focusColor: focusColor,
                            borderColor: borderColor,
                            radius: fieldRadius,
                            verticalPadding: verticalPadding,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              ValidExpiryDateTextInputFormatter(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CustomTextField(
                            controller: cvvController,
                            label: "CVV",
                            focusNode: _cvvFocus,
                            labelColor: labelColor,
                            focusColor: focusColor,
                            borderColor: borderColor,
                            radius: fieldRadius,
                            verticalPadding: verticalPadding,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: fieldSpacing),
                    _CustomTextField(
                      controller: nameController,
                      label: "Full name",
                      focusNode: _nameFocus,
                      labelColor: labelColor,
                      focusColor: focusColor,
                      borderColor: borderColor,
                      radius: fieldRadius,
                      verticalPadding: verticalPadding,
                      keyboardType: TextInputType.name,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Image.network(
                  "https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/payment%2Fundraw_mobile-pay_yho9%201.png?alt=media&token=31d93d23-4a04-4b63-9667-d375fffa7d05",
                  height: 190,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // منطق الحفظ هنا
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF50FDD5), Color(0xFF00D9FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  "Your card details are secure",
                  style: TextStyle(
                    color: Color(0xFF1BFEE3),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final FocusNode focusNode;
  final Color labelColor;
  final Color focusColor;
  final Color borderColor;
  final double radius;
  final double verticalPadding;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.focusNode,
    required this.labelColor,
    required this.focusColor,
    required this.borderColor,
    required this.radius,
    required this.verticalPadding,
    required this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasFocus = focusNode.hasFocus;
    final Color currentLabelColor = hasFocus ? focusColor : labelColor;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: currentLabelColor, fontSize: 16),
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 18),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: verticalPadding),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: borderColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: focusColor, width: 1.0),
        ),
        floatingLabelStyle: TextStyle(
          color: currentLabelColor,
          fontSize: 16,
          backgroundColor: Colors.white,
        ),
      ),
      style: const TextStyle(color: Colors.black87, fontSize: 18),
    );
  }
}

// فورماتر لتنسيق MM/YY مع منع شهور غير منطقية
class ValidExpiryDateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll('/', '');
    if (text.length > 4) text = text.substring(0, 4);

    String newText = '';
    if (text.isNotEmpty) {
      // أول رقم للشهر
      if (int.tryParse(text[0]) == null || int.parse(text[0]) > 1) {
        return oldValue;
      }
      newText += text[0];
    }
    if (text.length >= 2) {
      // ثاني رقم للشهر
      int month = int.parse(text.substring(0, 2));
      if (month < 1 || month > 12) {
        return oldValue;
      }
      newText += text[1];
      newText += '/';
    }
    if (text.length > 2) {
      newText += text.substring(2);
    }
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
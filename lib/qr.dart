import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ju_scooter/session_manager.dart';
import 'package:ju_scooter/utils/logger.dart';

class QrContent extends StatefulWidget {
  const QrContent({super.key});

  @override
  State<QrContent> createState() => _QrContentState();
}

class _QrContentState extends State<QrContent> {
  final TextEditingController _serialController = TextEditingController();
  String? _scannedSerial;

  @override
  void dispose() {
    _serialController.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    try {
      AppLogger.info('Checking camera permission status...');
      var status = await Permission.camera.status;
      AppLogger.info('Initial camera permission status: $status');

      if (!status.isGranted) {
        AppLogger.info('Camera permission not granted, requesting...');
        status = await Permission.camera.request();
        AppLogger.info('Camera permission request result: $status');
      }

      if (status.isGranted) {
        AppLogger.info('Camera permission granted, starting scan...');
        await _scanQRCode();
      } else if (status.isDenied) {
        AppLogger.warn('Camera permission denied by user');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required to scan QR codes. Please allow access.'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else if (status.isPermanentlyDenied) {
        AppLogger.warn('Camera permission permanently denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Camera permission is permanently denied. Please enable it in app settings.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () async {
                  AppLogger.info('Opening app settings...');
                  await openAppSettings();
                  final newStatus = await Permission.camera.status;
                  AppLogger.info('Camera permission after settings: $newStatus');
                  if (newStatus.isGranted && mounted) {
                    await _scanQRCode();
                  }
                },
              ),
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        AppLogger.warn('Camera permission status: $status');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unexpected camera permission status: $status')),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error requesting camera permission: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error requesting camera permission: $e')),
        );
      }
    }
  }

  Future<void> _scanQRCode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty && mounted) {
        setState(() {
          _scannedSerial = result.rawContent;
        });
        await _verifyScooterSerial(_scannedSerial!);
      }
    } catch (e) {
      AppLogger.error('Error scanning QR code: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning QR code: $e')),
        );
      }
    }
  }

  Future<void> _verifyScooterSerial(String serial) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No authenticated user found')),
        );
        return;
      }

      final scooterDoc = await firestore.collection('scooters').doc(serial).get();
      if (!scooterDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid scooter serial number: $serial')),
        );
        return;
      }

      final scooterData = scooterDoc.data()!;
      if (scooterData['status'] != 'available') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scooter is not available for rent')),
        );
        return;
      }

      await firestore.collection('scooters').doc(serial).update({
        'status': 'rented',
        'rented_by': user.uid,
        'rental_start': FieldValue.serverTimestamp(),
      });

      Map<String, dynamic> sessionData = await SessionManager.getSessionData();
      sessionData['scooter_id'] = serial;
      sessionData['rental_start'] = DateTime.now().toIso8601String();
      await SessionManager.setActiveSession(userData: sessionData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scooter $serial rented successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      AppLogger.error('Error verifying scooter serial: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  LinearGradient get _mainGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF43E97B), // أخضر مزرق
      Color(0xFF38F9D7), // تركواز
      Color(0xFF08AEEA), // أزرق فاتح
      Color(0xFF2F80ED), // أزرق متوسط
    ],
    stops: [0.0, 0.5, 0.8, 1.0],
  );

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
              decoration: BoxDecoration(
                gradient: _mainGradient,
              ),
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: const Text(
                      'Scan QR Code',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 250,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _serialController,
                    decoration: InputDecoration(
                      labelText: 'Enter Scooter Serial Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      final serial = _serialController.text.trim();
                      if (serial.isNotEmpty) {
                        _verifyScooterSerial(serial);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a serial number')),
                        );
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
                        gradient: _mainGradient,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    await _requestCameraPermission();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.qr_code_scanner, color: Color(0xFF2F80ED), size: 26),
                      SizedBox(width: 8),
                      Text(
                        'or Scan QR Code',
                        style: TextStyle(
                          color: Color(0xFF2F80ED),
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
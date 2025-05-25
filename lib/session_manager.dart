import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:developer' show log;
import 'dart:convert'; // إضافة مكتبة لتحويل JSON

class SessionManager {
  static const String _sessionKey = 'active_session';
  static const String _lastActivityKey = 'last_activity';
  static const String _rememberMeKey = 'remember_me';
  static const String _userDataKey = 'user_data';
  static const int _sessionTimeoutMinutes = 1440;
  static const _storage = FlutterSecureStorage();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تخزين بيانات الجلسة مع بيانات المستخدم
  static Future<void> setActiveSession({required Map<String, dynamic> userData}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, true);
    await prefs.setInt(_lastActivityKey, DateTime.now().millisecondsSinceEpoch ~/ 1000);
    await prefs.setString(_rememberMeKey, userData['email'] ?? '');
    await prefs.setString(_userDataKey, jsonEncode(userData)); // استخدام JSON لتخزين البيانات
    await _storage.write(key: 'email', value: userData['email']);
    if (userData.containsKey('password')) {
      await _storage.write(key: 'password', value: userData['password']);
    }
  }

  // استرجاع بيانات الجلسة مع بيانات المستخدم
  static Future<Map<String, dynamic>> getSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    bool isActive = prefs.getBool(_sessionKey) ?? false;
    if (!isActive) return {};

    int? lastActivity = prefs.getInt(_lastActivityKey);
    if (lastActivity == null) {
      await clearSession();
      return {};
    }

    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int timeElapsed = currentTime - lastActivity;
    if (timeElapsed >= (_sessionTimeoutMinutes * 60)) {
      await clearSession();
      return {};
    }

    String? userDataString = prefs.getString(_userDataKey);
    if (userDataString == null) return {};

    try {
      return jsonDecode(userDataString) as Map<String, dynamic>; // فك تشفير JSON
    } catch (e) {
      log('Error decoding user data: $e');
      return {};
    }
  }

  // تحديث آخر نشاط
  static Future<void> updateLastActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastActivityKey, DateTime.now().millisecondsSinceEpoch ~/ 1000);
  }

  // مسح الجلسة
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_lastActivityKey);
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_userDataKey);
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'password');
    await FirebaseAuth.instance.signOut();
  }

  // تحقق من وجود جلسة نشطة مع تحميل بيانات المستخدم
  static Future<bool> hasActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool isActive = prefs.getBool(_sessionKey) ?? false;
      if (!isActive) return false;

      int? lastActivity = prefs.getInt(_lastActivityKey);
      if (lastActivity == null) {
        await clearSession();
        return false;
      }

      int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      int timeElapsed = currentTime - lastActivity;
      if (timeElapsed >= (_sessionTimeoutMinutes * 60)) {
        await clearSession();
        return false;
      }

      String? storedEmail = await _storage.read(key: 'email');
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        user = FirebaseAuth.instance.currentUser;
        if (user != null && user.emailVerified && storedEmail == user.email) {
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
          if (userDoc.exists) {
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            await setActiveSession(userData: userData);
            return true;
          }
        }
      }
      await clearSession();
      return false;
    } catch (e) {
      log('Error checking session: $e');
      return false;
    }
  }
}
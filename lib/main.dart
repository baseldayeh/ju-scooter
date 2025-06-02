import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'tutorial.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'verify_email.dart';
import 'home_screen.dart';
import 'utils/logger.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart';
import 'session_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Placeholder for UnknownScreen
class UnknownScreen extends StatelessWidget {
  const UnknownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unknown Route')),
      body: const Center(child: Text('Page not found')),
    );
  }
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    runApp(const MyApp());
  }, (error, stackTrace) {
    AppLogger.error('Caught error: $error', error, stackTrace);
  });

  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error('Flutter error: ${details.exception}', details.exception, details.stack);
  };
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final Color gradientTop = const Color(0xFF80F1B3);
  final Color gradientBottom = const Color(0xFF26D1A4);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _preloadImages();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      AppLogger.info('[AppLifecycle] App resumed');
    }
  }

  Future<void> _preloadImages() async {
    // URLs للصور من Firebase Storage (استبدلها بـ URLs الفعلية)
    const imageUrls = [
      'https://firebasestorage.googleapis.com/v0/b/your-project-id.appspot.com/o/images%2Fbackground_image.png?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/your-project-id.appspot.com/o/images%2Fbackground_image_2.png?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/your-project-id.appspot.com/o/images%2Fbackground_image_3.png?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/your-project-id.appspot.com/o/images%2Fbackground_image_4.png?alt=media',
    ];

    for (final url in imageUrls) {
      bool loaded = false;
      int attempts = 0;
      const maxAttempts = 3;
      while (!loaded && attempts < maxAttempts) {
        try {
          if (!mounted) return;
          final imageProvider = CachedNetworkImageProvider(url);
          await precacheImage(imageProvider, context);
          loaded = true;
        } catch (e, stackTrace) {
          attempts++;
          AppLogger.error('Failed to preload image: $url (attempt $attempts)', e, stackTrace);
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }
  }

  Future<String> _getInitialRoute() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
      bool rememberMe = prefs.getBool('remember_me') ?? false;

      if (isFirstLaunch) {
        await prefs.setBool('is_first_launch', false);
        return '/tutorial';
      }

      User? user = FirebaseAuth.instance.currentUser;
      bool hasSession = await SessionManager.hasActiveSession();

      if (user != null && (rememberMe && hasSession)) {
        try {
          await user.reload();
          user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            if (user.emailVerified) {
              return '/home';
            } else {
              final tempEmail = prefs.getString('temp_email');
              if (tempEmail == user.email) {
                return '/verify-email';
              }
            }
          }
        } catch (e, stackTrace) {
          AppLogger.error('Error reloading user: $e', e, stackTrace);
          await SessionManager.clearSession();
        }
      } else {
        await SessionManager.clearSession();
      }
      return '/login';
    } catch (e, stackTrace) {
      AppLogger.error('Error determining initial route: $e', e, stackTrace);
      await SessionManager.clearSession();
      return '/login';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: SplashScreen(
              gradientTop: gradientTop,
              gradientBottom: gradientBottom,
            ),
            locale: const Locale('en', 'US'),
            supportedLocales: const [Locale('en', 'US')],
          );
        }

        String initialRoute = snapshot.data ?? '/login';
        return buildModifiedAppContent(initialRoute);
      },
    );
  }

  Widget buildModifiedAppContent(String initialRoute) {
    final Map<String, WidgetBuilder> appRoutes = {
      '/tutorial': (context) => const OnboardingScreen(),
      '/login': (context) => const SignInScreen(),
      '/signup': (context) => const SignUpScreen(),
      '/verify-email': (context) => const VerifyEmailScreen(),
      '/home': (context) => const HomeScreen(),
      '/edit-profile': (context) => const EditProfileScreen(),
    };

    Widget initialScreen;
    if (initialRoute == '/') {
      initialScreen = const SignUpScreen();
    } else if (appRoutes.containsKey(initialRoute)) {
      initialScreen = appRoutes[initialRoute]!(context);
    } else {
      initialScreen = const SignInScreen();
    }

    return MaterialApp(
      title: 'ju_scooter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: const TextTheme().apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
      ),
      home: initialScreen,
      locale: const Locale('en', 'US'),
      supportedLocales: const [Locale('en', 'US')],
      routes: appRoutes,
      onGenerateRoute: (settings) {
        final String? name = settings.name;
        final WidgetBuilder? pageContentBuilder = appRoutes[name];

        if (pageContentBuilder != null) {
          return MaterialPageRoute<dynamic>(
            settings: settings,
            builder: pageContentBuilder,
          );
        }

        AppLogger.warn('Navigating to unknown route: ${settings.name}');
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (context) => const UnknownScreen(),
        );
      },
      onUnknownRoute: (settings) {
        AppLogger.warn('Navigating to unknown route: ${settings.name}');
        return MaterialPageRoute(builder: (context) => const UnknownScreen());
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  final Color gradientTop;
  final Color gradientBottom;

  const SplashScreen({
    super.key,
    required this.gradientTop,
    required this.gradientBottom,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [gradientTop, gradientBottom],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(screenSize.width * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(230),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_outline,
                  size: screenSize.width * 0.18,
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: screenSize.height * 0.02),
              const Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

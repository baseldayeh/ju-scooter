import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/logger.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Removed SystemChrome calls since they're handled in main.dart
  }

  @override
  void dispose() {
    try {
      _pageController.dispose();
    } catch (e, stackTrace) {
      AppLogger.error('Error in dispose: $e', e, stackTrace);
    }
    super.dispose();
  }

  void _onPopInvokedWithResult(bool didPop, dynamic result) {
    if (didPop) return; // If the pop was already handled, do nothing
    if (_currentPage == 0) {
      // If on the first page, exit the app completely
      try {
        SystemNavigator.pop();
      } catch (e, stackTrace) {
        AppLogger.error('Error while exiting app: $e', e, stackTrace);
      }
    } else {
      // If on a later page, go to the previous page
      try {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } catch (e, stackTrace) {
        AppLogger.error('Error while navigating to previous page: $e', e, stackTrace);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // We handle the pop manually in onPopInvokedWithResult
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                buildOnboardingPage(0),
                buildOnboardingPage(1),
                buildOnboardingPage(2),
                buildOnboardingPage(3),
              ],
            ),
            // زر Skip يظهر فقط إذا لم يكن المستخدم في الصفحة الرابعة
            if (_currentPage < 3)
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                right: 20,
                child: SizedBox(
                  width: 74,
                  height: 35,
                  child: TextButton(
                    onPressed: () {
                      _pageController.jumpToPage(3);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF4DFAAF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Color(0xFF5F5A5A),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 29),
                    child: Transform.translate(
                      offset: const Offset(0, -19),
                      child: Row(
                        children: List.generate(4, (index) {
                          return SizedBox(
                            width: 35,
                            height: 7,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? const Color(0xFF4DFAAF)
                                    : Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(500),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: _currentPage == 3
                        ? Transform.translate(
                            offset: const Offset(0, -19),
                            child: SizedBox(
                              width: 90,
                              height: 45,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/login',
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF4DFAAF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "lets go",
                                  style: TextStyle(
                                    color: Color(0xFF5F5A5A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Transform.translate(
                            offset: const Offset(0, -19),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF4DFAAF),
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Material(
                                    color: const Color(0xFF4DFAAF),
                                    shape: const CircleBorder(),
                                    child: IconButton(
                                      onPressed: () {
                                        if (_currentPage < 3) {
                                          _pageController.nextPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 24,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOnboardingPage(int pageIndex) {
    String title;
    String description;
    TextStyle titleStyle;
    TextStyle descriptionStyle;
    double horizontalPadding;
    double spaceAfterDescription;

    const Color titleColor = Color(0xFF4DFAAF);
    const Color descriptionColor = Color(0xFF5F5A5A);

    switch (pageIndex) {
      case 0:
        title = 'User-Friendly and Simple';
        description = '"With a few taps on your phone, you can book and start your ride in seconds."';
        titleStyle = const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: titleColor);
        descriptionStyle = const TextStyle(fontSize: 16, color: descriptionColor, height: 1.5);
        horizontalPadding = 40.0;
        spaceAfterDescription = 75.0;
        break;
      case 1:
        title = 'Convenient Parking Locations';
        description = '"Find parking spots near key areas like lecture halls, libraries, and campus cafes, making it easy to save your time and make your commute easy."';
        titleStyle = const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: titleColor);
        descriptionStyle = const TextStyle(fontSize: 15, color: descriptionColor, height: 1.5);
        horizontalPadding = 15.0;
        spaceAfterDescription = 85.0;
        break;
      case 2:
        title = 'Sustainability and On-Campus Charging';
        description = '"We collaborate with the University of Jordan to provide solar-powered charging stations, promoting eco-friendly mobility and campus progress."';
        titleStyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: titleColor);
        descriptionStyle = const TextStyle(fontSize: 15, color: descriptionColor, height: 1.4);
        horizontalPadding = 15.0;
        spaceAfterDescription = 88.0;
        break;
      case 3:
        title = 'Convenient Access During Exams';
        description = '"Exam season? No worries! Our scooters are always available to help you move quickly between faculties and university buildings."';
        titleStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: titleColor);
        descriptionStyle = const TextStyle(fontSize: 15, color: descriptionColor, height: 1.5);
        horizontalPadding = 15.0;
        spaceAfterDescription = 100.0;
        break;
      default:
        title = 'Default Title';
        description = 'Default description text.';
        titleStyle = const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: titleColor);
        descriptionStyle = const TextStyle(fontSize: 16, color: descriptionColor, height: 1.5);
        horizontalPadding = 40.0;
        spaceAfterDescription = 75.0;
        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(77, 250, 175, 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.electric_scooter, size: 100, color: Color(0xFF4DFAAF)),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, textAlign: TextAlign.center, style: titleStyle),
                    const SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Text(description, textAlign: TextAlign.center, style: descriptionStyle),
                    ),
                    SizedBox(height: spaceAfterDescription),
                  ],
                ),
              ),
            ),
          ],
        );
    }

    return Stack(
      children: [
        if (pageIndex == 0)
          Positioned(
            top: 50,
            right: -5,
            child: Image.asset('assets/background_image.png', width: 400, height: 483, fit: BoxFit.contain),
          )
        else if (pageIndex == 1)
          Positioned(
            top: 50,
            right: -5,
            child: Image.asset('assets/background_image_2.png', width: 400, height: 483, fit: BoxFit.contain),
          )
        else if (pageIndex == 2)
          Positioned(
            top: 50,
            right: -5,
            child: Image.asset('assets/background_image_3.png', width: 400, height: 483, fit: BoxFit.contain),
          )
        else if (pageIndex == 3)
          Positioned(
            top: 50,
            right: -5,
            child: Image.asset('assets/background_image_4.png', width: 400, height: 483, fit: BoxFit.contain),
          )
        else
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(77, 250, 175, 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.electric_scooter, size: 100, color: Color(0xFF4DFAAF)),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, textAlign: TextAlign.center, style: titleStyle),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(description, textAlign: TextAlign.center, style: descriptionStyle),
                ),
                SizedBox(height: spaceAfterDescription),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
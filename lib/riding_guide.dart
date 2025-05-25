import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logger/logger.dart';


class RidingGuideContent extends StatelessWidget {
  RidingGuideContent({super.key});

  // URLs للصور في Firebase Storage
  final String zoneGuideUrl = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/images%2Fgis_map-route.png?alt=media&token=93dbd438-5f0c-4eb7-b824-36ccbaa4a520';
  final String zoneGuideUrl1 = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/images%2Friding_zone.png?alt=media&token=afb4016e-66c8-45a3-8dd7-c20bf6bec4a3';
  final String howToRideUrl = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/images%2Fs1.png?alt=media&token=19e41f74-6b8f-4132-871e-c753d0d7a0b1';
  final String safetyVideosUrl = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/images%2Fbxs_videos.png?alt=media&token=68703150-c698-4465-9fb3-d1b6d7565c92';
  final String userGuidelinesUrl = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/images%2Foui_documentation.png?alt=media&token=a6a278e3-79f8-432a-b8ae-f24fbd014618';
  final String newImageUrl = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/images%2FGroup.png?alt=media&token=dba15e6b-d0c3-459f-b3fe-8bd37284ce6c';
  final String page1ScooterUrl = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/images%2F3.gif?alt=media&token=6b762538-fb66-4557-8fac-54e975e7ca5d';
  final String page1QrPhoneUrl = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/images%2FGroup%2067%20(1).png?alt=media&token=1d1d80d8-8d72-4a83-9660-804196f2ef82';
  final String page2ImageUrl = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/images%2F2%20(2).gif?alt=media&token=41998771-7ade-4373-afcc-794b6d7206c2'; // استبدل token
  final String page3ImageUrl = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/images%2FABSTRACT%20BACKGROUND.gif?alt=media&token=d81be175-f222-48d4-8868-a24d3da004cb'; // استبدل token
  final String page4ImageUrl = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/images%2F41.gif?alt=media&token=c53e26da-9695-4e6f-9c60-bbad2e0da471'; // استبدل token
  final String page5ImageUrl = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/images%2F5.gif?alt=media&token=704a607b-7d9b-4d05-9446-26729f4f5529'; // استبدل token

  // رابط قناة YouTube
  final String youtubeChannelUrl = 'https://www.youtube.com/channel/UCm3FNpjgHT6WcerrnJThiPQ';

  // متغيرات للتحكم في الارتفاع والزوايا الدائرية والموضع العمودي
  final double getStartedHeight = 120.0;
  final double containerBorderRadius = 20.0;
  final double getStartedVerticalOffset = 10.0;

  // إعداد Logger لاستبدال print
  final Logger _logger = Logger();

  // دالة لفتح رابط YouTube
  Future<void> _launchYouTubeChannel() async {
    final Uri url = Uri.parse(youtubeChannelUrl);
    if (await canLaunchUrl(url)) {
      try {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );
      } catch (e) {
        _logger.e('Error launching URL: $e');
      }
    } else {
      _logger.w('Could not launch $url. Check the URL or permissions.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 40,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF012D37), Color(0xFF635E5B), Color(0xFF001637)],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                SizedBox(height: getStartedVerticalOffset),
                const Text(
                  'Get started',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Container(
                  height: getStartedHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(containerBorderRadius),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: howToRideUrl,
                            width: 24,
                            height: 24,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                          title: const Text('How to ride scooters'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HowToRidePage(
                                  page1ScooterUrl: page1ScooterUrl,
                                  page1QrPhoneUrl: page1QrPhoneUrl,
                                  page2ImageUrl: page2ImageUrl,
                                  page3ImageUrl: page3ImageUrl,
                                  page4ImageUrl: page4ImageUrl,
                                  page5ImageUrl: page5ImageUrl,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(height: 1, color: Colors.grey),
                      Expanded(
                        child: ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: zoneGuideUrl,
                            width: 24,
                            height: 24,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                          title: const Text('Zone guide'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ZoneGuidePage(imageUrl: zoneGuideUrl1),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                const Text(
                  'Learn safe riding',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(containerBorderRadius),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: userGuidelinesUrl,
                          width: 24,
                          height: 24,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                        title: const Text('User Guidelines'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(height: 1, color: Colors.grey),
                      ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: safetyVideosUrl,
                          width: 24,
                          height: 24,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                        title: const Text('Safety Videos'),
                        trailing: CachedNetworkImage(
                          imageUrl: newImageUrl,
                          width: 20,
                          height: 20,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                        onTap: () {
                          _launchYouTubeChannel();
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
                  color: Colors.grey,
                ),
                IconButton(
                  icon: const Icon(Icons.payment),
                  onPressed: () {},
                  color: Colors.grey,
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF012D37), Color(0xFF635E5B), Color(0xFF001637)],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.qr_code, color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.directions_bike),
                  onPressed: () {},
                  color: Colors.grey,
                ),
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {},
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ZoneGuidePage extends StatelessWidget {
  final String imageUrl;

  const ZoneGuidePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 40,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF012D37), Color(0xFF635E5B), Color(0xFF001637)],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF012D37), Color(0xFF635E5B), Color(0xFF001637)],
                  stops: [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  elevation: 0,
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HowToRidePage extends StatefulWidget {
  final String page1ScooterUrl;
  final String page1QrPhoneUrl;
  final String page2ImageUrl;
  final String page3ImageUrl;
  final String page4ImageUrl;
  final String page5ImageUrl;

  const HowToRidePage({
    super.key,
    required this.page1ScooterUrl,
    required this.page1QrPhoneUrl,
    required this.page2ImageUrl,
    required this.page3ImageUrl,
    required this.page4ImageUrl,
    required this.page5ImageUrl,
  });

  @override
  State<HowToRidePage> createState() => _HowToRidePageState();
}

class _HowToRidePageState extends State<HowToRidePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPopInvokedWithResult(bool didPop, dynamic result) {
    if (didPop) return;
    if (_currentPage == 0) {
      SystemNavigator.pop();
    } else {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF012D37), Color(0xFF635E5B), Color(0xFF001637)],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      // الصفحة الأولى
                      Stack(
                        children: [
                          Positioned(
                            top: 180.0,
                            left: -50.0,
                            child: SizedBox(
                              width: 500.0,
                              height: 300.0,
                              child: CachedNetworkImage(
                                imageUrl: widget.page1ScooterUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 100.0,
                            left: 150.0,
                            child: SizedBox(
                              width: 100.0,
                              height: 100.0,
                              child: CachedNetworkImage(
                                imageUrl: widget.page1QrPhoneUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 470.0,
                            left: 0.0,
                            right: 0.0,
                            child: const Center(
                              child: Text(
                                'How to unlock',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 530.0,
                            left: 0.0,
                            right: 0.0,
                            child: const Center(
                              child: Text(
                                '"Use the map to find the scooter. Scan the QR code found on the handlebar. See invoice"',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 15, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // الصفحة الثانية
                      Stack(
                        children: [
                          Positioned(
                            top: 50.0,
                            left: -100.0,
                            child: SizedBox(
                              width: 600.0,
                              height: 400.0,
                              child: CachedNetworkImage(
                                imageUrl: widget.page2ImageUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 470.0,
                            left: 0.0,
                            right: 0.0,
                            child: const Center(
                              child: Text(
                                'Fold in the kickstand',
                                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 550.0,
                            left: 0.0,
                            right: 0.0,
                            child: const Center(
                              child: Text(
                                '"Fold the kickstand up before riding"',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 15, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // الصفحة الثالثة
                      Stack(
                        children: [
                          Positioned(
                            top: 50.0,
                            left: -100.0,
                            child: SizedBox(
                              width: 600.0,
                              height: 400.0,
                              child: CachedNetworkImage(
                                imageUrl: widget.page3ImageUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 470.0,
                            left: 0.0,
                            right: 0.0,
                            child: const Center(
                              child: Text(
                                'How to accelerate',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 530.0,
                            left: 0.0,
                            right: 0.0,
                            child: const Center(
                              child: Text(
                                '"After unlocking and Fold in, make sure to push off with your foot a few times to get speed rolling then press the ‘speed’ button"',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // الصفحة الرابعة
                      Stack(
                        children: [
                          Positioned(
                            top: 50.0,
                            left: -100.0,
                            child: SizedBox(
                              width: 600.0,
                              height: 400.0,
                              child: CachedNetworkImage(
                                imageUrl: widget.page4ImageUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 470.0,
                            left: 0.0,
                            right: 0.0,
                            child: const Center(
                              child: Text(
                                'How to Slow Down',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 530.0,
                            left: 0.0,
                            right: 0.0,
                            child: const Center(
                              child: Text(
                                '"to slow down while riding , gently press the brake instead of applying sudden force. This allows for a smooth reduction in speed while maintaining balance and control."',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // الصفحة الخامسة
                      Stack(
                        children: [
                          Positioned(
                            top: 100.0,
                            left: -50.0,
                            child: SizedBox(
                              width: 500.0,
                              height: 300.0,
                              child: CachedNetworkImage(
                                imageUrl: widget.page5ImageUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 470.0,
                            left: 0.0,
                            right: 0.0,
                            child: const Center(
                              child: Text(
                                'Park with thought',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 530.0,
                            left: 0.0,
                            right: 0.0,
                            child: const Center(
                              child: Text(
                                '"Park with others in mind and always follow local parking regulations,Make sure the vehicle dosen’t obstruct the path of pedestrians or other vehicles."',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Skip Button (hidden on page 5)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 20,
              child: _currentPage != 4 ? GestureDetector(
                onTap: () {
                  _pageController.jumpToPage(4);
                },
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF012D37), Color(0xFF635E5B), Color(0xFF001637)],
                    stops: [0.0, 0.5, 1.0],
                  ).createShader(bounds),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                      decorationThickness: 2.0,
                    ),
                  ),
                ),
              ) : const SizedBox.shrink(),
            ),
            // Dots and Next Button
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
                    child: Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.circle,
                          size: 10,
                          color: _currentPage == index ? Colors.black : Colors.grey,
                        );
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: _currentPage == 4
                        ? SizedBox(
                            width: 90,
                            height: 45,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [Color(0xFF012D37), Color(0xFF635E5B), Color(0xFF001637)],
                                  stops: [0.0, 0.5, 1.0],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'Got it',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50.0),
                              border: Border.all(
                                width: 2.0,
                                color: const Color(0xFF012D37),
                              ),
                            ),
                            child: SizedBox(
                              width: 90,
                              height: 45,
                              child: TextButton(
                                onPressed: () {
                                  if (_currentPage < 4) {
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                ),
                                child: const Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
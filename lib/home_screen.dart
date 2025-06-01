import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ju_scooter/session_manager.dart'; // الاستيراد المصحح
import 'payment.dart'; // استدعاء الملف المنفصل
import 'qr.dart'; // استدعاء الملف المنفصل
import 'riding_guide.dart'; // استدعاء الملف المنفصل
import 'menu.dart'; // استدعاء الملف المنفصل
import 'help.dart'; // استدعاء صفحة HelpScreen
import 'package:url_launcher/url_launcher.dart'; // أضف الاستيراد اللازم للروابط الخارجية

class HomeScreen extends StatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  final LatLng _center = const LatLng(32.0081779, 35.8733819);
  LatLng? _currentLocation;
  LatLng? _destination;
  List<LatLng> _routePoints = [];
  bool _isMapReady = false;
  final TextEditingController _searchController = TextEditingController();

  Set<Marker> _scooterMarkers = {};
  Set<Polygon> _geoZones = {};

  BitmapDescriptor? _scooterIcon;

  final String googleMapsApiKey = 'AIzaSyDDabYsD1xiAalFm7kdMcZ5hZgusXsGeCE';

  final double customTopBarHeight = 30.0;

  static const Color gradientColor1 = Color(0xFF00FF80);
  static const Color gradientColor2 = Color(0xFF65E5D0);
  static const Color gradientColor3 = Color(0xFF65E5D0);

  int _selectedIndex = 0;

  final double unselectedIconSize = 24.0;
  final double selectedIconSize = 30.0;
  final double fixedQrSize = 90.0;
  final double qrVerticalOffset = 20.0;

  final Color homeSelectedColor = const Color(0xFF00FF80);
  final Color paymentSelectedColor = const Color(0xFF50FDD5);
  final Color ridingGuideSelectedColor = const Color(0xFF012D37);
  final Color menuSelectedColor = const Color(0xFFED5021);
  final Color unselectedColor = Colors.grey;

  String? _profileImageUrl; // استخدام رابط الصورة مباشرة بدلاً من المسار المحلي

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      await _getCurrentLocation();
      await _loadCustomIcons();
      _defineGeoZones();
      _addDummyScooters();
      await _loadProfileImage();
    } catch (e, stackTrace) {
      debugPrint('Error during initState: $e');
      debugPrint(stackTrace.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing app: $e')),
        );
      }
    }
  }

  Future<void> _loadProfileImage() async {
    if (!mounted) return;
    Map<String, dynamic> sessionData = await SessionManager.getSessionData();
    String? imageUrl = sessionData['profile_image_url']?.toString();
    if (imageUrl != null && imageUrl.isNotEmpty) {
      setState(() {
        _profileImageUrl = imageUrl; // تحميل رابط الصورة مباشرة
      });
    } else {
      setState(() {
        _profileImageUrl = null;
      });
    }
  }

  void _updateProfileImage(String? imageUrl) {
    if (!mounted) return;
    if (imageUrl != null) {
      setState(() {
        _profileImageUrl = imageUrl;
      });
    } else {
      _loadProfileImage();
    }
  }

  Future<void> _loadCustomIcons() async {
    // ignore: deprecated_member_use
    _scooterIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: ui.Size(48, 48)), 'assets/scooter_icon.png');

    if (mounted) {
      setState(() {
        _addDummyScooters();
      });
    }
  }

  void _defineGeoZones() {
    const String zoneId = 'jordan_university_zone';
    final List<LatLng> zonePoints = [
      const LatLng(32.0200, 35.8400),
      const LatLng(32.0200, 35.8500),
      const LatLng(32.0100, 35.8500),
      const LatLng(32.0100, 35.8400),
      const LatLng(32.0200, 35.8400),
    ];

    final Polygon universityZone = Polygon(
      polygonId: const PolygonId(zoneId),
      points: zonePoints,
      strokeColor: Colors.blue.shade700,
      strokeWidth: 2,
      fillColor: Colors.blue.shade700.withValues(alpha: 0.2),
      consumeTapEvents: true,
      onTap: () {
        debugPrint('Tapped on University Zone');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tapped on University Zone')),
          );
        }
      },
    );

    if (mounted) {
      setState(() {
        _geoZones = {universityZone};
      });
    }
  }

  void _addDummyScooters() {
    // أصلح الخطأ في تعريف الخرائط: لا تضع ":" في اسم المفتاح
    final List<Map<String, dynamic>> dummyScooterLocations = [
      {'id': 'JES-HA-17-8939', 'lat': 32.0170, 'lng': 35.8460},
      {'id': 'JES-HA-17-8940', 'lat': 32.0150, 'lng': 35.8480},
      {'id': 'JES-HA-17-8941', 'lat': 32.0185, 'lng': 35.8440},
    ];

    Set<Marker> scooters = {};
    for (var scooterData in dummyScooterLocations) {
      final icon = _scooterIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);

      scooters.add(
        Marker(
          markerId: MarkerId(scooterData['id']),
          position: LatLng(scooterData['lat'], scooterData['lng']),
          icon: icon,
          infoWindow: InfoWindow(
            title: 'Scooter ${scooterData['id']}',
            snippet: 'Battery: 85%',
            onTap: () async {
              if (mounted) {
                _showScooterDetails(context, scooterData['id']);
              }
            },
          ),
          onTap: () {
            if (mounted) {
              _showScooterDetails(context, scooterData['id']);
            }
          },
        ),
      );
    }

    if (mounted) {
      setState(() {
        _scooterMarkers = scooters;
      });
    }
  }

  void _showScooterDetails(BuildContext context, String scooterId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // روابط الصور من Firebase
        const String visaUrl = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/payment%2Fimage%2012.png?alt=media&token=1ffc7f80-2def-48a4-8f2a-1beb1cfb887b';
        const String mcUrl = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/payment%2Fimage%2011.png?alt=media&token=aaad7993-df44-470b-a361-aac0b719f7d5';
        const String scooterImgUrl = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/payment%2Femojione_kick-scooter.jpg?alt=media&token=e42d09a3-47dc-4fbc-a4be-7000c45e1027';
        const String reportIconUrl = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/payment%2FVector%20(1).png?alt=media&token=852c48eb-f558-4e0f-ac21-08b1ea961966';
        const String speedIconUrl = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/payment%2FGroup.png?alt=media&token=5d09bf62-6493-40cd-9ba6-0652ba9a124b';
        const String reserveIconUrl = 'https://firebasestorage.googleapis.com/v0/b/ju-scooter.firebasestorage.app/o/payment%2FVector%20(2).png?alt=media&token=e1b82914-430f-4b24-91d9-b6095d30cb15';

        final String scooterNumber = scooterId;
        final int batteryPercent = 100;
        final String range = "20km";

        return Container(
          margin: const EdgeInsets.only(left: 18, right: 18, bottom: 0, top: 0), // 18px لكل جانب
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    scooterNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 2),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Image.network(visaUrl, width: 32, height: 20, fit: BoxFit.contain),
                    const SizedBox(width: 4),
                    Image.network(mcUrl, width: 32, height: 20, fit: BoxFit.contain),
                    const SizedBox(width: 8),
                    const Text(
                      "0.35 for 10 min",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "•",
                      style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "0.05/3 min",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.battery_full, color: Colors.green, size: 24),
                    const SizedBox(width: 6),
                    Text(
                      "$batteryPercent%,$range range",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Image.network(
                      scooterImgUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Reserve
                    GestureDetector(
                      onTap: () {
                        // يمكنك إضافة منطق الحجز هنا
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.cyan[50],
                            radius: 24,
                            child: Image.network(reserveIconUrl, width: 28, height: 28),
                          ),
                          const SizedBox(height: 4),
                          const Text("Reserve", style: TextStyle(fontSize: 13, color: Color(0xFF00C2FF))),
                        ],
                      ),
                    ),
                    // Speed mode
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        // بدلاً من push إلى MenuContent، غير _selectedIndex ليظهر MenuContent مع navigation bar
                        setState(() {
                          _selectedIndex = 4;
                        });
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.red[50],
                            radius: 24,
                            child: Image.network(speedIconUrl, width: 28, height: 28),
                          ),
                          const SizedBox(height: 4),
                          const Text("Speed mode", style: TextStyle(fontSize: 13, color: Color(0xFFFF5B5B))),
                        ],
                      ),
                    ),
                    // Report Issue
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        final url = Uri.parse('https://forms.gle/op5L6cjgUXPhpUiz5');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.amber[50],
                            radius: 24,
                            child: Image.network(reportIconUrl, width: 28, height: 28),
                          ),
                          const SizedBox(height: 4),
                          const Text("Report Issue", style: TextStyle(fontSize: 13, color: Color(0xFF1A1A1A))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Payment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          // الحل الصحيح: غير _selectedIndex ليظهر PaymentContent داخل الـ IndexedStack مع الـ navigation bar
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                        child: Row(
                          children: [
                            Image.network(visaUrl, width: 32, height: 20, fit: BoxFit.contain),
                            const SizedBox(width: 4),
                            Image.network(mcUrl, width: 32, height: 20, fit: BoxFit.contain),
                            const SizedBox(width: 8),
                            const Text("Payment method", style: TextStyle(fontSize: 16, color: Colors.black)),
                            const Spacer(),
                            Icon(Icons.chevron_right, color: Colors.grey[400]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          // نفس الشيء: غير _selectedIndex ليظهر PaymentContent (أي صفحة الدفع) مع navigation bar
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(Icons.local_offer, color: Color(0xFF00FF80), size: 28),
                            const SizedBox(width: 8),
                            Icon(Icons.percent, color: Color(0xFF00FF80), size: 28),
                            const SizedBox(width: 8),
                            const Text("Add Promo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
                            const Spacer(),
                            Icon(Icons.chevron_right, color: Colors.grey[400]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // زر Start ride مع تدرج لوني
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00FFE1), Color(0xFF1DFF97), Color(0xFFC2FF1B)],
                        stops: [0.0, 0.36, 0.67],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Start ride",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        return;
      }

      Position position = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      } else {
        debugPrint('Could not get current location.');
      }
    } catch (e, stackTrace) {
      debugPrint('Error getting location: $e');
      debugPrint(stackTrace.toString());
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentLocation != null && _isMapReady && _mapController != null) {
      try {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation!, 15.0),
        );
      } catch (e) {
        debugPrint('Error animating camera to current location: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error animating camera: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current location not available or map not ready.')),
        );
      }
    }
  }

  Future<void> searchLocation(String query) async {
    if (!mounted) return;
    if (query.isEmpty) return;

    try {
      final String encodedQuery = Uri.encodeComponent(query);
      final String url =
          'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$encodedQuery&language=en®ion=JO&key=$googleMapsApiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] != 'OK') {
          debugPrint('Places API error: ${data['status']} - ${data['error_message']}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Places API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}')),
            );
          }
          return;
        }

        final results = data['results'];
        if (results.isNotEmpty) {
          final location = results[0]['geometry']['location'];
          final double lat = location['lat'];
          final double lng = location['lng'];

          if (mounted) {
            setState(() {
              _destination = LatLng(lat, lng);
              _routePoints = [];
            });

            drawRoute();

            if (_isMapReady && _mapController != null) {
              try {
                await _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(_destination!, 15.0),
                );
              } catch (e) {
                debugPrint('Error animating camera after search: $e');
              }
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location not found. Please try a different search term.')),
            );
          }
        }
      } else {
        debugPrint('Places API HTTP error: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Places API HTTP error: ${response.statusCode}')),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error getting location: $e');
      debugPrint(stackTrace.toString());
    }
  }

  Future<void> drawRoute() async {
    if (!mounted) return;
    if (_currentLocation == null || _destination == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot draw route: Current location or destination is not set.')),
        );
      }
      return;
    }

    try {
      final String encodedOrigin = Uri.encodeComponent('${_currentLocation!.latitude},${_currentLocation!.longitude}');
      final String encodedDestination = Uri.encodeComponent('${_destination!.latitude},${_destination!.longitude}');
      final String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=$encodedOrigin&destination=$encodedDestination&key=$googleMapsApiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] != 'OK') {
          debugPrint('Directions API error: ${data['status']} - ${data['error_message']}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Directions API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}')),
            );
          }
          return;
        }

        final routes = data['routes'];
        if (routes.isNotEmpty) {
          final polyline = routes[0]['overview_polyline']['points'];
          List<LatLng> routePoints = _decodePolyline(polyline);

          if (mounted) {
            setState(() {
              _routePoints = routePoints;
            });

            if (_isMapReady && _mapController != null) {
              try {
                LatLngBounds bounds = LatLngBounds(
                  southwest: LatLng(
                      [_currentLocation!, _destination!, ..._routePoints]
                          .map((p) => p.latitude)
                          .reduce((a, b) => a < b ? a : b),
                      [_currentLocation!, _destination!, ..._routePoints]
                          .map((p) => p.longitude)
                          .reduce((a, b) => a < b ? a : b)),
                  northeast: LatLng(
                      [_currentLocation!, _destination!, ..._routePoints]
                          .map((p) => p.latitude)
                          .reduce((a, b) => a > b ? a : b),
                      [_currentLocation!, _destination!, ..._routePoints]
                          .map((p) => p.longitude)
                          .reduce((a, b) => a > b ? a : b)),
                );

                if (bounds.northeast.latitude != bounds.southwest.latitude &&
                    bounds.northeast.longitude != bounds.southwest.longitude) {
                  await _mapController!.animateCamera(
                    CameraUpdate.newLatLngBounds(bounds, 100.0),
                  );
                } else {
                  debugPrint('Calculated bounds are invalid or empty.');
                }
              } catch (e) {
                debugPrint('Error animating camera after drawing route: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error animating camera: $e')),
                  );
                }
              }
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No route found.')),
            );
          }
        }
      } else {
        debugPrint('Directions API HTTP error: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Directions API HTTP error: ${response.statusCode}')),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error drawing route: $e');
      debugPrint(stackTrace.toString());
    }
  }

  void clearRouteAndDestination() {
    if (mounted) {
      setState(() {
        _routePoints = [];
        _destination = null;
      });
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final List<Widget> screens = [
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
        },
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 15.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                setState(() {
                  _isMapReady = true;
                });
              },
              onTap: (LatLng tappedLocation) {
                setState(() {
                  _destination = tappedLocation;
                  _routePoints = [];
                });
                drawRoute();
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              padding: EdgeInsets.only(top: customTopBarHeight),
              markers: {
                if (_destination != null)
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: _destination!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    onTap: () {
                      clearRouteAndDestination();
                    },
                  ),
                ..._scooterMarkers,
              },
              polylines: {
                if (_routePoints.isNotEmpty)
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: _routePoints,
                    color: Colors.blue,
                    width: 4,
                  ),
              },
              polygons: _geoZones,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: customTopBarHeight,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gradientColor1, gradientColor2, gradientColor3],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.0,
              left: 10.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.pushNamed(context, '/edit-profile');
                      if (result is String) {
                        _updateProfileImage(result);
                      } else {
                        _loadProfileImage();
                      }
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!) // استخدام NetworkImage لرابط الصورة
                          : const AssetImage('assets/user_profile_icon.png') as ImageProvider,
                      onBackgroundImageError: (e, stackTrace) {
                        debugPrint('Error loading user profile image: $e');
                        _loadProfileImage();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 300,
                    height: 55.0,
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextField(
                          controller: _searchController,
                          textAlign: TextAlign.center,
                          textDirection: _searchController.text.isNotEmpty &&
                                  _searchController.text.trim().startsWith(RegExp(r'[\u0600-\u06FF]'))
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          decoration: InputDecoration(
                            hintText: 'Navigate to ...',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            border: InputBorder.none,
                            prefixIcon: Padding(
                              padding: const EdgeInsetsDirectional.only(end: 15.0),
                              child: ImageIcon(
                                const AssetImage('assets/search_prefix_icon.png'),
                                color: gradientColor1,
                                size: 5.0,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              searchLocation(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 550.0,
              right: 15.0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpScreen()),
                        );
                      },
                      child: SvgPicture.asset(
                        'assets/support.svg',
                        width: 24.0,
                        height: 24.0,
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    GestureDetector(
                      onTap: _goToCurrentLocation,
                      child: SvgPicture.asset(
                        'assets/my_location_icon.svg',
                        width: 24.0,
                        height: 24.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      const PaymentContent(), // استبدال Placeholder باستدعاء الملف المنفصل
      const QrContent(), // استبدال Placeholder باستدعاء الملف المنفصل
      RidingGuideContent(), // استبدال Placeholder باستدعاء الملف المنفصل
      const MenuContent(), // استبدال Placeholder باستدعاء الملف المنفصل
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: screens,
            ),
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: Container(
                height: 80.0,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home,
                              color: _selectedIndex == 0 ? homeSelectedColor : unselectedColor,
                              size: _selectedIndex == 0 ? selectedIconSize : unselectedIconSize,
                            ),
                            Text(
                              'Home',
                              style: TextStyle(
                                color: _selectedIndex == 0 ? homeSelectedColor : unselectedColor,
                                fontSize: _selectedIndex == 0 ? 10.0 : 8.0,
                                fontWeight: _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 60.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/payment_icon.svg',
                              width: _selectedIndex == 1 ? selectedIconSize : unselectedIconSize,
                              height: _selectedIndex == 1 ? selectedIconSize : unselectedIconSize,
                              colorFilter: _selectedIndex == 1
                                  ? ColorFilter.mode(paymentSelectedColor, BlendMode.srcIn)
                                  : ColorFilter.mode(unselectedColor, BlendMode.srcIn),
                            ),
                            Text(
                              'Payment',
                              style: TextStyle(
                                color: _selectedIndex == 1 ? paymentSelectedColor : unselectedColor,
                                fontSize: _selectedIndex == 1 ? 10.0 : 8.0,
                                fontWeight: _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = 3;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 70.0, right: 15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/guide_icon.svg',
                              width: _selectedIndex == 3 ? selectedIconSize : unselectedIconSize,
                              height: _selectedIndex == 3 ? selectedIconSize : unselectedIconSize,
                              colorFilter: _selectedIndex == 3
                                  ? ColorFilter.mode(ridingGuideSelectedColor, BlendMode.srcIn)
                                  : ColorFilter.mode(unselectedColor, BlendMode.srcIn),
                            ),
                            Text(
                              'Riding Guide',
                              style: TextStyle(
                                color: _selectedIndex == 3 ? ridingGuideSelectedColor : unselectedColor,
                                fontSize: _selectedIndex == 3 ? 10.0 : 8.0,
                                fontWeight: _selectedIndex == 3 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = 4;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/menu_icon.svg',
                              width: _selectedIndex == 4 ? selectedIconSize : unselectedIconSize,
                              height: _selectedIndex == 4 ? selectedIconSize : unselectedIconSize,
                              colorFilter: _selectedIndex == 4
                                  ? ColorFilter.mode(menuSelectedColor, BlendMode.srcIn)
                                  : ColorFilter.mode(unselectedColor, BlendMode.srcIn),
                            ),
                            Text(
                              'Menu',
                              style: TextStyle(
                                color: _selectedIndex == 4 ? menuSelectedColor : unselectedColor,
                                fontSize: _selectedIndex == 4 ? 10.0 : 8.0,
                                fontWeight: _selectedIndex == 4 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: qrVerticalOffset,
              left: (screenWidth / 2) - (fixedQrSize / 2),
              child: GestureDetector(
                onTap: () {
                  debugPrint('QR button tapped, perform QR scan action');
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
                child: SvgPicture.asset(
                  'assets/icons/qr.svg',
                  width: fixedQrSize,
                  height: fixedQrSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

// ملاحظة: لجعل الـ navigation bar دائماً ظاهراً في جميع الصفحات، يجب أن تجعل التنقل بين PaymentContent وغيره يتم عبر تغيير الـ _selectedIndex في HomeScreen وليس عبر push لصفحات جديدة.
// الحل الأفضل: اجعل كل صفحاتك (PaymentContent, QrContent, MenuContent, RidingGuideContent) تظهر داخل الـ IndexedStack في HomeScreen وغير _selectedIndex فقط.
// إذا أردت أن تذهب إلى صفحة الدفع من أي مكان، استخدم:
// setState(() { _selectedIndex = 1; });
// بدلاً من Navigator.push(...).
// ويمكنك تمرير دالة إلى الـ PaymentContent إذا احتجت ذلك.

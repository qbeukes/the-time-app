import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:inner_time/screens/moon_screen.dart';
import 'package:inner_time/screens/sun_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const InnerTimeApp(),
    ),
  );
}

class InnerTimeApp extends StatelessWidget {
  const InnerTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Inner Time',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late final ValueNotifier<DateTime> _globalMomentNotifier;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _globalMomentNotifier = ValueNotifier<DateTime>(DateTime.now());
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      // Ignore location errors gracefully
    }
  }

  @override
  void dispose() {
    _globalMomentNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _globalMomentNotifier.value,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _globalMomentNotifier.value = picked;
    }
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta != null) {
      final double deltaDays = -details.primaryDelta! / 10.0;
      final int deltaMs = (deltaDays * 24 * 60 * 60 * 1000).round();
      final newTime = _globalMomentNotifier.value.add(Duration(milliseconds: deltaMs));
      _globalMomentNotifier.value = newTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _globalMomentNotifier,
      builder: (context, globalDate, _) {
        final List<Widget> screens = [
          MoonScreen(date: globalDate, latitude: _latitude, longitude: _longitude),
          SunScreen(date: globalDate),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(_currentIndex == 0 ? 'Moon Time' : 'Solar Time'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: _pickDate,
              ),
            ],
          ),
          body: GestureDetector(
            onHorizontalDragUpdate: _handleHorizontalDragUpdate,
            behavior: HitTestBehavior.opaque,
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.nightlight_round),
                label: 'Moon',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.wb_sunny),
                label: 'Sun',
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:background_location_plus/background_location_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool running = false;
  String last = '';
  String speed = '';
  String accuracy = '';
  String timestamp = '';

  @override
  void initState() {
    super.initState();
    BackgroundLocationPlus.initialize();
    BackgroundLocationPlus.configure(
      distanceFilter: 0, // Cada 5 metros
      timeInterval: 1, // O cada 2 segundos
      accuracy: "best", // Máxima precisión
    );
    BackgroundLocationPlus.onLocation.listen((loc) {
      setState(() {
        last = '${loc['latitude']}, ${loc['longitude']}';
        speed = '${loc['speed']}';
        accuracy = '${loc['accuracy']}';
        timestamp = '${loc['timestamp']}';
      });
      print(last);
    });
  }

  _start() async {
    final ok = await BackgroundLocationPlus.requestPermissions();
    if (!ok) {
      // explicar y abrir ajustes si hace falta
      await BackgroundLocationPlus.openAppSettings();
      return;
    }
    final r = await BackgroundLocationPlus.start();
    setState(() {
      running = r;
    });
  }

  _stop() async {
    final r = await BackgroundLocationPlus.stop();
    setState(() {
      running = !r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('BG Location Plus example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running: $running'),
              const SizedBox(height: 12),
              Text('Last: $last'),
              const SizedBox(height: 12),
              Text('Sped: $speed'),
              const SizedBox(height: 12),
              Text('Accuracy: $accuracy'),
              const SizedBox(height: 12),
              Text('Timestamp: $timestamp'),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _start, child: const Text('Start')),
              ElevatedButton(onPressed: _stop, child: const Text('Stop')),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LatLng? gpsLocation;
  String alertMessage = '';
  Timer? _timer;

  final client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchLatestLocation();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchLatestLocation();
    });
  }

  Future<void> _fetchLatestLocation() async {
    final response = await client
        .from('locations')
        .select()
        .order('timestamp', ascending: false)
        .limit(1);

    if (response.isNotEmpty) {
      final row = response.first;
      final double lat = row['latitude'];
      final double lon = row['longitude'];
      final String mode = row['mode'] ?? '';

      setState(() {
        gpsLocation = LatLng(lat, lon);
        alertMessage = mode == 'help' ? '🚨 Help requested!' : '';
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Stick Tracker')),
      body: Column(
        children: [
          if (alertMessage.isNotEmpty)
            Container(
              width: double.infinity,
              color: Colors.red,
              padding: const EdgeInsets.all(12),
              child: Text(
                alertMessage,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          Expanded(
            child: gpsLocation == null
                ? const Center(child: Text('Waiting for location...'))
                : FlutterMap(
                    options: MapOptions(
                      initialCenter: gpsLocation!,
                      initialZoom: 17,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: gpsLocation!,
                            width: 60,
                            height: 60,
                            child: const Icon(
                              Icons.person_pin_circle,
                              size: 48,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.mic),
              label: const Text('Ping Stick (Voice)'),
              onPressed: () async {
                await client.from('alerts').insert({
                  'user_id': 'blind_user_1',
                  'type': 'voice',
                  'message': 'Ping from parent',
                  'timestamp': DateTime.now().toIso8601String(),
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

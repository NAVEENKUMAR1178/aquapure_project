import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final name, phone, addr;
  @override
  void initState() {
    super.initState();
    final p = context.read<AppState>().profile!;
    name = TextEditingController(text: p['name']);
    phone = TextEditingController(text: p['phone']);
    addr = TextEditingController(text: p['address']);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text('Profile (${s.role})')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(s.user?.email ?? ''),
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
        TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone')),
        TextField(controller: addr, maxLines: 2, decoration: const InputDecoration(labelText: 'Address')),
        const SizedBox(height: 12),
        FilledButton(
            onPressed: () => s.saveProfile(name.text, phone.text, addr.text),
            child: const Text('Save')),
        const SizedBox(height: 16),
        const Text('Our service centre (OpenStreetMap)'),
        SizedBox(
          height: 200,
          child: FlutterMap(
            options: const MapOptions(
                initialCenter: LatLng(12.9716, 77.5946), initialZoom: 12),
            children: [
              TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.aquapure'),
              const MarkerLayer(markers: [
                Marker(point: LatLng(12.9716, 77.5946),
                    child: Icon(Icons.location_pin, color: Colors.red, size: 36))
              ]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: s.logout, child: const Text('Logout')),
      ]),
    );
  }
}

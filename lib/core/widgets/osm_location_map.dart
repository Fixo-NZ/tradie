import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/viewmodels/skills_viewmodel.dart';

class OSMLocationMap extends ConsumerStatefulWidget {
  const OSMLocationMap({super.key});

  @override
  ConsumerState<OSMLocationMap> createState() => _OSMLocationMapState();
}

class _OSMLocationMapState extends ConsumerState<OSMLocationMap> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  LatLng? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    try {
      Position pos = await _determinePosition();

      setState(() {
        _currentPosition = LatLng(pos.latitude, pos.longitude);
        _selectedPosition = _currentPosition;
      });

      // Save in ViewModel
      ref.read(skillsViewModelProvider.notifier)
          .updateSelectedLocation(pos.latitude, pos.longitude);

    } catch (e) {
      debugPrint("GPS Error: $e");
    }
  }

  // === GPS permissions + location ===
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services disabled");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions permanently denied");
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 260,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentPosition!,
          initialZoom: 15,
          onTap: (tapPos, latLng) {
            setState(() => _selectedPosition = latLng);

            ref.read(skillsViewModelProvider.notifier)
                .updateSelectedLocation(latLng.latitude, latLng.longitude);
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "com.example.app",
          ),

          // Marker layer
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedPosition!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_pin,
                  size: 40,
                  color: Colors.red,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

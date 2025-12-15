import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/viewmodels/skills_viewmodel.dart';

class OSMLocationMap extends ConsumerStatefulWidget {
  final Function(double latitude, double longitude)? onLocationChanged;
  final LatLng? initialPosition;
  
  const OSMLocationMap({
    super.key,
    this.onLocationChanged,
    this.initialPosition,
  });

  @override
  ConsumerState<OSMLocationMap> createState() => _OSMLocationMapState();
}

class _OSMLocationMapState extends ConsumerState<OSMLocationMap> {
  final MapController _mapController = MapController();
  // Default to Auckland, New Zealand so the map shows immediately
  LatLng _currentPosition = LatLng(-36.8485, 174.7633);
  LatLng _selectedPosition = LatLng(-36.8485, 174.7633);

  @override
  void initState() {
    super.initState();
    // Use initial position if provided, otherwise use default
    if (widget.initialPosition != null) {
      _currentPosition = widget.initialPosition!;
      _selectedPosition = widget.initialPosition!;
    }
    _loadUserLocation();
  }

  @override
  void didUpdateWidget(OSMLocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update map position if initial position changes
    if (widget.initialPosition != null && 
        widget.initialPosition != oldWidget.initialPosition) {
      setState(() {
        _selectedPosition = widget.initialPosition!;
      });
      _mapController.move(widget.initialPosition!, 15);
    }
  }

  // Method to update map position from external source (address geocoding)
  void updateMapPosition(double latitude, double longitude) {
    final newPosition = LatLng(latitude, longitude);
    setState(() {
      _selectedPosition = newPosition;
    });
    _mapController.move(newPosition, 15);
  }

  Future<void> _loadUserLocation() async {
    try {
      Position pos = await _determinePosition();

      final LatLng found = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _currentPosition = found;
        _selectedPosition = found;
      });

      // Move map to device location when it becomes available
      try {
        _mapController.move(_currentPosition, 15);
      } catch (_) {
        // ignore if map controller not ready
      }

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
    // Render immediately using the default NZ position, then update
    // to the device GPS asynchronously when available.
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 15,
              minZoom: 1,
              maxZoom: 18, // Respect OSM server resources
              onTap: (tapPos, latLng) async {
                setState(() => _selectedPosition = latLng);

                // Update viewmodel
                ref.read(skillsViewModelProvider.notifier)
                    .updateSelectedLocation(latLng.latitude, latLng.longitude);
                
                // Notify parent widget about location change
                if (widget.onLocationChanged != null) {
                  widget.onLocationChanged!(latLng.latitude, latLng.longitude);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                // OSM Compliance: Use proper app identification
                userAgentPackageName: "com.fixo.tradie.tradie",
                maxNativeZoom: 18,
                maxZoom: 18,
                // OSM Compliance: Add proper headers
                additionalOptions: const {
                  'User-Agent': 'Tradie App (com.fixo.tradie.tradie)',
                },
              ),

              // Marker layer
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPosition,
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
          
          // OSM Compliance: Required attribution overlay
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '© OpenStreetMap contributors',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

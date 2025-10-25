import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:muni_report_pro/features/issues/domain/entities/issue.dart';
import 'package:muni_report_pro/features/issues/presentation/providers/issue_provider.dart' show allIssuesProvider;
import 'package:muni_report_pro/core/theme/app_colors.dart';

class MapViewPage extends ConsumerStatefulWidget {
  const MapViewPage({super.key});

  @override
  ConsumerState<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends ConsumerState<MapViewPage> {
  final Completer<GoogleMapController> _controller = Completer();
  bool _isLoading = true;
  String? _mapStyle;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(-25.7313, 28.2184), // Centered on South Africa
    zoom: 5,
  );

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _getCurrentLocation();
  }

  Future<void> _loadMapStyle() async {
    try {
      _mapStyle = await rootBundle.loadString('assets/map_styles/map_style.json');
      setState(() {});
    } catch (e) {
      debugPrint('Error loading map style: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
          ),
        );
      }
      return;
    }

    // Get the current position
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
      _moveToCurrentLocation();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: ${e.toString()}')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _moveToCurrentLocation() async {
    if (_currentPosition == null) return;
    
    final GoogleMapController controller = await _controller.future;
    final cameraPosition = CameraPosition(
      target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      zoom: 14,
    );
    
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void _loadIssuesOnMap() {
    final issues = ref.watch(allIssuesProvider).valueOrNull ?? [];
    
    setState(() {
      _markers = {}; // Clear existing markers
      
      for (final issue in issues) {
        if (issue.location != null) {
          _markers.add(
            Marker(
              markerId: MarkerId(issue.id),
              position: LatLng(
                issue.location!.latitude,
                issue.location!.longitude,
              ),
              infoWindow: InfoWindow(
                title: issue.title,
                snippet: issue.status,
                onTap: () {
                  // TODO: Navigate to issue detail
                  // context.push('${Routes.issueDetail}/${issue.id}');
                },
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                _getMarkerColor(issue.status),
              ),
            ),
          );
        }
      }
    });
  }

  double _getMarkerColor(String status) {
    switch (status.toLowerCase()) {
      case 'reported':
        return BitmapDescriptor.hueRed;
      case 'in_progress':
        return BitmapDescriptor.hueBlue;
      case 'resolved':
        return BitmapDescriptor.hueGreen;
      default:
        return BitmapDescriptor.hueOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for issues changes
final issuesAsync = ref.watch(allIssuesProvider);
    
    // Load issues when they're available
    issuesAsync.whenData((_) => _loadIssuesOnMap());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _moveToCurrentLocation,
            tooltip: 'My Location',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: _defaultPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                // Apply custom map style if loaded
                if (_mapStyle != null) {
                  controller.setMapStyle(_mapStyle);
                }
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
              zoomControlsEnabled: false,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moveToCurrentLocation,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}

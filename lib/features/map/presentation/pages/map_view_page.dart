import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import 'package:muni_report_pro/features/issues/domain/entities/issue.dart';
import 'package:muni_report_pro/features/issues/presentation/providers/issue_provider.dart' show allIssuesProvider;
import 'package:muni_report_pro/core/theme/app_colors.dart';
import 'package:muni_report_pro/core/constants/app_constants.dart';
import 'package:muni_report_pro/core/constants/route_constants.dart';

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
  bool _showLegend = true;
  String? _selectedCategory; // For filtering
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

  Future<void> _loadIssuesOnMap() async {
    final issues = ref.watch(allIssuesProvider).valueOrNull ?? [];
    final newMarkers = <Marker>{};
    
    for (final issue in issues) {
      // Skip resolved issues - they don't need to be on the map anymore
      if (issue.status.toLowerCase() == 'resolved') {
        continue;
      }
      
      // Filter by selected category if any
      if (_selectedCategory != null && issue.category != _selectedCategory) {
        continue;
      }
      
      if (issue.location != null) {
        // Create custom icon for this category
        final icon = await _createCustomMarkerIcon(
          _getCategoryIcon(issue.category),
          _getCategoryColor(issue.category),
        );
        
        newMarkers.add(
          Marker(
            markerId: MarkerId(issue.id),
            position: LatLng(
              issue.location!.latitude,
              issue.location!.longitude,
            ),
            infoWindow: InfoWindow(
              title: issue.title,
              snippet: '${IssueCategories.getDisplayName(issue.category)} - ${issue.status}',
              onTap: () {
                context.push('${Routes.issueDetail}/${issue.id}');
              },
            ),
            icon: icon,
          ),
        );
      }
    }
    
    if (mounted) {
      setState(() {
        _markers = newMarkers;
      });
    }
  }

  double _getMarkerColorByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'potholes':
        return BitmapDescriptor.hueOrange; // 🚧 Orange for roads
      case 'water':
        return BitmapDescriptor.hueBlue; // 💧 Blue for water
      case 'electricity':
        return BitmapDescriptor.hueYellow; // ⚡ Yellow for electricity
      case 'waste':
        return BitmapDescriptor.hueGreen; // 🗑️ Green for waste
      case 'safety':
        return BitmapDescriptor.hueRed; // 🚨 Red for safety
      case 'infrastructure':
        return BitmapDescriptor.hueViolet; // 🏗️ Violet for infrastructure
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'potholes':
        return Icons.construction;
      case 'water':
        return Icons.water_drop;
      case 'electricity':
        return Icons.bolt;
      case 'waste':
        return Icons.delete;
      case 'safety':
        return Icons.warning;
      case 'infrastructure':
        return Icons.business;
      default:
        return Icons.location_on;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'potholes':
        return Colors.orange;
      case 'water':
        return Colors.blue;
      case 'electricity':
        return Colors.yellow[700]!;
      case 'waste':
        return Colors.green;
      case 'safety':
        return Colors.red;
      case 'infrastructure':
        return Colors.purple;
      default:
        return Colors.grey;
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
          // Toggle legend
          IconButton(
            icon: Icon(_showLegend ? Icons.layers : Icons.layers_outlined),
            onPressed: () {
              setState(() {
                _showLegend = !_showLegend;
              });
            },
            tooltip: 'Toggle Legend',
          ),
          // My location
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _moveToCurrentLocation,
            tooltip: 'My Location',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Google Map
                GoogleMap(
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
                
                // Legend
                if (_showLegend)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _buildLegend(),
                  ),
                
                // Issue count badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: _buildIssueCountBadge(issuesAsync),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moveToCurrentLocation,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildLegend() {
    return Card(
      elevation: 4,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (_selectedCategory != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                      _loadIssuesOnMap();
                    },
                    tooltip: 'Clear filter',
                  ),
              ],
            ),
            const Divider(height: 8),
            ...IssueCategories.all.map((category) {
              final isSelected = _selectedCategory == category;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = isSelected ? null : category;
                  });
                  _loadIssuesOnMap();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? _getCategoryColor(category).withOpacity(0.2) : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        size: 16,
                        color: _getCategoryColor(category),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          IssueCategories.getDisplayName(category),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueCountBadge(AsyncValue<List<Issue>> issuesAsync) {
    return issuesAsync.when(
      data: (issues) {
        final filteredCount = _selectedCategory != null
            ? issues.where((i) => i.category == _selectedCategory).length
            : issues.length;
        
        return Card(
          elevation: 4,
          color: AppColors.primary,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$filteredCount ${filteredCount == 1 ? 'Issue' : 'Issues'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Create custom marker icon with category icon and color
  Future<BitmapDescriptor> _createCustomMarkerIcon(IconData icon, Color color) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const size = 120.0;

    // Draw circle background
    final paint = Paint()..color = color;
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2,
      paint,
    );

    // Draw white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 4,
      borderPaint,
    );

    // Draw icon
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 60,
        fontFamily: icon.fontFamily,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    // Convert to image
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }
}

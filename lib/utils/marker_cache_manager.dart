import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart'
    as cluster_mgr;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/yelp_places_business.dart';
import '../utils/custom_scroll_text.dart';
import '../utils/sf_font.dart';

class MarkerManager {
  // Image cache: URL → Uint8List
  final Map<String, Uint8List> _imageCache = {};

  // Marker bitmap cache: businessId → BitmapDescriptor
  final Map<String, BitmapDescriptor> _markerCache = {};

  // Cluster manager
  cluster_mgr.ClusterManager<PlaceClusterItem>? _clusterManager;

  cluster_mgr.ClusterManager<PlaceClusterItem>? get clusterManager =>
      _clusterManager;

  // Initialize cluster manager
  void initializeClusterManager({
    required GoogleMapController mapController,
    required Function(Set<Marker>) updateMarkers,
    required Function(YelpBusiness) onMarkerTapped,
  }) {
    _clusterManager = cluster_mgr.ClusterManager<PlaceClusterItem>(
      [],
      updateMarkers,
      markerBuilder: (dynamic cluster) async {
        final c = cluster as cluster_mgr.Cluster<PlaceClusterItem>;

        return Marker(
          markerId: MarkerId(c.getId()),
          position: c.location,
          onTap: () {
            if (!c.isMultiple) {
              onMarkerTapped(c.items.first.business);
            }
          },
          icon: c.isMultiple
              ? await _createClusterMarker(c.count)
              : await getOrCreateMarker(c.items.first.business),
          anchor: const Offset(0.5, 1.0),
        );
      },
    );
  }

  // Update items in cluster manager
  void updateClusterItems(List<YelpBusiness> businesses) {
    final items = businesses
        .map(
          (business) => PlaceClusterItem(
            id: business.id,
            business: business,
            latLng: LatLng(business.latitude ?? 0, business.longitude ?? 0),
          ),
        )
        .toList();

    _clusterManager?.setItems(items);
  }

  // Get or create marker (with caching)
  Future<BitmapDescriptor> getOrCreateMarker(YelpBusiness business) async {
    if (_markerCache.containsKey(business.id)) {
      return _markerCache[business.id]!;
    }

    final marker = await _createCustomMarker(business);
    _markerCache[business.id] = marker;

    return marker;
  }

  // Preload markers
  Future<void> preloadMarkers(List<YelpBusiness> businesses) async {
    final futures = businesses.map((business) async {
      if (!_markerCache.containsKey(business.id)) {
        final marker = await _createCustomMarker(business);
        _markerCache[business.id] = marker;
      }
    }).toList();

    await Future.wait(futures);
  }

  // Load image with caching
  Future<Uint8List?> _loadImageBytes(String url) async {
    if (url.isEmpty) return null;

    if (_imageCache.containsKey(url)) return _imageCache[url];

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        final codec = await ui.instantiateImageCodec(bytes);
        await codec.getNextFrame();

        _imageCache[url] = bytes;
        return bytes;
      }
    } catch (e) {
      debugPrint('Image load error for $url: $e');
    }

    return null;
  }

  // Create custom marker
  Future<BitmapDescriptor> _createCustomMarker(YelpBusiness business) async {
    Color markerColor = business.rating >= 4.5
        ? const Color(0xFF8B5CF6)
        : business.rating >= 4.0
        ? const Color(0xFF3B82F6)
        : const Color(0xFFF59E0B);

    final imageBytes = await _loadImageBytes(business.imageUrl ?? '');

    final customMarker = CustomMarkerWidget(
      businessName: business.name,
      rating: business.rating,
      color: markerColor,
      imageBytes: imageBytes,
    );

    return await _createBitmapDescriptor(customMarker);
  }

  // Create cluster marker
  Future<BitmapDescriptor> _createClusterMarker(int count) async {
    final widget = ClusterMarkerWidget(count: count);
    return await _createBitmapDescriptor(widget);
  }

  // Convert widget to BitmapDescriptor
  Future<BitmapDescriptor> _createBitmapDescriptor(Widget widget) async {
    final repaintBoundary = RenderRepaintBoundary();
    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());

    final renderView = RenderView(
      view: ui.PlatformDispatcher.instance.views.first,
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints(maxWidth: 200, maxHeight: 120),
        physicalConstraints: BoxConstraints(maxWidth: 200, maxHeight: 120),
        devicePixelRatio: 3.0,
      ),
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
    );

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Material(color: Colors.transparent, child: widget),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    await Future.delayed(const Duration(milliseconds: 50));

    final image = await repaintBoundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  // Clear caches
  void clearCache() {
    _imageCache.clear();
    _markerCache.clear();
  }

  void clearMarkerCache() {
    _markerCache.clear();
  }
}

// Cluster item
class PlaceClusterItem with cluster_mgr.ClusterItem {
  final String id;
  final YelpBusiness business;
  final LatLng latLng;

  PlaceClusterItem({
    required this.id,
    required this.business,
    required this.latLng,
  });

  @override
  LatLng get location => latLng;

  @override
  String getId() => id;
}

// Custom Marker Widget
class CustomMarkerWidget extends StatelessWidget {
  final String businessName;
  final double rating;
  final Color color;
  final Uint8List? imageBytes;

  const CustomMarkerWidget({
    super.key,
    required this.businessName,
    required this.rating,
    required this.color,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    image: imageBytes != null
                        ? DecorationImage(
                            image: MemoryImage(imageBytes!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageBytes == null
                      ? Icon(Icons.store, size: 22, color: Colors.grey.shade600)
                      : null,
                ),
                const SizedBox(width: 8),
                CustomScrollText(
                  text: businessName,
                  width: 60,
                  height: 24,
                  fontSize: 11,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  textStyle: SFPro.font(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                    height: 1.2,
                  ),
                ),
                const SizedBox(width: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 12, color: Color(0xFFFBBF24)),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(20, 12),
            painter: TrianglePainter(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// Cluster Marker Widget
class ClusterMarkerWidget extends StatelessWidget {
  final int count;

  const ClusterMarkerWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Triangle painter
class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawShadow(path, Colors.black.withOpacity(0.2), 2.0, false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

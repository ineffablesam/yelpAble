import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../../models/yelp_places_business.dart';
import '../../../utils/custom_sliding_up_panel.dart';

enum ViewMode { list, grid }

// Make YelpBusiness implement ClusterItem
class ClusterYelpBusiness with ClusterItem {
  final YelpBusiness business;

  ClusterYelpBusiness(this.business);

  @override
  LatLng get location =>
      LatLng(business.latitude ?? 0, business.longitude ?? 0);

  String get geohash => business.id; // Use business ID as unique identifier
}

class HomeController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxBool isMapLoading = true.obs;
  final RxList<YelpBusiness> businesses = <YelpBusiness>[].obs;
  final RxList<YelpBusiness> filteredBusinesses = <YelpBusiness>[].obs;
  final Rx<YelpBusiness?> selectedBusiness = Rx<YelpBusiness?>(null);
  final Rx<ViewMode> viewMode = ViewMode.list.obs;

  GoogleMapController? mapController;
  final PanelController panelController = PanelController();

  final RxSet<Marker> markers = <Marker>{}.obs;
  final Rx<LatLng> currentLocation = const LatLng(40.7128, -74.0060).obs;

  // Cluster Manager
  ClusterManager<ClusterYelpBusiness>? clusterManager;
  final RxList<ClusterYelpBusiness> clusterItems = <ClusterYelpBusiness>[].obs;

  // Search
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  Timer? _debounce;

  // Filters
  final RxList<String> selectedCategories = <String>[].obs;
  final RxString selectedPrice = ''.obs;
  final RxDouble selectedRadius = 5000.0.obs;
  final RxBool openNowOnly = false.obs;
  final RxString sortBy = 'best_match'.obs;

  final List<String> availableCategories = [
    'Restaurants',
    'Coffee & Tea',
    'Bars',
    'Shopping',
    'Hotels',
    'Beauty & Spas',
    'Arts & Entertainment',
    'Active Life',
    'Nightlife',
    'Fast Food',
    'Burgers',
    'Pizza',
    'Asian Fusion',
    'Italian',
    'Mexican',
  ];

  final List<String> priceOptions = ['\$', '\$\$', '\$\$\$', '\$\$\$\$'];

  int get activeFiltersCount {
    int count = 0;
    if (selectedCategories.isNotEmpty) count += selectedCategories.length;
    if (selectedPrice.isNotEmpty) count++;
    if (openNowOnly.value) count++;
    if (selectedRadius.value != 5000.0) count++;
    if (sortBy.value != 'best_match') count++;
    return count;
  }

  // Custom map style
  String? mapStyle;

  @override
  void onInit() {
    super.onInit();
    _loadMapStyle();
    _initializeClusterManager();
    _initializeLocation();
  }

  Future<void> _loadMapStyle() async {
    mapStyle = '''
  [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8ec3b9"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1a3646"
      }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#4b6878"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#64779e"
      }
    ]
  },
  {
    "featureType": "administrative.province",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#4b6878"
      }
    ]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#334e87"
      }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#283d6a"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6f9ba5"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#3C7680"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#304a7d"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#98a5be"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2c6675"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#255763"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#b0d5ce"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#98a5be"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#283d6a"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#3a4762"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#0e1626"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#4e6d70"
      }
    ]
  }
]
    ''';
  }

  void _initializeClusterManager() {
    clusterManager = ClusterManager<ClusterYelpBusiness>(
      clusterItems,
      _updateMarkers,
      markerBuilder: _markerBuilder,
      levels: [1, 4.25, 6.75, 8.25, 11.5, 14.5, 16.0, 16.5, 20.0],
      extraPercent: 0.2,
      stopClusteringZoom: 17.0,
    );
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;

    if (mapStyle != null) {
      mapController!.setMapStyle(mapStyle);
    }

    // Set the map ID for the cluster manager
    clusterManager?.setMapId(controller.mapId);
  }

  Future<void> _initializeLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        currentLocation.value = const LatLng(40.7128, -74.0060);
      } else {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        currentLocation.value = LatLng(position.latitude, position.longitude);
      }
    } catch (e) {
      currentLocation.value = const LatLng(40.7128, -74.0060);
    }

    await fetchBusinesses();
  }

  void setViewMode(ViewMode mode) {
    viewMode.value = mode;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _filterBusinesses();
    });
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _filterBusinesses();
  }

  void _filterBusinesses() {
    if (searchQuery.value.isEmpty) {
      filteredBusinesses.value = businesses;
    } else {
      filteredBusinesses.value = businesses.where((business) {
        final nameLower = business.name.toLowerCase();
        final queryLower = searchQuery.value.toLowerCase();
        final categoriesMatch = business.categories.any(
          (cat) => cat.toLowerCase().contains(queryLower),
        );
        return nameLower.contains(queryLower) || categoriesMatch;
      }).toList();
    }

    // Update cluster items
    clusterItems.value = filteredBusinesses
        .map((business) => ClusterYelpBusiness(business))
        .toList();

    // Update the cluster manager
    clusterManager?.setItems(clusterItems);
  }

  Future<void> fetchBusinesses() async {
    try {
      isLoading.value = true;

      final categories = selectedCategories.isEmpty
          ? ''
          : selectedCategories.join(',').toLowerCase().replaceAll(' ', '');

      final queryParams = {
        'latitude': currentLocation.value.latitude.toString(),
        'longitude': currentLocation.value.longitude.toString(),
        'radius': selectedRadius.value.toInt().toString(),
        'sort_by': sortBy.value,
        'limit': '50',
        if (categories.isNotEmpty) 'categories': categories,
        if (selectedPrice.isNotEmpty) 'price': selectedPrice.value,
        if (openNowOnly.value) 'open_now': 'true',
      };

      final uri = Uri.https(
        'api.yelp.com',
        '/v3/businesses/search',
        queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization':
              'Bearer uzzIWEZt_m7eWcHBGID4Hacc8Y2ImS3QUq4VpkSKb3X5WpSDhtIJiEXsukT25xgCoN2doxCoTzKTwn05so3rMFktAjDo42MU8Qhi1UuSzLapy7vc8ZCnq2S21js3aXYx',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> businessList = data['businesses'] ?? [];

        businesses.value = businessList
            .map((json) => YelpBusiness.fromJson(json))
            .toList();

        _filterBusinesses();
      }
    } catch (e) {
      debugPrint('Error fetching businesses: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch businesses',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
      isMapLoading.value = false;
    }
  }

  // This method is called by the cluster manager when markers need to be updated
  void _updateMarkers(Set<Marker> newMarkers) {
    markers.value = newMarkers;
  }

  // This method builds markers for clusters
  Future<Marker> _markerBuilder(Cluster<ClusterYelpBusiness> cluster) async {
    if (cluster.isMultiple) {
      // Build cluster marker (multiple businesses)
      return Marker(
        markerId: MarkerId(cluster.getId()),
        position: cluster.location,
        icon: await _createClusterMarker(cluster.count),
        anchor: const Offset(0.5, 0.5),
        onTap: () {
          // Zoom in on cluster
          mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(cluster.location, 15),
          );
        },
      );
    } else {
      // Build single business marker
      final business = cluster.items.first.business;
      final markerIcon = await _createCustomMarker(business);

      return Marker(
        markerId: MarkerId(business.id),
        position: LatLng(business.latitude ?? 0, business.longitude ?? 0),
        icon: markerIcon,
        anchor: const Offset(0.5, 1.0),
        onTap: () {
          selectedBusiness.value = business;
          panelController.open();
          mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(business.latitude ?? 0, business.longitude ?? 0),
              15,
            ),
          );
        },
      );
    }
  }

  // Create cluster marker icon (for multiple businesses)
  Future<BitmapDescriptor> _createClusterMarker(int count) async {
    final customMarker = ClusterMarkerWidget(count: count);
    return await _createBitmapDescriptor(customMarker);
  }

  Future<BitmapDescriptor> _createCustomMarker(YelpBusiness business) async {
    Color markerColor = business.rating >= 4.5
        ? const Color(0xFF8B5CF6)
        : business.rating >= 4.0
        ? const Color(0xFF3B82F6)
        : const Color(0xFFF59E0B);

    // Pre-load the image
    ui.Image? image;
    if (business.imageUrl != null && business.imageUrl!.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(business.imageUrl!));
        if (response.statusCode == 200) {
          final codec = await ui.instantiateImageCodec(response.bodyBytes);
          final frame = await codec.getNextFrame();
          image = frame.image;
        }
      } catch (e) {
        debugPrint('Failed to load image: $e');
      }
    }

    final customMarker = CustomMarkerWidget(
      businessName: business.name,
      rating: business.rating,
      color: markerColor,
      image: image,
    );

    return await _createBitmapDescriptor(customMarker);
  }

  Future<BitmapDescriptor> _createBitmapDescriptor(Widget widget) async {
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

    final RenderView renderView = RenderView(
      view: ui.PlatformDispatcher.instance.views.first,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        logicalConstraints: const BoxConstraints(maxWidth: 190, maxHeight: 80),
        physicalConstraints: const BoxConstraints(maxWidth: 50, maxHeight: 80),
        devicePixelRatio: 1.0,
      ),
    );

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
          container: repaintBoundary,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(150, 180),
                devicePixelRatio: 1.0,
              ),
              child: Material(color: Colors.transparent, child: widget),
            ),
          ),
        ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final ui.Image image = await repaintBoundary.toImage(pixelRatio: 2.0);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List imageData = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(imageData);
  }

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
    fetchBusinesses();
  }

  void setPrice(String price) {
    selectedPrice.value = selectedPrice.value == price ? '' : price;
    fetchBusinesses();
  }

  void setRadius(double radius) {
    selectedRadius.value = radius;
    fetchBusinesses();
  }

  void toggleOpenNow() {
    openNowOnly.value = !openNowOnly.value;
    fetchBusinesses();
  }

  void setSortBy(String sort) {
    sortBy.value = sort;
    fetchBusinesses();
  }

  void clearFilters() {
    selectedCategories.clear();
    selectedPrice.value = '';
    selectedRadius.value = 5000.0;
    openNowOnly.value = false;
    sortBy.value = 'best_match';
    fetchBusinesses();
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    mapController?.dispose();
    super.onClose();
  }
}

// Cluster Marker Widget (for multiple businesses)
class ClusterMarkerWidget extends StatelessWidget {
  final int count;

  const ClusterMarkerWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF8B5CF6),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
    );
  }
}

class CustomMarkerWidget extends StatelessWidget {
  final String businessName;
  final double rating;
  final Color color;
  final ui.Image? image;

  const CustomMarkerWidget({
    super.key,
    required this.businessName,
    required this.rating,
    required this.color,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0x85090F18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF7489AC), width: 1),
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
                      color: Colors.grey.shade800.withOpacity(0.3),
                    ),
                    child: ClipOval(
                      child: image != null
                          ? CustomPaint(
                              painter: ImagePainter(image: image!),
                              size: const Size(48, 48),
                            )
                          : const Icon(
                              Icons.store,
                              size: 22,
                              color: Colors.white,
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      businessName,
                      maxLines: 1,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: Color(0xFFFBBF24),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter({required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) => false;
}

// Triangle painter for the pointer
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

    // Add shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.2), 2.0, false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

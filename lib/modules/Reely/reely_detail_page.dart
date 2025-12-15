import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:yelpable/utils/sf_font.dart';

import '../../models/yelp_metadata_model.dart'; // Import your model

class ReelDetailPage extends StatefulWidget {
  final String reelId;

  const ReelDetailPage({super.key, required this.reelId});

  @override
  State<ReelDetailPage> createState() => _ReelDetailPageState();
}

class _ReelDetailPageState extends State<ReelDetailPage> {
  final supabase = Supabase.instance.client;
  Stream<Map<String, dynamic>>? reelStream;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    setupRealtimeSubscription();
  }

  void setupRealtimeSubscription() {
    reelStream = supabase
        .from('reels')
        .stream(primaryKey: ['id'])
        .eq('id', widget.reelId)
        .map((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            final reel = data.first;
            if (reel['video_url'] != null && _videoController == null) {
              _initializeVideoPlayer(reel['video_url']);
            }
            return reel;
          }
          return <String, dynamic>{};
        });
  }

  Future<void> _initializeVideoPlayer(String videoUrl) async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoController!.initialize();
      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      print('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFF9500);
      case 'downloading':
        return const Color(0xFF007AFF);
      case 'analyzing':
        return const Color(0xFFAF52DE);
      case 'querying_yelp':
        return const Color(0xFF5856D6);
      case 'completed':
        return const Color(0xFF34C759);
      case 'error':
        return const Color(0xFFFF3B30);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'downloading':
        return 'Downloading Video';
      case 'analyzing':
        return 'Analyzing Content';
      case 'querying_yelp':
        return 'Finding Restaurants';
      case 'completed':
        return 'Completed';
      case 'error':
        return 'Error';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Color(0xFF1A1A1A)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Reel Details',
          style: SFPro.font(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.trash, color: Color(0xFFFF3B30)),
            onPressed: () => _showDeleteConfirmation(),
          ),
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: reelStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CupertinoActivityIndicator(radius: 14),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading reel details...',
                    style: SFPro.font(
                      fontSize: 15.sp,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 64.sp,
                    color: const Color(0xFFFF3B30),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Failed to load reel',
                    style: SFPro.font(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CupertinoButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Go Back',
                      style: SFPro.font(
                        fontSize: 15.sp,
                        color: const Color(0xFF007AFF),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final reel = snapshot.data!;
          return _buildContent(reel);
        },
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> reel) {
    final status = reel['status'] ?? 'pending';
    final title = reel['title'] ?? 'Processing...';
    final restaurants = reel['restaurants'] as List? ?? [];
    final valid = reel['valid'] ?? false;
    final errorMessage = reel['error_message'];
    final videoUrl = reel['video_url'];
    final instagramUrl = reel['instagram_url'];
    final yelpReview = reel['yelp_review'];
    final createdAt = reel['created_at'];

    // Parse yelp_entities JSON
    List<YelpEntity>? yelpEntities;
    try {
      if (reel['yelp_entities'] != null) {
        // yelp_entities is a List, not a Map
        final entitiesList = reel['yelp_entities'] as List;
        yelpEntities = entitiesList
            .map((e) => YelpEntity.fromMap(e as Map<String, dynamic>))
            .toList();
        print('✅ Parsed ${yelpEntities.length} yelp entities');
      }
    } catch (e) {
      print('❌ Error parsing yelp_entities: $e');
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: _getStatusColor(status).withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.circle_fill,
                  size: 8.sp,
                  color: _getStatusColor(status),
                ),
                SizedBox(width: 8.w),
                Text(
                  _getStatusText(status),
                  style: SFPro.font(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(status),
                  ),
                ),
                if (status != 'completed' && status != 'error') ...[
                  SizedBox(width: 12.w),
                  SizedBox(
                    width: 14.w,
                    height: 14.w,
                    child: CupertinoActivityIndicator(
                      color: _getStatusColor(status),
                      radius: 7,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video Player or Thumbnail
                if (videoUrl != null && _isVideoInitialized)
                  _buildVideoPlayer()
                else if (reel['thumbnail_url'] != null)
                  _buildThumbnail(reel['thumbnail_url'])
                else
                  _buildVideoPlaceholder(),

                SizedBox(height: 20.h),

                // Title
                Text(
                  title,
                  style: SFPro.font(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 8.h),

                // Timestamp
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.clock,
                      size: 14.sp,
                      color: const Color(0xFF8E8E93),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatTimestamp(createdAt),
                      style: SFPro.font(
                        fontSize: 14.sp,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Instagram URL Card
                _buildInfoCard(
                  icon: CupertinoIcons.link,
                  title: 'Instagram URL',
                  content: instagramUrl,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 0,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: instagramUrl));
                          _showToast('URL copied to clipboard');
                        },
                        child: Icon(
                          CupertinoIcons.doc_on_doc,
                          size: 20.sp,
                          color: const Color(0xFF007AFF),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 0,
                        onPressed: () async {
                          final uri = Uri.parse(instagramUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        child: Icon(
                          CupertinoIcons.arrow_up_right_square,
                          size: 20.sp,
                          color: const Color(0xFF007AFF),
                        ),
                      ),
                    ],
                  ),
                ),

                // Error Message
                if (errorMessage != null && errorMessage.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFFF3B30).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          CupertinoIcons.exclamationmark_circle,
                          color: const Color(0xFFFF3B30),
                          size: 20.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: SFPro.font(
                              fontSize: 14.sp,
                              color: const Color(0xFFFF3B30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Processing Message
                if (status != 'completed' && status != 'error') ...[
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFF007AFF).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CupertinoActivityIndicator(
                            color: Color(0xFF007AFF),
                            radius: 10,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Your reel is being processed. This page updates automatically.',
                            style: SFPro.font(
                              fontSize: 14.sp,
                              color: const Color(0xFF007AFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Yelp Review Section
                if (yelpReview != null && yelpReview.isNotEmpty) ...[
                  SizedBox(height: 24.h),
                  _buildSectionHeader(
                    icon: CupertinoIcons.quote_bubble_fill,
                    title: 'AI-Generated Review',
                    color: const Color(0xFFFF3B30),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFF3B30).withOpacity(0.05),
                          const Color(0xFFFF9500).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: const Color(0xFFFF3B30).withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      yelpReview,
                      style: SFPro.font(
                        fontSize: 15.sp,
                        height: 1.6,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ],

                // Yelp Businesses Section
                if (yelpEntities != null && yelpEntities.isNotEmpty) ...[
                  SizedBox(height: 32.h),
                  _buildSectionHeader(
                    icon: CupertinoIcons.building_2_fill,
                    title: 'Discovered Restaurants',
                    subtitle:
                        '${_getTotalBusinessCount(yelpEntities)} places found',
                    color: const Color(0xFF34C759),
                  ),
                  SizedBox(height: 16.h),
                  ..._buildYelpBusinessCards(yelpEntities),
                ],

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 20.sp, color: color),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: SFPro.font(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: SFPro.font(
                    fontSize: 13.sp,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  int _getTotalBusinessCount(List<YelpEntity> entities) {
    int count = 0;
    for (var entity in entities) {
      count += entity.businesses?.length ?? 0;
    }
    return count;
  }

  List<Widget> _buildYelpBusinessCards(List<YelpEntity> entities) {
    List<Widget> cards = [];
    int index = 0;

    for (var entity in entities) {
      if (entity.businesses != null) {
        for (var business in entity.businesses!) {
          cards.add(_buildBusinessCard(business, index + 1));
          cards.add(SizedBox(height: 16.h));
          index++;
        }
      }
    }

    return cards;
  }

  Widget _buildBusinessCard(Business business, int number) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with number badge
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF34C759).withOpacity(0.1),
                  const Color(0xFF30D158).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF34C759), Color(0xFF30D158)],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF34C759).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: SFPro.font(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.name ?? 'Unknown Restaurant',
                        style: SFPro.font(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      if (business.categories != null &&
                          business.categories!.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          business.categories!
                              .map((c) => c.title ?? '')
                              .take(2)
                              .join(' • '),
                          style: SFPro.font(
                            fontSize: 13.sp,
                            color: const Color(0xFF34C759),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating and Price
                Row(
                  children: [
                    if (business.rating != null) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9500).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.star_fill,
                              size: 14.sp,
                              color: const Color(0xFFFF9500),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              business.rating!.toStringAsFixed(1),
                              style: SFPro.font(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFF9500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    if (business.price != null) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF34C759).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          business.price!,
                          style: SFPro.font(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF34C759),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    if (business.reviewCount != null) ...[
                      Text(
                        '${business.reviewCount} reviews',
                        style: SFPro.font(
                          fontSize: 13.sp,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ],
                ),

                // Location
                if (business.location?.formattedAddress != null) ...[
                  SizedBox(height: 12.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.location_solid,
                        size: 16.sp,
                        color: const Color(0xFF007AFF),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          business.location!.formattedAddress!,
                          style: SFPro.font(
                            fontSize: 14.sp,
                            color: const Color(0xFF1A1A1A),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Phone
                if (business.phone != null && business.phone!.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.phone_fill,
                        size: 16.sp,
                        color: const Color(0xFF34C759),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        business.phone!,
                        style: SFPro.font(
                          fontSize: 14.sp,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ],

                // Summary
                if (business.summaries?.short != null) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          CupertinoIcons.info_circle_fill,
                          size: 16.sp,
                          color: const Color(0xFF5856D6),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            business.summaries!.short!,
                            style: SFPro.font(
                              fontSize: 13.sp,
                              color: const Color(0xFF1A1A1A),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Attributes badges
                if (_hasRelevantAttributes(business)) ...[
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _buildAttributeBadges(business),
                  ),
                ],

                // Action buttons
                SizedBox(height: 16.h),
                Row(
                  children: [
                    if (business.url != null) ...[
                      Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          color: const Color(0xFFFF3B30),
                          borderRadius: BorderRadius.circular(10.r),
                          onPressed: () async {
                            final uri = Uri.parse(business.url!);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'View on Yelp',
                                style: SFPro.font(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                CupertinoIcons.arrow_up_right,
                                size: 16.sp,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasRelevantAttributes(Business business) {
    final attrs = business.attributes;
    if (attrs == null) return false;
    return attrs.restaurantsDelivery == true ||
        attrs.restaurantsTakeOut == true ||
        attrs.wheelchairAccessible == true ||
        attrs.goodForKids == true ||
        attrs.wiFi != null ||
        attrs.businessAcceptsCreditCards == true;
  }

  List<Widget> _buildAttributeBadges(Business business) {
    List<Widget> badges = [];
    final attrs = business.attributes;
    if (attrs == null) return badges;

    if (attrs.restaurantsDelivery == true) {
      badges.add(
        _buildBadge(
          'Delivery',
          CupertinoIcons.car_fill,
          const Color(0xFF34C759),
        ),
      );
    }
    if (attrs.restaurantsTakeOut == true) {
      badges.add(
        _buildBadge(
          'Takeout',
          CupertinoIcons.bag_fill,
          const Color(0xFFFF9500),
        ),
      );
    }
    if (attrs.wheelchairAccessible == true) {
      badges.add(
        _buildBadge(
          'Accessible',
          CupertinoIcons.person_fill,
          const Color(0xFF007AFF),
        ),
      );
    }
    if (attrs.goodForKids == true) {
      badges.add(
        _buildBadge(
          'Kid Friendly',
          CupertinoIcons.heart_fill,
          const Color(0xFFFF2D55),
        ),
      );
    }
    if (attrs.wiFi != null && attrs.wiFi != 'no') {
      badges.add(
        _buildBadge('WiFi', CupertinoIcons.wifi, const Color(0xFF5856D6)),
      );
    }
    if (attrs.businessAcceptsCreditCards == true) {
      badges.add(
        _buildBadge(
          'Cards',
          CupertinoIcons.creditcard_fill,
          const Color(0xFFAF52DE),
        ),
      );
    }

    return badges;
  }

  Widget _buildBadge(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: SFPro.font(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYelpTags(List<YelpTag> tags) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: tags.map((tag) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF5856D6).withOpacity(0.15),
                const Color(0xFFAF52DE).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: const Color(0xFF5856D6).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.tag_fill,
                size: 14.sp,
                color: const Color(0xFF5856D6),
              ),
              SizedBox(width: 6.w),
              Text(
                tag.tagType ?? 'Tag',
                style: SFPro.font(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5856D6),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildYelpTypes(List<String> types) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: types.map((type) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFF9500).withOpacity(0.15),
                const Color(0xFFFF3B30).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFFF9500).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            type,
            style: SFPro.font(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFF9500),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      width: double.infinity,
      height: 400.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            _VideoControls(controller: _videoController!),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(String thumbnailUrl) {
    return Container(
      width: double.infinity,
      height: 400.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Image.network(
          thumbnailUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CupertinoActivityIndicator(radius: 14));
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildVideoPlaceholder();
          },
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      width: double.infinity,
      height: 400.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFF7F8FA), const Color(0xFFE5E5EA)],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.film,
              size: 64.sp,
              color: const Color(0xFFD1D1D6),
            ),
            SizedBox(height: 12.h),
            Text(
              'Video processing...',
              style: SFPro.font(
                fontSize: 15.sp,
                color: const Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    Widget? trailing,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18.sp, color: const Color(0xFF007AFF)),
                  SizedBox(width: 8.w),
                  Text(
                    title,
                    style: SFPro.font(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: SFPro.font(fontSize: 14.sp, color: const Color(0xFF007AFF)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'Just now';

    try {
      final dateTime = DateTime.parse(timestamp);
      return timeago.format(dateTime);
    } catch (e) {
      return 'Just now';
    }
  }

  void _showDeleteConfirmation() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Delete Reel',
          style: SFPro.font(fontSize: 17.sp, fontWeight: FontWeight.w600),
        ),
        content: Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Text(
            'Are you sure you want to delete this reel? This action cannot be undone.',
            style: SFPro.font(fontSize: 13.sp),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: SFPro.font(
                fontSize: 17.sp,
                color: const Color(0xFF007AFF),
              ),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await supabase.from('reels').delete().eq('id', widget.reelId);
                Get.back();
                _showToast('Reel deleted successfully');
              } catch (e) {
                _showToast('Failed to delete reel');
              }
            },
            child: Text(
              'Delete',
              style: SFPro.font(fontSize: 17.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    Get.snackbar(
      '',
      message,
      titleText: const SizedBox.shrink(),
      messageText: Text(
        message,
        style: SFPro.font(fontSize: 15.sp, color: Colors.white),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
      duration: const Duration(seconds: 2),
    );
  }
}

// Video Controls Widget
class _VideoControls extends StatefulWidget {
  final VideoPlayerController controller;

  const _VideoControls({required this.controller});

  @override
  State<_VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<_VideoControls> {
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_videoListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_videoListener);
    super.dispose();
  }

  void _videoListener() {
    if (mounted) setState(() {});
  }

  void _togglePlayPause() {
    setState(() {
      if (widget.controller.value.isPlaying) {
        widget.controller.pause();
      } else {
        widget.controller.play();
        _hideControlsAfterDelay();
      }
    });
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _showControls = !_showControls);
        if (_showControls && widget.controller.value.isPlaying) {
          _hideControlsAfterDelay();
        }
      },
      child: Container(
        color: Colors.transparent,
        child: AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Stack(
            children: [
              Center(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _togglePlayPause,
                  child: Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.controller.value.isPlaying
                          ? CupertinoIcons.pause_fill
                          : CupertinoIcons.play_fill,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      VideoProgressIndicator(
                        widget.controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: const Color(0xFF007AFF),
                          bufferedColor: Colors.white.withOpacity(0.3),
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(widget.controller.value.position),
                            style: SFPro.font(
                              fontSize: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _formatDuration(widget.controller.value.duration),
                            style: SFPro.font(
                              fontSize: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

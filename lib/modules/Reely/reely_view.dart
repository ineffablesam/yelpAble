import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:yelpable/utils/sf_font.dart';

import '../../utils/colors.dart';
import 'reely_controller.dart';
import 'reely_detail_page.dart';

class ReelyPage extends StatelessWidget {
  const ReelyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Get.put with tag to ensure single instance
    final ReelyController controller = Get.put(ReelyController());
    final TextEditingController urlController = TextEditingController();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFEEEEEE), const Color(0xFFDDDAF8)],
        ),
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.scaffoldBg,
                surfaceTintColor: AppColors.scaffoldBg,
                elevation: 0,
                centerTitle: true,
                stretch: true,
                actions: [
                  Obx(() {
                    if (controller.isLoadingReels.value) {
                      return Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: const CupertinoActivityIndicator(radius: 10),
                      );
                    }
                    return IconButton(
                      icon: const Icon(
                        CupertinoIcons.refresh,
                        color: Color(0xFF007AFF),
                      ),
                      onPressed: () => controller.loadReels(),
                    );
                  }),
                ],
                title: Row(
                  children: [
                    Text(
                      'Reely',
                      style: SFPro.font(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    10.horizontalSpace,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.r),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Supercharged by',
                              style: SFPro.font(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[900],
                              ),
                            ),
                            VerticalDivider(
                              indent: 3,
                              endIndent: 2,
                              color: Colors.black.withOpacity(0.2),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 0.h),
                              child: SvgPicture.asset(
                                'assets/images/yelp.svg',
                                width: 32.w,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: Column(
                  children: [
                    // URL Input Section
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFFE5E5EA),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Input Field
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: TextField(
                              controller: urlController,
                              decoration: InputDecoration(
                                hintText: 'Paste Instagram Reel URL...',
                                hintStyle: SFPro.font(
                                  fontSize: 15.sp,
                                  color: const Color(0xFFC7C7CC),
                                ),
                                prefixIcon: Icon(
                                  CupertinoIcons.link,
                                  color: const Color(0xFF8E8E93),
                                  size: 20.sp,
                                ),
                                suffixIcon: Obx(() {
                                  if (controller.isProcessing.value) {
                                    return Padding(
                                      padding: EdgeInsets.all(12.w),
                                      child: SizedBox(
                                        width: 20.w,
                                        height: 20.w,
                                        child: const CupertinoActivityIndicator(
                                          radius: 10,
                                        ),
                                      ),
                                    );
                                  }
                                  if (urlController.text.isNotEmpty) {
                                    return IconButton(
                                      icon: Icon(
                                        CupertinoIcons.clear_circled_solid,
                                        color: const Color(0xFF8E8E93),
                                        size: 20.sp,
                                      ),
                                      onPressed: () => urlController.clear(),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                              ),
                              style: SFPro.font(fontSize: 15.sp),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  controller.processInstagramUrl(value.trim());
                                  urlController.clear();
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 12.h),
                          // Analyze Button
                          Obx(
                            () => GestureDetector(
                              onTap: controller.isProcessing.value
                                  ? null
                                  : () {
                                      final url = urlController.text.trim();
                                      if (url.isNotEmpty) {
                                        controller.processInstagramUrl(url);
                                        urlController.clear();
                                      }
                                    },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage(
                                      'assets/images/container-bg.png',
                                    ),
                                    fit: BoxFit.cover,
                                    opacity: 0.9,
                                    repeat: ImageRepeat.repeat,
                                  ),
                                  borderRadius: BorderRadius.circular(50.r),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.6),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (controller.isProcessing.value)
                                      Padding(
                                        padding: EdgeInsets.only(right: 8.w),
                                        child: const CupertinoActivityIndicator(
                                          color: Colors.white,
                                          radius: 10,
                                        ),
                                      ),
                                    Icon(
                                      CupertinoIcons.sparkles,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      controller.isProcessing.value
                                          ? 'Processing...'
                                          : 'Analyze Reel',
                                      style: SFPro.font(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Reels Grid
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoadingReels.value &&
                            controller.reels.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CupertinoActivityIndicator(radius: 14),
                                SizedBox(height: 16.h),
                                Text(
                                  'Loading your reels...',
                                  style: SFPro.font(
                                    fontSize: 15.sp,
                                    color: const Color(0xFF8E8E93),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (controller.reels.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.film,
                                    size: 64.sp,
                                    color: const Color(0xFFD1D1D6),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'No Reels Yet',
                                    style: SFPro.font(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Paste an Instagram Reel URL above\nto discover food spots!',
                                    style: SFPro.font(
                                      fontSize: 15.sp,
                                      color: const Color(0xFF8E8E93),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: controller.loadReels,
                          color: const Color(0xFF007AFF),
                          child: MasonryGridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12.h,
                            crossAxisSpacing: 12.w,
                            padding: EdgeInsets.all(16.w),
                            itemCount: controller.reels.length,
                            itemBuilder: (context, index) {
                              final reel = controller.reels[index];
                              // Use unique key and real-time card for proper updates
                              return _RealtimeReelCard(
                                key: ValueKey(reel['id']),
                                reelId: reel['id'],
                                controller: controller,
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Real-time card that subscribes to individual reel updates
class _RealtimeReelCard extends StatefulWidget {
  final String reelId;
  final ReelyController controller;

  const _RealtimeReelCard({
    Key? key,
    required this.reelId,
    required this.controller,
  }) : super(key: key);

  @override
  State<_RealtimeReelCard> createState() => _RealtimeReelCardState();
}

class _RealtimeReelCardState extends State<_RealtimeReelCard> {
  final supabase = Supabase.instance.client;
  StreamSubscription? _subscription;
  Map<String, dynamic>? _reelData;

  @override
  void initState() {
    super.initState();
    _setupRealtimeSubscription();
  }

  void _setupRealtimeSubscription() {
    // Subscribe to this specific reel's updates
    _subscription = supabase
        .from('reels')
        .stream(primaryKey: ['id'])
        .eq('id', widget.reelId)
        .listen((List<Map<String, dynamic>> data) {
          if (mounted && data.isNotEmpty) {
            setState(() {
              _reelData = data.first;
            });
            print('🔄 Card ${widget.reelId} updated: ${_reelData!['status']}');
          }
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return CupertinoIcons.clock;
      case 'downloading':
        return CupertinoIcons.cloud_download;
      case 'analyzing':
        return CupertinoIcons.chart_bar_alt_fill;
      case 'querying_yelp':
        return CupertinoIcons.search;
      case 'completed':
        return CupertinoIcons.check_mark_circled;
      case 'error':
        return CupertinoIcons.exclamationmark_triangle;
      default:
        return CupertinoIcons.info;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'downloading':
        return 'Downloading';
      case 'analyzing':
        return 'Analyzing';
      case 'querying_yelp':
        return 'Finding Places';
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
    // If no data yet, show loading placeholder
    if (_reelData == null) {
      return Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: const Center(child: CupertinoActivityIndicator(radius: 10)),
      );
    }

    final status = _reelData!['status'] ?? 'pending';
    final title = _reelData!['title'] ?? 'Processing...';
    final restaurants = _reelData!['restaurants'] as List? ?? [];
    final valid = _reelData!['valid'] ?? false;
    final thumbnailUrl = _reelData!['thumbnail_url'];
    final createdAt = _reelData!['created_at'];

    return GestureDetector(
      onTap: () => Get.to(
        () => ReelDetailPage(reelId: widget.reelId),
        transition: Transition.cupertino,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
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
            // Thumbnail with status overlay
            Stack(
              children: [
                // Thumbnail
                Container(
                  width: double.infinity,
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    child: thumbnailUrl != null
                        ? Image.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CupertinoActivityIndicator(radius: 10),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                // Status badge
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          size: 14.sp,
                          color: Colors.white,
                        ),
                        if (status != 'completed' && status != 'error') ...[
                          SizedBox(width: 6.w),
                          SizedBox(
                            width: 10.w,
                            height: 10.w,
                            child: const CupertinoActivityIndicator(
                              color: Colors.white,
                              radius: 5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Play icon overlay
                if (status == 'completed')
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.play_fill,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status text
                  Text(
                    _getStatusText(status),
                    style: SFPro.font(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(status),
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // Title
                  Text(
                    title,
                    style: SFPro.font(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),

                  // Restaurant count or message
                  if (status == 'completed')
                    if (valid && restaurants.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF34C759).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: const Color(0xFF34C759).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.location_solid,
                              size: 14.sp,
                              color: const Color(0xFF34C759),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${restaurants.length} ${restaurants.length == 1 ? "place" : "places"}',
                              style: SFPro.font(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF34C759),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9500).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: const Color(0xFFFF9500).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'No places found',
                          style: SFPro.font(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFFF9500),
                          ),
                        ),
                      ),

                  // Processing indicator
                  if (status != 'completed' && status != 'error') ...[
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.r),
                      child: LinearProgressIndicator(
                        backgroundColor: const Color(0xFFE5E5EA),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStatusColor(status),
                        ),
                        minHeight: 3.h,
                      ),
                    ),
                  ],

                  // Timestamp
                  SizedBox(height: 8.h),
                  Text(
                    _formatTimestamp(createdAt),
                    style: SFPro.font(
                      fontSize: 12.sp,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF7F8FA),
      child: Center(
        child: Icon(
          CupertinoIcons.film,
          size: 48.sp,
          color: const Color(0xFFD1D1D6),
        ),
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'Just now';

    try {
      final dateTime = DateTime.parse(timestamp);
      return timeago.format(dateTime, locale: 'en_short');
    } catch (e) {
      return 'Just now';
    }
  }
}

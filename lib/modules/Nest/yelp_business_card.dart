import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yelpable/models/yelp_metadata_model.dart';
import 'package:yelpable/utils/sf_font.dart';

class YelpBusinessCard extends StatefulWidget {
  final Business business;
  final bool isCurrentUser;

  const YelpBusinessCard({
    super.key,
    required this.business,
    this.isCurrentUser = false,
  });

  @override
  State<YelpBusinessCard> createState() => _YelpBusinessCardState();
}

class _YelpBusinessCardState extends State<YelpBusinessCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Business get business => widget.business;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.w,
      margin: EdgeInsets.only(right: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Gallery
              if (widget.business.contextualInfo?.photos?.isNotEmpty == true)
                _buildImageGallery(),

              // Content
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Business Name
                        Text(
                          widget.business.name ?? 'Unknown Business',
                          style: SFPro.font(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),

                        // Rating & Reviews
                        _buildRatingRow(),
                        SizedBox(height: 8.h),

                        // Categories
                        if (widget.business.categories?.isNotEmpty == true)
                          _buildCategories(),

                        // Summary
                        if (widget.business.summaries?.short != null) ...[
                          SizedBox(height: 8.h),
                          Text(
                            widget.business.summaries!.short!,
                            style: SFPro.font(
                              fontSize: 13.sp,
                              color: const Color(0xFF3C3C43),
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        SizedBox(height: 10.h),

                        // Attributes Row
                        _buildAttributesRow(),

                        SizedBox(height: 10.h),

                        // Location
                        if (widget.business.location?.formattedAddress != null)
                          _buildLocationRow(),

                        SizedBox(height: 10.h),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,

                      children: [
                        // Action Buttons
                        _buildActionButtons(context),
                        SizedBox(height: 10.h),
                      ],
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

  Widget _buildImageGallery() {
    final photos = business.contextualInfo!.photos!;
    final imageCount = photos.length > 3 ? 3 : photos.length;

    return Stack(
      children: [
        SizedBox(
          height: 140.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: imageCount,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return _buildSingleImage(photos[index].originalUrl ?? '');
            },
          ),
        ),

        // 🔹 Dots Indicator
        Positioned(
          bottom: 8.h,
          left: 0,
          right: 0,
          child: _buildImageIndicators(imageCount),
        ),
      ],
    );
  }

  Widget _buildImageIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: isActive ? 8.w : 6.w,
          height: isActive ? 8.w : 6.w,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildSingleImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: 160.h,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildImageShimmer(),
        errorWidget: (context, url, error) => Container(
          height: 160.h,
          color: const Color(0xFFF7F8FA),
          child: Icon(
            CupertinoIcons.photo,
            size: 48.sp,
            color: const Color(0xFFD1D1D6),
          ),
        ),
      ),
    );
  }

  Widget _buildImageShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E5EA),
      highlightColor: const Color(0xFFF7F8FA),
      child: Container(height: 160.h, color: Colors.white),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        // Stars
        ...List.generate(5, (index) {
          final rating = widget.business.rating ?? 0;
          final fullStars = rating.floor();
          final hasHalfStar = (rating - fullStars) >= 0.5;

          if (index < fullStars) {
            return Icon(
              CupertinoIcons.star_fill,
              size: 14.sp,
              color: const Color(0xFFFF6B35),
            );
          } else if (index == fullStars && hasHalfStar) {
            return Icon(
              CupertinoIcons.star_lefthalf_fill,
              size: 14.sp,
              color: const Color(0xFFFF6B35),
            );
          } else {
            return Icon(
              CupertinoIcons.star,
              size: 14.sp,
              color: const Color(0xFFD1D1D6),
            );
          }
        }),
        SizedBox(width: 6.w),
        Text(
          '${widget.business.rating?.toStringAsFixed(1) ?? '0.0'}',
          style: SFPro.font(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        if (widget.business.reviewCount != null) ...[
          SizedBox(width: 4.w),
          Text(
            '(${widget.business.reviewCount})',
            style: SFPro.font(fontSize: 12.sp, color: const Color(0xFF8E8E93)),
          ),
        ],
        if (widget.business.price != null) ...[
          SizedBox(width: 8.w),
          Text(
            widget.business.price!,
            style: SFPro.font(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF34C759),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategories() {
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: widget.business.categories!.take(3).map((category) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            category.title ?? '',
            style: SFPro.font(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3C3C43),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAttributesRow() {
    final attributes = <Widget>[];

    if (widget.business.attributes?.goodForKids == true) {
      attributes.add(
        _buildAttributeChip(CupertinoIcons.smiley, 'Kid Friendly'),
      );
    }

    if (widget.business.attributes?.wiFi == 'free') {
      attributes.add(_buildAttributeChip(CupertinoIcons.wifi, 'Free WiFi'));
    }

    if (widget.business.attributes?.restaurantsTakeOut == true) {
      attributes.add(_buildAttributeChip(CupertinoIcons.bag, 'Takeout'));
    }

    if (widget.business.attributes?.restaurantsDelivery == true) {
      attributes.add(_buildAttributeChip(CupertinoIcons.car, 'Delivery'));
    }

    if (widget.business.attributes?.wheelchairAccessible == true) {
      attributes.add(
        _buildAttributeChip(CupertinoIcons.person_2, 'Accessible'),
      );
    }

    if (attributes.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: attributes.take(3).toList(),
    );
  }

  Widget _buildAttributeChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F5FF),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: const Color(0xFF007AFF).withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: const Color(0xFF007AFF)),
          SizedBox(width: 4.w),
          Text(
            label,
            style: SFPro.font(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF007AFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow() {
    return Row(
      children: [
        Icon(
          CupertinoIcons.location_solid,
          size: 14.sp,
          color: const Color(0xFFFF3B30),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            widget.business.location!.formattedAddress!,
            style: SFPro.font(fontSize: 12.sp, color: const Color(0xFF3C3C43)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CupertinoButton(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            color: const Color(0xFF007AFF),
            borderRadius: BorderRadius.circular(10.r),
            onPressed: () => _openYelpPage(widget.business.url),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.arrow_up_right_square,
                  size: 16.sp,
                  color: Colors.white,
                ),
                SizedBox(width: 6.w),
                Text(
                  'View on Yelp',
                  style: SFPro.font(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.business.phone?.isNotEmpty == true) ...[
          SizedBox(width: 8.w),
          CupertinoButton(
            padding: EdgeInsets.all(10.w),
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(10.r),
            onPressed: () => _makePhoneCall(widget.business.phone!),
            child: Icon(
              CupertinoIcons.phone_fill,
              size: 18.sp,
              color: const Color(0xFF34C759),
            ),
          ),
        ],
        if (widget.business.coordinates?.latitude != null &&
            widget.business.coordinates?.longitude != null) ...[
          SizedBox(width: 8.w),
          CupertinoButton(
            padding: EdgeInsets.all(10.w),
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(10.r),
            onPressed: () => _openMaps(
              widget.business.coordinates!.latitude!,
              widget.business.coordinates!.longitude!,
            ),
            child: Icon(
              CupertinoIcons.map_fill,
              size: 18.sp,
              color: const Color(0xFFFF3B30),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _openYelpPage(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMaps(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

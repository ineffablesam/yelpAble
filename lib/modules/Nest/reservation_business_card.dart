import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yelpable/models/yelp_metadata_model.dart';
import 'package:yelpable/modules/Nest/reservation_bottom_sheet.dart';
import 'package:yelpable/utils/sf_font.dart';

class ReservationBusinessCard extends StatefulWidget {
  final Business business;
  final bool isCurrentUser;
  final VoidCallback onReservationConfirmed;

  const ReservationBusinessCard({
    super.key,
    required this.business,
    required this.onReservationConfirmed,
    this.isCurrentUser = false,
  });

  @override
  State<ReservationBusinessCard> createState() =>
      _ReservationBusinessCardState();
}

class _ReservationBusinessCardState extends State<ReservationBusinessCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _partySize = 2;
  String _selectedTimeSlot = '7:00 PM';

  // Fake time slots
  final List<String> _timeSlots = [
    '7:30 PM',
    '8:00 PM',
    '8:30 PM',
    '9:00 PM',
    '9:30 PM',
  ];

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

                        // Location
                        if (widget.business.location?.formattedAddress != null)
                          _buildLocationRow(),

                        SizedBox(height: 12.h),

                        // Party Size Selector
                        _buildPartySizeSelector(),

                        SizedBox(height: 12.h),

                        // Time Slot Selector
                        _buildTimeSlotSelector(),

                        SizedBox(height: 10.h),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Reservation Button
                        _buildReservationButton(context),
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

  Widget _buildPartySizeSelector() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Party Size',
          style: SFPro.font(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        10.horizontalSpace,
        Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCounterButton(
              icon: CupertinoIcons.minus,
              onTap: () {
                if (_partySize > 1) {
                  setState(() => _partySize--);
                }
              },
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 25.w,
              height: 25.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: const Color(0xFF007AFF), width: 2),
              ),
              child: Center(
                child: Text(
                  '$_partySize',
                  style: SFPro.font(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF007AFF),
                  ),
                ),
              ),
            ),
            _buildCounterButton(
              icon: CupertinoIcons.plus,
              onTap: () {
                if (_partySize < 20) {
                  setState(() => _partySize++);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22.w,
        height: 22.w,
        decoration: BoxDecoration(
          color: const Color(0xFF007AFF),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: Colors.white, size: 14.sp),
      ),
    );
  }

  Widget _buildTimeSlotSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time',
          style: SFPro.font(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _timeSlots.map((slot) {
            final isSelected = slot == _selectedTimeSlot;
            return GestureDetector(
              onTap: () => setState(() => _selectedTimeSlot = slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF007AFF)
                      : const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF007AFF)
                        : const Color(0xFFE5E5EA),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  slot,
                  style: SFPro.font(
                    fontSize: 12.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF3C3C43),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReservationButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        color: const Color(0xFF007AFF),
        borderRadius: BorderRadius.circular(10.r),
        onPressed: () => _showReservationSheet(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.calendar_badge_plus,
              size: 18.sp,
              color: Colors.white,
            ),
            SizedBox(width: 8.w),
            Text(
              'Make Reservation',
              style: SFPro.font(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReservationSheet(BuildContext context) {
    Get.bottomSheet(
      ReservationBottomSheet(
        business: business,
        partySize: _partySize,
        timeSlot: _selectedTimeSlot,
        onConfirmed: widget.onReservationConfirmed,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
    );
  }
}

class ReservationConfirmationCard extends StatelessWidget {
  final String businessName;
  final int partySize;
  final String timeSlot;
  final String? businessAddress;
  final bool isCurrentUser;

  const ReservationConfirmationCard({
    super.key,
    required this.businessName,
    required this.partySize,
    required this.timeSlot,
    this.businessAddress,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 8.h,
        bottom: 4.h,
        left: isCurrentUser ? 60.w : 30.w,
        right: isCurrentUser ? 30.w : 60.w,
      ),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF007AFF).withOpacity(0.1),
            const Color(0xFF34C759).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF007AFF).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with checkmark icon
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.check_mark,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reservation Confirmed',
                      style: SFPro.font(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Your table is booked!',
                      style: SFPro.font(
                        fontSize: 13.sp,
                        color: const Color(0xFF34C759),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Divider
          Container(height: 1, color: const Color(0xFFE5E5EA)),

          SizedBox(height: 16.h),

          // Restaurant Name
          Row(
            children: [
              Icon(
                CupertinoIcons.building_2_fill,
                size: 18.sp,
                color: const Color(0xFF007AFF),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  businessName,
                  style: SFPro.font(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),

          if (businessAddress != null) ...[
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.location_solid,
                  size: 16.sp,
                  color: const Color(0xFF8E8E93),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    businessAddress!,
                    style: SFPro.font(
                      fontSize: 13.sp,
                      color: const Color(0xFF8E8E93),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 16.h),

          // Reservation Details
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE5E5EA)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    CupertinoIcons.person_2_fill,
                    'Party Size',
                    '$partySize guests',
                  ),
                ),
                Container(
                  width: 1,
                  height: 40.h,
                  color: const Color(0xFFE5E5EA),
                ),
                Expanded(
                  child: _buildDetailItem(
                    CupertinoIcons.clock_fill,
                    'Time',
                    timeSlot,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: CupertinoIcons.calendar_badge_plus,
                  label: 'Add to Calendar',
                  color: const Color(0xFF007AFF),
                  onTap: () {
                    // Add to calendar logic
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildActionButton(
                  icon: CupertinoIcons.phone_fill,
                  label: 'Call Restaurant',
                  color: const Color(0xFF34C759),
                  onTap: () {
                    // Call restaurant logic
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Info note
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFFFE082), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.info_circle_fill,
                  size: 16.sp,
                  color: const Color(0xFFFFA726),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Please arrive 10 minutes early. Confirmation sent to your email.',
                    style: SFPro.font(
                      fontSize: 12.sp,
                      color: const Color(0xFF795548),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20.sp, color: const Color(0xFF007AFF)),
        SizedBox(height: 6.h),
        Text(
          label,
          style: SFPro.font(fontSize: 11.sp, color: const Color(0xFF8E8E93)),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: SFPro.font(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18.sp, color: color),
            SizedBox(height: 4.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: SFPro.font(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

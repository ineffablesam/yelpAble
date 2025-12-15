import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yelpable/utils/sf_font.dart';

import '../../models/yelp_metadata_model.dart';

class BusinessCarouselCard extends StatefulWidget {
  final List<Business> businesses;

  const BusinessCarouselCard({Key? key, required this.businesses})
    : super(key: key);

  @override
  State<BusinessCarouselCard> createState() => _BusinessCarouselCardState();
}

class _BusinessCarouselCardState extends State<BusinessCarouselCard> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.businesses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 260.h,
          width: 230.w,
          child: Center(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              padEnds: false,
              clipBehavior: Clip.none,
              itemCount: widget.businesses.length,
              itemBuilder: (context, index) {
                final business = widget.businesses[index];
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _BusinessCard(business: business),
                );
              },
            ),
          ),
        ),
        if (widget.businesses.length > 1) ...[
          SizedBox(height: 8.h), // Reduced from 12.h
          Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: widget.businesses.length,
              effect: WormEffect(
                dotHeight: 6.h, // Reduced from 8.h
                dotWidth: 6.w, // Reduced from 8.w
                activeDotColor: const Color(0xFF6366F1),
                dotColor: const Color(0xFFD1D5DB),
                spacing: 4.w, // Reduced from 6.w
              ),
            ),
          ),
        ],
        10.verticalSpace,
      ],
    );
  }
}

class _BusinessCard extends StatefulWidget {
  final Business business;

  const _BusinessCard({required this.business});

  @override
  State<_BusinessCard> createState() => _BusinessCardState();
}

class _BusinessCardState extends State<_BusinessCard> {
  final PageController _imageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImages =
        widget.business.contextualInfo?.photos?.isNotEmpty ?? false;
    final images = widget.business.contextualInfo?.photos ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r), // Reduced from 20.r
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06), // Reduced shadow
            blurRadius: 15, // Reduced from 20
            offset: Offset(0, 3.h), // Reduced from 4.h
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Carousel
          if (hasImages)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: Stack(
                children: [
                  SizedBox(
                    height: 110.h,
                    width: 190.w,
                    child: PageView.builder(
                      controller: _imageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          images[index].originalUrl ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFF3F4F6),
                              child: Icon(
                                Icons.restaurant,
                                size: 32.sp, // Reduced from 48.sp
                                color: const Color(0xFF9CA3AF),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 6.h, // Reduced from 8.h
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w, // Reduced from 8.w
                            vertical: 3.h, // Reduced from 4.h
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              images.length,
                              (index) => Container(
                                margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                                width: 5.w, // Reduced from 6.w
                                height: 5.h, // Reduced from 6.h
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            Container(
              height: 110.h, // Reduced from 160.h
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant,
                  size: 32.sp, // Reduced from 48.sp
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w), // Reduced from 16.w
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Rating
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 5,
                    children: [
                      Text(
                        widget.business.name ?? 'Unknown',
                        style: SFPro.font(
                          fontSize: 13.sp, // Reduced from 16.sp
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.business.rating != null) ...[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w, // Reduced from 8.w
                                vertical: 3.h, // Reduced from 4.h
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 11.sp, // Reduced from 14.sp
                                    color: const Color(0xFFFBBF24),
                                  ),
                                  SizedBox(width: 3.w), // Reduced from 4.w
                                  Text(
                                    widget.business.rating.toString(),
                                    style: SFPro.font(
                                      fontSize: 10.sp, // Reduced from 12.sp
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  4.verticalSpace,
                  // Categories
                  if (widget.business.categories?.isNotEmpty ?? false)
                    Text(
                      widget.business.categories!
                          .map((c) => c.title)
                          .join(' • '),
                      style: SFPro.font(
                        fontSize: 10.sp, // Reduced from 12.sp
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  5.verticalSpace,
                  // Address
                  if (widget.business.location?.formattedAddress != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 11.sp, // Reduced from 14.sp
                          color: const Color(0xFF64748B),
                        ),
                        SizedBox(width: 3.w), // Reduced from 4.w
                        Expanded(
                          child: Text(
                            widget.business.location!.formattedAddress!,
                            style: SFPro.font(
                              fontSize: 9.sp, // Reduced from 11.sp
                              color: const Color(0xFF64748B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  const Spacer(),
                  // Action Buttons
                  Row(
                    children: [
                      if (widget.business.phone != null)
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.phone_outlined,
                            label: 'Call',
                            onTap: () async {
                              final phone = widget.business.phone!.replaceAll(
                                RegExp(r'[^\d+]'),
                                '',
                              );
                              final uri = Uri.parse('tel:$phone');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                          ),
                        ),
                      if (widget.business.phone != null) SizedBox(width: 6.w),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.directions_outlined,
                          label: 'Directions',
                          onTap: () async {
                            final lat = widget.business.coordinates?.latitude;
                            final lng = widget.business.coordinates?.longitude;
                            if (lat != null && lng != null) {
                              final uri = Uri.parse(
                                'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
                              );
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 6.w), // Reduced from 8.w
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.open_in_new,
                          label: 'View',
                          isPrimary: true,
                          onTap: () async {
                            if (widget.business.url != null) {
                              final uri = Uri.parse(widget.business.url!);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            }
                          },
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
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h), // Reduced from 10.h
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF6366F1) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8.r), // Reduced from 10.r
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15.sp, // Reduced from 18.sp
              color: isPrimary ? Colors.white : const Color(0xFF64748B),
            ),
            SizedBox(height: 3.h), // Reduced from 4.h
            Text(
              label,
              style: SFPro.font(
                fontSize: 9.sp, // Reduced from 10.sp
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

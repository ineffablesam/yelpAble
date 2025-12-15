import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:yelpable/utils/sf_font.dart';

import '../../models/yelp_places_business.dart';
import '../../utils/custom_sliding_up_panel.dart';
import 'Controller/home_controller.dart';
import 'business_detail_modal.dart';
import 'filter_bottom_sheet.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFFF8F9FA),
          body: Stack(
            children: [
              // Sliding Panel
              SlidingUpPanel(
                controller: controller.panelController,
                minHeight: 0.56.sh,
                maxHeight: 0.7.sh,
                panelSnapping: true,
                parallaxEnabled: true,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                color: Colors.transparent,
                renderPanelSheet: false,
                panelBuilder: (sc) => _buildPanel(sc, controller),
                body: Stack(
                  children: [
                    // Google Map
                    Obx(
                      () => GoogleMap(
                        mapType: MapType.normal,
                        onMapCreated: (GoogleMapController mapController) {
                          controller.onMapCreated(mapController);
                          controller.clusterManager?.setMapId(
                            mapController.mapId,
                          );
                          mapController.setMapStyle(controller.mapStyle);
                          controller.isMapLoading(false);
                        },
                        initialCameraPosition: CameraPosition(
                          target: controller.currentLocation.value,
                          zoom: 14,
                          tilt: 60,
                          bearing: 0,
                        ),
                        buildingsEnabled: true,
                        tiltGesturesEnabled: true,
                        markers: controller.markers.value,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        compassEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,

                        // Important: Listen to camera movements to update clusters
                        onCameraMove: (CameraPosition position) {
                          controller.clusterManager?.onCameraMove(position);
                        },
                        onCameraIdle: () {
                          controller.clusterManager?.updateMap();
                        },
                      ),
                    ),
                    // if (controller.isMapLoading.value)
                    //   Container(
                    //     color: Colors.white.withOpacity(0.8),
                    //     child: const Center(child: CircularProgressIndicator()),
                    //   ),
                    // Floating Action Buttons
                    Positioned(
                      right: 16.w,
                      bottom: 340.h,
                      child: Column(
                        children: [
                          _buildFAB(
                            icon: Icons.my_location_rounded,
                            onPressed: () {
                              controller.mapController?.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  controller.currentLocation.value,
                                  13,
                                ),
                              );
                            },
                          ),
                          50.verticalSpace,
                        ],
                      ),
                    ),
                    // Loading Overlay
                    Obx(
                      () => controller.isMapLoading.value
                          ? Container(
                              color: Colors.white,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: const Color(0xFF6366F1),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              // Top Search & Filter Bar
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  child: Column(
                    children: [
                      _buildSearchBar(context, controller),
                      SizedBox(height: 12.h),
                      _buildActiveFiltersChips(controller),
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

  Widget _buildFAB({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            width: 48.w,
            height: 48.w,
            alignment: Alignment.center,
            child: Icon(icon, color: const Color(0xFF1F2937), size: 22.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, HomeController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(
              0.3,
            ), // semi-transparent for frosted effect
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.grey.shade600,
              width: 0.4,
            ), // white border
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.onSearchChanged,
                  style: SFPro.font(
                    fontSize: 15.sp,
                    color: const Color(0xFF1F2937),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search restaurants, cafes...',
                    hintStyle: SFPro.font(
                      fontSize: 15.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      color: const Color(0xFF6B7280),
                      size: 20.sp,
                    ),
                    suffixIcon: Obx(
                      () => controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                CupertinoIcons.xmark_circle_fill,
                                color: const Color(0xFF9CA3AF),
                                size: 18.sp,
                              ),
                              onPressed: controller.clearSearch,
                            )
                          : const SizedBox.shrink(),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 4.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.8),
                      const Color(0xFF8B5CF6).withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showFilterSheet(context, controller),
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.slider_horizontal_3,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                          Obx(() {
                            final count = controller.activeFiltersCount;
                            if (count > 0) {
                              return Container(
                                margin: EdgeInsets.only(left: 6.w),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  '$count',
                                  style: SFPro.font(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF6366F1),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFiltersChips(HomeController controller) {
    return Obx(() {
      final hasFilters =
          controller.selectedCategories.isNotEmpty ||
          controller.selectedPrice.isNotEmpty ||
          controller.openNowOnly.value ||
          controller.selectedRadius.value != 5000.0;

      if (!hasFilters) return const SizedBox.shrink();

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (controller.selectedCategories.isNotEmpty)
                        ...controller.selectedCategories.map(
                          (cat) => Padding(
                            padding: EdgeInsets.only(right: 6.w),
                            child: _buildFilterChip(
                              cat,
                              () => controller.toggleCategory(cat),
                            ),
                          ),
                        ),
                      if (controller.selectedPrice.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: _buildFilterChip(
                            controller.selectedPrice.value,
                            () => controller.setPrice(''),
                          ),
                        ),
                      if (controller.openNowOnly.value)
                        Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: _buildFilterChip(
                            'Open Now',
                            controller.toggleOpenNow,
                          ),
                        ),
                      if (controller.selectedRadius.value != 5000.0)
                        Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: _buildFilterChip(
                            '${(controller.selectedRadius.value / 1000).toStringAsFixed(1)}km',
                            () => controller.selectedRadius.value = 5000.0,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: controller.clearFilters,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Clear',
                    style: SFPro.font(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: SFPro.font(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6366F1),
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              CupertinoIcons.xmark,
              size: 14.sp,
              color: const Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel(ScrollController sc, HomeController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFEEEEEE), const Color(0xFFDDDAF8)],
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: EdgeInsets.symmetric(vertical: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // View Toggle & Results Count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    '${controller.filteredBusinesses.length} Places Found',
                    style: SFPro.font(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
                Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        _buildViewToggleButton(
                          icon: CupertinoIcons.list_bullet,
                          isSelected:
                              controller.viewMode.value == ViewMode.list,
                          onTap: () => controller.setViewMode(ViewMode.list),
                        ),
                        _buildViewToggleButton(
                          icon: CupertinoIcons.square_grid_2x2,
                          isSelected:
                              controller.viewMode.value == ViewMode.grid,
                          onTap: () => controller.setViewMode(ViewMode.grid),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Business List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState(controller);
              }

              if (controller.filteredBusinesses.isEmpty) {
                return _buildEmptyState();
              }

              if (controller.viewMode.value == ViewMode.list) {
                return _buildListView(sc, controller);
              } else {
                return _buildGridView(sc, controller);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected
          ? Color(0xFF6366F1).withOpacity(0.8)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.all(10.w),
          child: Icon(
            icon,
            size: 18.sp,
            color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(HomeController controller) {
    return controller.viewMode.value == ViewMode.list
        ? ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: 5,
            itemBuilder: (context, index) => _buildShimmerCard(),
          )
        : GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => _buildShimmerGridCard(),
          );
  }

  Widget _buildListView(ScrollController sc, HomeController controller) {
    return AnimationLimiter(
      child: ListView.builder(
        controller: sc,
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 80.h),
        itemCount: controller.filteredBusinesses.length,
        itemBuilder: (context, index) {
          final business = controller.filteredBusinesses[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildBusinessListCard(context, business, controller),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView(ScrollController sc, HomeController controller) {
    return AnimationLimiter(
      child: GridView.builder(
        controller: sc,
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 80.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        itemCount: controller.filteredBusinesses.length,
        itemBuilder: (context, index) {
          final business = controller.filteredBusinesses[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildBusinessGridCard(context, business, controller),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBusinessListCard(
    BuildContext context,
    YelpBusiness business,
    HomeController controller,
  ) {
    return GestureDetector(
      onTap: () => _showBusinessDetail(context, business),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                bottomLeft: Radius.circular(20.r),
              ),
              child: Hero(
                tag: 'business-${business.id}',
                child: CachedNetworkImage(
                  imageUrl: business.imageUrl ?? '',
                  width: 100.w,
                  height: 120.h,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFF3F4F6),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFFF3F4F6),
                    child: Icon(
                      CupertinoIcons.building_2_fill,
                      color: const Color(0xFFD1D5DB),
                      size: 32.sp,
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            business.name,
                            style: SFPro.font(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (business.price != null)
                          Container(
                            margin: EdgeInsets.only(left: 8.w),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              business.price!,
                              style: SFPro.font(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.star_fill,
                          size: 14.sp,
                          color: const Color(0xFFFBBF24),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          business.rating.toString(),
                          style: SFPro.font(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '(${business.reviewCount})',
                          style: SFPro.font(
                            fontSize: 12.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      business.categories.take(2).join(' • '),
                      style: SFPro.font(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (business.distance != null) ...[
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.location_solid,
                            size: 12.sp,
                            color: const Color(0xFFEF4444),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${(business.distance! / 1000).toStringAsFixed(1)} km away',
                            style: SFPro.font(
                              fontSize: 11.sp,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessGridCard(
    BuildContext context,
    YelpBusiness business,
    HomeController controller,
  ) {
    return GestureDetector(
      onTap: () => _showBusinessDetail(context, business),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              child: Hero(
                tag: 'business-${business.id}',
                child: CachedNetworkImage(
                  imageUrl: business.imageUrl ?? '',
                  width: double.infinity,
                  height: 120.h,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFF3F4F6),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFFF3F4F6),
                    child: Icon(
                      CupertinoIcons.building_2_fill,
                      color: const Color(0xFFD1D5DB),
                      size: 32.sp,
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: SFPro.font(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.star_fill,
                          size: 12.sp,
                          color: const Color(0xFFFBBF24),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          business.rating.toString(),
                          style: SFPro.font(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        if (business.price != null) ...[
                          SizedBox(width: 6.w),
                          Text(
                            business.price!,
                            style: SFPro.font(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      business.categories.first,
                      style: SFPro.font(
                        fontSize: 11.sp,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE5E7EB),
        highlightColor: const Color(0xFFF9FAFB),
        child: Container(
          height: 120.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGridCard() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.search,
            size: 64.sp,
            color: const Color(0xFFD1D5DB),
          ),
          SizedBox(height: 16.h),
          Text(
            'No businesses found',
            style: SFPro.font(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your filters',
            style: SFPro.font(fontSize: 14.sp, color: const Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  void _showBusinessDetail(BuildContext context, YelpBusiness business) {
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        BusinessDetailModal.buildPage(context, business),
      ],
    );
  }

  void _showFilterSheet(BuildContext context, HomeController controller) {
    Get.bottomSheet(
      FilterSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

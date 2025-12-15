import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:yelpable/utils/colors.dart';
import 'package:yelpable/utils/sf_font.dart';

import '../Auth/Controller/auth_controller.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFEEEEEE), const Color(0xFFDDDAF8)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Simple App Bar
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.scaffoldBg,
              surfaceTintColor: AppColors.scaffoldBg,
              elevation: 0,
              centerTitle: false,
              title: Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Yelpable',
                    style: SFPro.font(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  // Supercharged by Yelp Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.r),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      color: Colors.white,
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
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[900],
                            ),
                          ),
                          VerticalDivider(
                            indent: 3,
                            endIndent: 2,
                            color: Colors.black.withOpacity(0.2),
                          ),
                          SvgPicture.asset(
                            'assets/images/yelp.svg',
                            width: 28.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    LucideIcons.settings,
                    color: const Color(0xFF64748B),
                    size: 22.sp,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.logOut,
                    color: const Color(0xFF64748B),
                    size: 22.sp,
                  ),
                  onPressed: controller.logout,
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFFEEEEEE), const Color(0xFFDDDAF8)],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 32.h),

                      // Profile Section
                      Obx(() {
                        final user = controller.currentUser.value;
                        return TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 600),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: Row(
                            children: [
                              // Profile Picture
                              GestureDetector(
                                onTap: controller.showImageSourceDialog,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF6366F1,
                                        ).withOpacity(0.15),
                                        blurRadius: 30,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 40.r,
                                        backgroundColor: Colors.white,
                                        backgroundImage:
                                            user?.profilePictureUrl != null
                                            ? NetworkImage(
                                                user!.profilePictureUrl!,
                                              )
                                            : null,
                                        child: user?.profilePictureUrl == null
                                            ? Icon(
                                                LucideIcons.user,
                                                size: 50.sp,
                                                color: const Color(0xFF6366F1),
                                              )
                                            : null,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(4.w),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6366F1),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                          ),
                                          child: Icon(
                                            LucideIcons.camera,
                                            size: 12.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              20.horizontalSpace,
                              // Name
                              Column(
                                spacing: 5,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    user?.name ?? 'Guest User',
                                    style: SFPro.font(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1E293B),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  // Email
                                  Text(
                                    user?.email ?? 'guest@yelpable.com',
                                    style: SFPro.font(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  4.verticalSpace,
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        border: Border.all(
                                          color: const Color(0x93F5F5F5),
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.06,
                                            ),
                                            blurRadius: 12,
                                            offset: Offset(0, 4.h),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            LucideIcons.pen,
                                            size: 10.sp,
                                            color: const Color(0xFF6366F1),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Edit Profile',
                                            style: SFPro.font(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF6366F1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      SizedBox(height: 32.h),

                      // Stats Section
                      _buildStatsSection(),

                      SizedBox(height: 24.h),

                      // AI Features Section
                      _buildSectionTitle('AI Features'),
                      SizedBox(height: 12.h),
                      _buildFeatureCard(
                        icon: LucideIcons.mic,
                        title: 'Orion',
                        subtitle: 'Voice conversations with Yelp AI',
                        iconColor: const Color(0xFF6366F1),
                      ),
                      SizedBox(height: 12.h),
                      _buildFeatureCard(
                        icon: LucideIcons.users,
                        title: 'Nest',
                        subtitle: 'Group rooms with AI agent',
                        iconColor: const Color(0xFF10B981),
                      ),
                      SizedBox(height: 12.h),
                      _buildFeatureCard(
                        icon: LucideIcons.video,
                        title: 'Reely',
                        subtitle: 'Share reels, discover spots',
                        iconColor: const Color(0xFFEC4899),
                      ),
                      SizedBox(height: 24.h),

                      // Preferences Section
                      Obx(() {
                        final prefs = controller.currentUser.value?.preferences;
                        if (prefs != null && prefs.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Your Preferences'),
                              SizedBox(height: 12.h),
                              _buildPreferencesChips(prefs),
                              SizedBox(height: 24.h),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      }),

                      // Quick Actions
                      _buildSectionTitle('Quick Actions'),
                      SizedBox(height: 12.h),
                      _buildActionTile(
                        icon: LucideIcons.bell,
                        title: 'Notifications',
                        subtitle: 'Manage your alerts',
                        onTap: () {},
                      ),
                      SizedBox(height: 8.h),
                      _buildActionTile(
                        icon: LucideIcons.shield,
                        title: 'Privacy & Security',
                        subtitle: 'Control your data',
                        onTap: () {},
                      ),
                      SizedBox(height: 8.h),
                      _buildActionTile(
                        icon: LucideIcons.lifeBuoy,
                        title: 'Help & Support',
                        subtitle: 'Get assistance',
                        onTap: () {},
                      ),

                      SizedBox(height: 32.h),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(emoji: '🔥', value: '12', label: 'Streak'),
          Container(
            width: 1,
            height: 40.h,
            color: Colors.grey.withOpacity(0.2),
          ),
          _buildStatItem(emoji: '⭐', value: '47', label: 'Reviews'),
          Container(
            width: 1,
            height: 40.h,
            color: Colors.grey.withOpacity(0.2),
          ),
          _buildStatItem(emoji: '📍', value: '128', label: 'Saved'),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String emoji,
    required String value,
    required String label,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animation),
          child: Opacity(opacity: animation, child: child),
        );
      },
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 28.sp)),
          SizedBox(height: 8.h),
          Text(
            value,
            style: SFPro.font(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: SFPro.font(fontSize: 12.sp, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: SFPro.font(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SFPro.font(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: SFPro.font(
                    fontSize: 13.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            LucideIcons.chevronRight,
            color: const Color(0xFF94A3B8),
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesChips(List<String> preferences) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: preferences.map((pref) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    pref,
                    style: SFPro.font(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: const Color(0xFF64748B), size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: SFPro.font(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: SFPro.font(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: const Color(0xFF94A3B8),
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AuthController controller) {
    return Obx(() {
      return GestureDetector(
        onTap: controller.isLoading.value ? null : controller.logout,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFFEF4444).withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (controller.isLoading.value)
                SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Color(0xFFEF4444)),
                  ),
                )
              else
                Icon(
                  LucideIcons.logOut,
                  color: const Color(0xFFEF4444),
                  size: 20.sp,
                ),
              SizedBox(width: 12.w),
              Text(
                controller.isLoading.value ? 'Logging out...' : 'Logout',
                style: SFPro.font(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:yelpable/modules/Auth/Controller/auth_controller.dart';
import 'package:yelpable/utils/colors.dart';

import '../../utils/custom_tap.dart';
import '../../utils/sf_font.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: WillPopScope(
        onWillPop: () async {
          if (controller.currentStep.value == 1) {
            controller.currentStep.value = 0;
            return false;
          }
          return true;
        },
        child: CustomScrollView(
          slivers: [
            Obx(
              () => SliverAppBar(
                backgroundColor: AppColors.scaffoldBg,
                surfaceTintColor: AppColors.scaffoldBg,
                pinned: true,
                elevation: 0,
                expandedHeight: 40,
                toolbarHeight: 40,
                centerTitle: false,
                leading: controller.currentStep.value == 1
                    ? IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () {
                          controller.currentStep.value = 0;
                        },
                      )
                    : null,
                title: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PageTransitionSwitcher(
                      duration: const Duration(milliseconds: 300),
                      reverse: controller.currentStep.value == 0,
                      transitionBuilder:
                          (child, primaryAnimation, secondaryAnimation) {
                            return SharedAxisTransition(
                              animation: primaryAnimation,
                              secondaryAnimation: secondaryAnimation,
                              transitionType: SharedAxisTransitionType.vertical,
                              fillColor: AppColors.scaffoldBg,
                              child: child,
                            );
                          },
                      child: controller.currentStep.value == 0
                          ? Text(
                              "Enter Your Information",
                              key: const ValueKey(0),
                              textAlign: TextAlign.left,
                              style: SFPro.font(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            )
                          : Text(
                              "Select Your Preferences",
                              key: const ValueKey(1),
                              textAlign: TextAlign.left,
                              style: SFPro.font(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: true,
              child: Obx(
                () => PageTransitionSwitcher(
                  duration: const Duration(milliseconds: 400),
                  reverse: controller.currentStep.value == 0,
                  transitionBuilder:
                      (child, primaryAnimation, secondaryAnimation) {
                        return SharedAxisTransition(
                          animation: primaryAnimation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.horizontal,
                          fillColor: AppColors.scaffoldBg,

                          child: child,
                        );
                      },
                  child: controller.currentStep.value == 0
                      ? _buildStepOne(
                          controller.nameController,
                          controller.emailController,
                          controller.currentStep,
                          controller.formKey,
                        )
                      : _buildStepTwo(controller.selectedPreferences),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            10.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: CustomTap(
                      onTap: () {
                        HapticFeedback.heavyImpact();

                        if (controller.currentStep.value == 0) {
                          // Step 1: Validate form
                          final formKey = controller.formKey;
                          if (formKey.currentState!.validate()) {
                            // Move to step 2
                            controller.currentStep.value = 1;
                          }
                        } else {
                          // Step 2: Validate preferences and submit
                          if (controller.selectedPreferences.isNotEmpty) {
                            // Submit
                            controller.doContinue();
                          } else {
                            Get.snackbar(
                              "Required",
                              "Please select at least one preference",
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        }
                      },
                      child: Container(
                        height: 46.h,
                        width: 200.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Text(
                          controller.currentStep.value == 0
                              ? "Continue"
                              : "Get Started",
                          style: SFPro.font(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            20.verticalSpace,
          ],
        ),
      ),
    );
  }

  Widget _buildStepOne(
    TextEditingController nameController,
    TextEditingController emailController,
    RxInt currentStep,
    GlobalKey<FormState> formKey,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Form(
        key: formKey,
        child: Column(
          key: ValueKey<int>(0),
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Let's get to know you",
              style: SFPro.font(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            Text(
              "We'll use this information to personalize your experience",
              style: SFPro.font(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 10.h),
            Obx(
              () => CustomTap(
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller.showImageSourceDialog();
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40.r,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: controller.profileImage.value != null
                          ? FileImage(controller.profileImage.value!)
                          : null,
                      child: controller.profileImage.value == null
                          ? Icon(
                              SolarIconsOutline.cameraMinimalistic,
                              size: 24.sp,
                              color: Colors.black38,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          controller.profileImage.value == null
                              ? SolarIconsOutline.gallery
                              : SolarIconsOutline.pen,
                          size: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Name",
              style: SFPro.font(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: "Enter your name",
                hintStyle: SFPro.font(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black38,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: Icon(
                  SolarIconsOutline.user,
                  color: Colors.black38,
                  size: 20.sp,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.black87, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                ),
                errorStyle: SFPro.font(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.red,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
              style: SFPro.font(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Email",
              style: SFPro.font(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!GetUtils.isEmail(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(
                  SolarIconsOutline.letter,
                  color: Colors.black38,
                  size: 20.sp,
                ),
                hintText: "Enter your email",
                hintStyle: SFPro.font(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black38,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.black87, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                ),
                errorStyle: SFPro.font(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.red,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
              style: SFPro.font(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTwo(RxList<String> selectedPreferences) {
    final Map<String, List<Map<String, String>>> chipSections = {
      'Accessibility Needs / Disabilities': [
        {'emoji': '👀', 'label': 'Visual'},
        {'emoji': '🦽', 'label': 'Wheelchair'},
        {'emoji': '👂', 'label': 'Hearing'},
        {'emoji': '🧠', 'label': 'Cognitive'},
        {'emoji': '🧓', 'label': 'Elderly'},
        {'emoji': '🤰', 'label': 'Pregnant'},
        {'emoji': '', 'label': 'None'},
      ],
      'Environment & Place Preferences': [
        {'emoji': '♿', 'label': 'Wheelchair Access'},
        {'emoji': '🔇', 'label': 'Quiet / Low Noise'},
        {'emoji': '💡', 'label': 'Good Lighting'},
        {'emoji': '🧭', 'label': 'Simple Navigation'},
        {'emoji': '🐶', 'label': 'Pet-friendly'},
        {'emoji': '👨‍👩‍👧', 'label': 'Family-friendly'},
        {'emoji': '🌳', 'label': 'Outdoor Seating'},
      ],
      'Service & Business Preferences': [
        {'emoji': '☕', 'label': 'Cafés'},
        {'emoji': '🍽️', 'label': 'Restaurants'},
        {'emoji': '💇‍♀️', 'label': 'Salons'},
        {'emoji': '🏋️', 'label': 'Gyms'},
        {'emoji': '🏥', 'label': 'Healthcare'},
        {'emoji': '🛍️', 'label': 'Shopping'},
        {'emoji': '⭐', 'label': 'Ratings Important'},
        {'emoji': '💰', 'label': 'Budget-Friendly'},
      ],
    };

    return SingleChildScrollView(
      key: ValueKey<int>(1),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              itemCount: chipSections.entries.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final entry = chipSections.entries.elementAt(index);
                return Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: SFPro.font(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: entry.value.map((pref) {
                          return Obx(() {
                            final isSelected = selectedPreferences.contains(
                              pref['label'],
                            );
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                if (isSelected) {
                                  selectedPreferences.remove(pref['label']);
                                } else {
                                  selectedPreferences.add(pref['label']!);
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? RadialGradient(
                                          colors: [
                                            Color(0xffFF5E5E),
                                            Color(0xffFF1A1A),
                                          ],
                                          center: Alignment(-0.5, -0.5),
                                          radius: 1.0,
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? Color(0xffFF1A1A)
                                        : Colors.grey.shade300,
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (pref['emoji']!.isNotEmpty) ...[
                                      Text(
                                        pref['emoji']!,
                                        style: SFPro.font(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                    ],
                                    Text(
                                      pref['label']!,
                                      style: SFPro.font(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.grey.shade100
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

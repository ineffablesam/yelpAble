import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';
import 'package:yelpable/modules/Auth/Controller/auth_controller.dart';
import 'package:yelpable/utils/assets.dart';
import 'package:yelpable/utils/colors.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());
    return Scaffold(
      backgroundColor: AppColors.appPrimary,
      body: Container(
        height: 1.sh,
        width: 1.sw,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage(AppAssets.authBg)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SafeArea(
                    child: SvgPicture.asset(
                      AppAssets.logoFullWhiteColorSVG,
                      width: 90.w,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Billit Now",
                        style: GoogleFonts.encodeSansSemiExpanded(
                          color: Colors.black,
                          fontSize: 34.sp,
                          fontWeight: FontWeight.w600,
                          textStyle: TextStyle(letterSpacing: .5),
                        ),
                      ),
                      Text(
                        "Empowering Businesses with Fast, Reliable Invoicing Solutions.",
                        style: GoogleFonts.dmSans(
                          color: Colors.grey.shade800,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                40.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: NeoPopButton(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2.sp),
                          rightShadowColor: Colors.black,
                          bottomShadowColor: Colors.black,
                          onTapUp: () {},
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(AntDesign.google),
                                4.horizontalSpace,
                                Text(
                                  "Login with Apple",
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
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
                10.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: NeoPopButton(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2.sp),
                          rightShadowColor: Colors.black,
                          bottomShadowColor: Colors.black,
                          onTapUp: () {},
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.apple),
                                4.horizontalSpace,
                                Text(
                                  "Login with Apple",
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
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
                10.verticalSpace,
                Divider(color: Colors.grey.shade800, indent: 12, endIndent: 12),
                10.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: NeoPopButton(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.black, width: 2.sp),
                          rightShadowColor: Colors.black,
                          bottomShadowColor: Colors.black,
                          onTapUp: () {
                            controller.doSkipAuth();
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "SKIP",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                25.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "CRAFTED BY SAMUEL PHILIP",
                      style: GoogleFonts.ibmPlexMono(
                        color: Colors.grey.shade800,
                        textStyle: TextStyle(letterSpacing: .5),
                      ),
                    ),
                  ],
                ),
                20.verticalSpace,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:yelpable/modules/Account/account_view.dart';
import 'package:yelpable/modules/Home/home_view.dart';

import 'Controller/layout_controller.dart';

class LayoutView extends GetView<LayoutController> {
  const LayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF0373F3);
    const inactiveColor = Color(0XFFBCBCBC);
    final bottomNavBarController = Get.put(LayoutController());
    return Obx(() {
      if (bottomNavBarController.isLoading.value) {
        return const Scaffold(
          backgroundColor: Color(0XFFFFFFFF),
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0XFF0373F3),
              strokeWidth: 0.8,
            ),
          ),
        );
      }

      List<Widget> _userPages = [HomeView(), AccountView()];
      List<Widget> _userDestinations = [
        NavigationDestination(
          icon: Icon(SolarIconsOutline.home, color: inactiveColor),
          selectedIcon: Icon(SolarIconsBold.home, color: activeColor),
          label: 'Invoice',
          tooltip: '',
        ),
        NavigationDestination(
          icon: Icon(SolarIconsOutline.user, color: inactiveColor),
          selectedIcon: Icon(SolarIconsBold.user, color: activeColor),
          label: 'Account',
          tooltip: '',
        ),
      ];

      final double bottomNavBarHeight = 60.h;
      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 400),
            reverse:
                bottomNavBarController.currentIndex <
                bottomNavBarController.previousPageIndex,
            transitionBuilder: (child, animation, secondaryAnimation) =>
                SharedAxisTransition(
                  fillColor: Colors.white,
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                ),
            child: _userPages.elementAt(bottomNavBarController.currentIndex),
          ),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                (Set<WidgetState> states) =>
                    states.contains(WidgetState.selected)
                    ? GoogleFonts.kantumruyPro(color: activeColor)
                    : GoogleFonts.kantumruyPro(color: inactiveColor),
              ),
            ),
            child: NavigationBar(
              // type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              indicatorColor: Color(0XFF0373F3).withOpacity(0.1),

              // showSelectedLabels: true,
              // showUnselectedLabels: true,
              elevation: 19,
              // selectedLabelStyle: GoogleFonts.kantumruyPro(
              //   fontSize: 12.sp,
              //   fontWeight: FontWeight.w700,
              //   color: activeColor,
              //   height: 1.5.h,
              // ),
              // unselectedLabelStyle: GoogleFonts.kantumruyPro(
              //   fontSize: 12.sp,
              //   fontWeight: FontWeight.w400,
              //   color: Colors.grey,
              // ),
              // selectedItemColor: activeColor,
              // unselectedItemColor: Colors.grey,
              // selectedFontSize: 8.sp,
              // unselectedFontSize: 8.sp,
              // enableFeedback: true,
              destinations: _userDestinations,
              selectedIndex: bottomNavBarController.currentIndex,
              onDestinationSelected: (index) {
                HapticFeedback.lightImpact();
                bottomNavBarController.updatePageIndex(index);
              },
            ),
          ),
        ),
      );
    });
  }
}

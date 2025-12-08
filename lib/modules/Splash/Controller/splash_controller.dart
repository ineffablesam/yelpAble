import 'package:flutter/animation.dart';
import 'package:get/get.dart';

import '../../Onboarding/onboarding_view.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 5), () {
      checkLogin();
    });
  }

  // function to return the 'token' from the shared preferences to navigate to the home page or login page
  Future<void> checkLogin() async {
    Get.off(
      () => const OnboardingView(),
      transition: Transition.fade,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 900),
      fullscreenDialog: true,
    );
  }
}

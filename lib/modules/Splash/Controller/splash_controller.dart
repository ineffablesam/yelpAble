import 'package:get/get.dart';
import 'package:yelpable/modules/Onboarding/onboarding_view.dart';

import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import '../../Layout/layout_view.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 5), () {
      checkLogin();
    });
  }

  // function to return the 'token' from the shared preferences to navigate to the home page or login page
  Future<void> checkLogin() async {
    // Get.off(
    //   () => const OnboardingView(),
    //   transition: Transition.fade,
    //   curve: Curves.easeInOut,
    //   duration: const Duration(milliseconds: 900),
    //   fullscreenDialog: true,
    // );
    try {
      // Check if user data exists locally
      final user = await _userService.getUserLocally();

      if (user != null) {
        // User exists, navigate to home
        currentUser.value = user;
        print("User found: ${user.name}, navigating to home");
        // OR if you have a layout view
        Get.offAll(() => LayoutView());
      } else {
        // No user found, navigate to onboarding
        print("No user found, navigating to onboarding");

        // Navigate to Auth/Onboarding
        Get.offAll(() => OnboardingView());
      }
    } catch (e) {
      print("Error checking user: $e");

      // On error, navigate to onboarding to be safe
      Get.offAll(() => OnboardingView());
    }
  }
}

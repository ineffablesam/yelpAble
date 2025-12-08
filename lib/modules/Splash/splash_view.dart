import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../utils/assets.dart';
import '../../utils/colors.dart';
import 'Controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final SplashController controller = Get.put(SplashController());

    bool hasVibrated = false;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Center(
        child: Lottie.asset(
          AppAssets.splashLottie,
          width: 1.sw,
          height: 1.sh,
          frameRate: FrameRate.max,

          onLoaded: (composition) {
            final animController = AnimationController(
              vsync: controller,
              duration: composition.duration,
            );

            animController.addListener(() {
              final currentTimeMs =
                  (animController.value * composition.duration.inMilliseconds)
                      .round();

              if (!hasVibrated && currentTimeMs >= 1340) {
                hasVibrated = true;
                HapticFeedback.selectionClick();
              }
            });
            animController.addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                controller.checkLogin();
              }
            });
            // animController.forward();
          },
        ),
      ),
    );
  }
}

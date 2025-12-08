import 'package:get/get.dart';

import '../../Layout/layout_view.dart';

class AuthController extends GetxController {
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void doAppleAuth() {}

  void doGoogleAuth() {}

  void doSkipAuth() {
    Get.to(() => LayoutView());
  }
}

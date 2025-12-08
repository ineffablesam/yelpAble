import 'dart:async';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_carousel/flutter_custom_carousel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:yelpable/modules/AbleCam/able_camera_view.dart';
import 'package:yelpable/modules/Auth/Controller/auth_controller.dart';
import 'package:yelpable/utils/assets.dart';
import 'package:yelpable/utils/colors.dart';
import 'package:yelpable/utils/custom_tap.dart';

import '../../utils/sf_font.dart';

class OnboardingView extends GetView<AuthController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          50.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              20.horizontalSpace,
              SvgPicture.asset(AppAssets.logoSvg, width: 60.w),
              IconButton(
                onPressed: () {
                  Get.to(() => AbleCameraView());
                },
                icon: Icon(
                  SolarIconsBold.cameraMinimalistic,
                  size: 24.w,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          20.verticalSpace,
          MyCarouselRow(height: 290.h, category: 'c', count: 7),
          50.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 23.w),
            child: Column(
              children: [
                Text(
                  "Find What You Need, Without Barriers.",
                  textAlign: TextAlign.center,
                  style: SFPro.font(
                    color: Colors.black,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                10.verticalSpace,
                Text(
                  "Smart voice, vision, and assistance built to support every ability.",
                  textAlign: TextAlign.center,
                  style: SFPro.font(
                    color: Colors.grey.shade600,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ).paddingSymmetric(horizontal: 10.w),
              ],
            ),
          ),
          30.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTap(
                onTap: () {
                  HapticFeedback.heavyImpact();
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
                    "Get Started",
                    style: SFPro.font(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyCarouselRow extends StatefulWidget {
  final String category;
  final int count;
  final double height;

  const MyCarouselRow({
    super.key,
    required this.category,
    required this.count,
    this.height = 160,
  });

  @override
  State<MyCarouselRow> createState() => _MyCarouselRowState();
}

class _MyCarouselRowState extends State<MyCarouselRow> {
  final CustomCarouselScrollController _controller =
      CustomCarouselScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Autoplay: move to next item every 1 seconds
    _timer = Timer.periodic(Duration(seconds: 3), (_) {
      _controller.animateToItem(
        _nextItemIndex(),
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  int _nextItemIndex() {
    int currentIndex = _controller.position.itemIndex ?? 0;
    return (currentIndex + 1) % widget.count;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(
      widget.count,
      (i) => _Card(widget.category, i + 1),
    );

    return SizedBox(
      height: widget.height,
      child: CustomCarousel(
        controller: _controller,
        itemCountBefore: 1,
        itemCountAfter: 1,
        alignment: Alignment.center,
        scrollDirection: Axis.horizontal,
        loop: true,
        scrollSpeed: 0.6,
        depthOrder: DepthOrder.forward,
        tapToSelect: false,
        effectsBuilder: (_, ratio, child) {
          double rotationAngle = ratio * 0.04;
          double verticalOffset = ratio.abs() * 7;
          return Transform.translate(
            offset: Offset(ratio * 170 * 2.5, verticalOffset),
            child: Transform.rotate(angle: rotationAngle, child: child),
          );
        },
        children: items,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card(this.category, this.index, {super.key});

  final String category;
  final int index;

  @override
  Widget build(BuildContext context) {
    // Construct the asset path
    String assetPath = 'assets/images/carousel/${index}.jpg';

    Widget content = ClipSmoothRect(
      radius: SmoothBorderRadius(cornerRadius: 26.r, cornerSmoothing: 0.9),
      child: SoftEdgeBlur(
        edges: [
          EdgeBlur(
            type: EdgeType.bottomEdge,
            size: 190.h,
            sigma: 80,
            tileMode: TileMode.mirror,
            tintColor: Colors.black.withOpacity(0.6),
            controlPoints: [
              ControlPoint(position: 0.5, type: ControlPointType.visible),
              ControlPoint(position: 0.2, type: ControlPointType.visible),
              ControlPoint(position: 1, type: ControlPointType.transparent),
            ],
          ),
        ],
        child: Container(
          width: 0.61.sw,
          decoration: ShapeDecoration(
            color: Colors.red.withOpacity(0.75),
            image: DecorationImage(
              image: AssetImage(assetPath),
              fit: BoxFit.cover,
            ),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 26.r,
                cornerSmoothing: 0.9,
              ),
            ),
          ),
        ),
      ),
    );

    return content;
  }
}

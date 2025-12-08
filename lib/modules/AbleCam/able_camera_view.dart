import 'package:camera/camera.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:yelpable/modules/AbleCam/able_camera_view_controller.dart';

class AbleCameraView extends StatelessWidget {
  AbleCameraView({super.key});

  final AbleCameraViewController controller = Get.put(
    AbleCameraViewController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GetBuilder<AbleCameraViewController>(
        builder: (_) {
          if (!controller.isInitialized.value) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 1,
                color: Colors.white,
              ),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              /// EXPOSURE SLIDER (Behind camera)
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: 100),
                      Row(
                        children: [
                          const SizedBox(width: 40),
                          const Icon(
                            Icons.wb_sunny_outlined,
                            color: Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Obx(() {
                              return SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 3,
                                  activeTrackColor: Colors.yellow.shade700,
                                  inactiveTrackColor: Colors.white24,
                                  thumbColor: Colors.yellow.shade700,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 8,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 16,
                                  ),
                                ),
                                child: Slider(
                                  value: controller.currentExposure.value,
                                  min: controller.minExposure.value,
                                  max: controller.maxExposure.value,
                                  onChanged: (value) {
                                    controller.setExposure(value);
                                  },
                                ),
                              );
                            }),
                          ),
                          const SizedBox(width: 20),
                          Obx(() {
                            return SizedBox(
                              width: 40,
                              child: Text(
                                controller.currentExposure.value
                                    .toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 20),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Exposure scale indicator
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controller.minExposure.value.toStringAsFixed(0),
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                            const Text(
                              '0',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              controller.maxExposure.value.toStringAsFixed(0),
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              /// CAMERA PREVIEW (Draggable with elastic physics)
              Obx(() {
                return AnimatedPositioned(
                  duration: controller.isDragging.value
                      ? Duration.zero
                      : const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  bottom: controller.cameraOffset.value,
                  left: 0,
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onVerticalDragStart: (details) {
                      controller.onDragStart(details);
                    },
                    onVerticalDragUpdate: (details) {
                      controller.onDragUpdate(details);
                    },
                    onVerticalDragEnd: (details) {
                      controller.onDragEnd(details);
                    },
                    onTapUp: (details) {
                      controller.onTapFocus(details);
                    },
                    child: ClipSmoothRect(
                      radius: SmoothBorderRadius(
                        cornerRadius: controller.cameraOffset.value > 0
                            ? 40
                            : 0,
                        cornerSmoothing: 1,
                      ),
                      child: Container(
                        color: Colors.black,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CameraPreview(
                                controller.cameraController!,
                              ),
                            ),

                            Obx(() {
                              // Adjust vertical position based on cameraOffset
                              double baseBottom = 25; // default bottom padding
                              double elasticOffset =
                                  controller.cameraOffset.value * 0.0;
                              // 0 = closed, moves slightly up as camera opens
                              // multiply by factor for more/less movement
                              return Positioned(
                                bottom: baseBottom + elasticOffset,
                                left: 0,
                                right: 0,
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: controller.isProcessing.value
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : GestureDetector(
                                          onTap: controller.capture,
                                          child: CircleAvatar(
                                            radius: 37.r,
                                            backgroundColor:
                                                Colors.grey.shade400,
                                            child: CircleAvatar(
                                              radius: 32.r,
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              /// FOCUS INDICATOR
              Obx(() {
                if (!controller.showFocusIndicator.value) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  left: controller.focusX.value - 40,
                  top:
                      controller.focusY.value -
                      40 +
                      controller.cameraOffset.value,
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: controller.showFocusIndicator.value ? 1.0 : 0.0,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.yellow, width: 2),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              /// TOP BAR
              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),

              /// CAPTURE BUTTON
              // Positioned(
              //   bottom: 40,
              //   left: 0,
              //   right: 0,
              //   child: Column(
              //     children: [
              //       Obx(() {
              //         return controller.isProcessing.value
              //             ? const CircularProgressIndicator(color: Colors.white)
              //             : GestureDetector(
              //                 onTap: controller.capture,
              //                 child: Container(
              //                   width: 75,
              //                   height: 75,
              //                   decoration: BoxDecoration(
              //                     shape: BoxShape.circle,
              //                     border: Border.all(
              //                       color: Colors.white,
              //                       width: 5,
              //                     ),
              //                   ),
              //                 ),
              //               );
              //       }),
              //       const SizedBox(height: 10),
              //       const Text(
              //         "Tap to capture",
              //         style: TextStyle(color: Colors.white70),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }
}

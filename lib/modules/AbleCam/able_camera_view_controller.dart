import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AbleCameraViewController extends GetxController {
  CameraController? cameraController;
  RxBool isInitialized = false.obs;
  RxBool isProcessing = false.obs;

  // Exposure control variables
  RxDouble currentExposure = 0.0.obs;
  RxDouble minExposure = (-4.0).obs;
  RxDouble maxExposure = 4.0.obs;

  // Camera dragging variables
  RxDouble cameraOffset = 0.0.obs;
  RxBool isDragging = false.obs;
  double _dragStartY = 0.0;
  double _dragStartOffset = 0.0;
  int _lastHapticBucket = -999;

  // Elastic physics constants
  static const double maxDragDistance = 150;
  static const double elasticResistance = 0.5;
  static const double snapThresholdUp = 90.0; // Easy to open (drag up)
  static const double snapThresholdDown =
      90.0; // Hard to close (need to drag down more)

  // Focus indicator variables
  RxBool showFocusIndicator = false.obs;
  RxDouble focusX = 0.0.obs;
  RxDouble focusY = 0.0.obs;
  Timer? _hideFocusTimer;

  // Track last snapped state to allow only one haptic per cycle
  bool _wasOpen = false;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await cameraController!.initialize();

      minExposure.value = await cameraController!.getMinExposureOffset();
      maxExposure.value = await cameraController!.getMaxExposureOffset();
      currentExposure.value = 0.0;

      isInitialized.value = true;
      update();
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void onDragStart(DragStartDetails details) {
    _dragStartY = details.globalPosition.dy;
    _dragStartOffset = cameraOffset.value;
    isDragging.value = true;
  }

  void onDragUpdate(DragUpdateDetails details) {
    if (!isDragging.value) return;

    double drag = _dragStartY - details.globalPosition.dy;
    double rawOffset = _dragStartOffset + drag;
    double newOffset;

    if (rawOffset >= 0) {
      if (rawOffset <= maxDragDistance) {
        newOffset = rawOffset;
      } else {
        double excess = rawOffset - maxDragDistance;
        newOffset = maxDragDistance + (excess * elasticResistance);
      }
    } else {
      newOffset = rawOffset * 0.3;
    }

    cameraOffset.value = newOffset.clamp(-40.0, maxDragDistance + 120);
  }

  void onDragEnd(DragEndDetails details) {
    isDragging.value = false;

    double offset = cameraOffset.value;

    // Different thresholds based on direction
    bool willBeOpen;
    if (_wasOpen) {
      // Currently open: need to drag down past snapThresholdDown to close
      willBeOpen = offset > snapThresholdDown;
    } else {
      // Currently closed: need to drag up past snapThresholdUp to open
      willBeOpen = offset >= snapThresholdUp;
    }

    // Only vibrate if the state changed from last snap
    if (willBeOpen != _wasOpen) {
      HapticFeedback.mediumImpact(); // Single vibration
      _wasOpen = willBeOpen;
    }

    // Snap logic
    if (willBeOpen) {
      cameraOffset.value = maxDragDistance;
    } else {
      cameraOffset.value = 0.0;
    }
  }

  Future<void> setExposure(double value) async {
    try {
      final clampedValue = value.clamp(minExposure.value, maxExposure.value);
      if ((clampedValue - currentExposure.value).abs() < 0.1) return;

      currentExposure.value = clampedValue;
      await cameraController?.setExposureOffset(currentExposure.value);
      update();
    } catch (e) {
      print('Error setting exposure: $e');
    }
  }

  void onTapFocus(TapUpDetails details) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    try {
      final offset = details.localPosition;
      focusX.value = offset.dx;
      focusY.value = offset.dy;

      HapticFeedback.lightImpact();

      showFocusIndicator.value = true;
      _hideFocusTimer?.cancel();
      _hideFocusTimer = Timer(const Duration(seconds: 2), () {
        showFocusIndicator.value = false;
      });

      final x = offset.dx / Get.width;
      final y = offset.dy / Get.height;

      cameraController!.setFocusPoint(Offset(x, y));
      cameraController!.setExposurePoint(Offset(x, y));
    } catch (e) {
      print('Error setting focus: $e');
    }
  }

  Future<void> capture() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    if (isProcessing.value) return;

    try {
      isProcessing.value = true;
      HapticFeedback.mediumImpact();

      final image = await cameraController!.takePicture();

      print('Image captured: ${image.path}');

      // Navigate to preview or process the image
      // Get.to(() => ImagePreviewScreen(imagePath: image.path));
    } catch (e) {
      print('Error capturing image: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  @override
  void onClose() {
    _hideFocusTimer?.cancel();
    cameraController?.dispose();
    super.onClose();
  }
}

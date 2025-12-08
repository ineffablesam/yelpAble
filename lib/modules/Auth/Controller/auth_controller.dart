import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yelpable/utils/sf_font.dart';

class AuthController extends GetxController {
  RxBool isLoading = false.obs;

  // Store selected preferences
  final RxInt currentStep = 0.obs;
  final RxList<String> selectedPreferences = <String>[].obs;

  // Profile picture
  final Rx<File?> profileImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  // form key
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        profileImage.value = File(pickedFile.path);
        print("Profile image selected: ${pickedFile.path}");
      }
    } catch (e) {
      print("Error picking image: $e");
      Get.snackbar(
        "Error",
        "Failed to pick image. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Optional: Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        profileImage.value = File(pickedFile.path);
        print("Profile image captured: ${pickedFile.path}");
      }
    } catch (e) {
      print("Error capturing image: $e");
      Get.snackbar(
        "Error",
        "Failed to capture image. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Show image source selection dialog
  void showImageSourceDialog() {
    Get.bottomSheet(
      backgroundColor: Colors.white,
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(CupertinoIcons.photo),
                title: Text(
                  'Choose from Gallery',
                  style: SFPro.font(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Get.back();
                  pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(CupertinoIcons.camera),
                title: Text(
                  'Take a Photo',
                  style: SFPro.font(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Get.back();
                  pickImageFromCamera();
                },
              ),
              if (profileImage.value != null)
                ListTile(
                  leading: Icon(CupertinoIcons.trash, color: Colors.red),
                  title: Text(
                    'Remove Photo',
                    style: SFPro.font(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    profileImage.value = null;
                  },
                ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  void doAppleAuth() {}

  void doGoogleAuth() {}

  // Called when user taps Continue/Get Started
  void doContinue() {
    print("============================================");
    print("USER REGISTRATION DATA");
    print("============================================");
    print("Name: ${nameController.text}");
    print("Email: ${emailController.text}");
    print("Selected Preferences: $selectedPreferences");
    print(
      "Profile Image: ${profileImage.value != null ? profileImage.value!.path : 'Not selected'}",
    );
    print("============================================");

    // TODO: Save preferences to user profile or backend here
    // You can use profileImage.value to upload to backend

    // Navigate to main layout
    // Get.to(() => LayoutView());
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}

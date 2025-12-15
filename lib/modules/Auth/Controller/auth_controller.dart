import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yelpable/models/user_model.dart';
import 'package:yelpable/services/user_service.dart';
import 'package:yelpable/utils/sf_font.dart';

import '../../Layout/layout_view.dart';

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

  // User service
  final UserService _userService = UserService();

  // Current user
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadUserFromLocal();
  }

  // Load user from SharedPreferences
  Future<void> loadUserFromLocal() async {
    try {
      final user = await _userService.getUserLocally();
      if (user != null) {
        currentUser.value = user;
        print("User loaded from local storage: ${user.name}");
      }
    } catch (e) {
      print("Error loading user from local: $e");
    }
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

  void doAppleAuth() {
    // TODO: Implement Apple authentication
  }

  void doGoogleAuth() {
    // TODO: Implement Google authentication
  }

  // Called when user taps Continue/Get Started
  Future<void> doContinue() async {
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

    // Show loading
    isLoading.value = true;

    try {
      // Create user in Supabase
      final user = await _userService.createUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        preferences: selectedPreferences.toList(),
        profileImage: profileImage.value,
      );

      if (user != null) {
        currentUser.value = user;
        // Navigate to main layout
        Get.offAll(() => LayoutView());
        print("User created successfully: ${user.id}");
      } else {
        debugPrint("User creation failed.");
      }
    } catch (e) {
      print("Error during registration: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Logout method
  Future<void> logout() async {
    await _userService.clearUserLocally();
    currentUser.value = null;

    // Clear form data
    nameController.clear();
    emailController.clear();
    selectedPreferences.clear();
    profileImage.value = null;
    currentStep.value = 0;

    // Navigate to auth view
    // Get.offAll(() => AuthView());
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}

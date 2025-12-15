import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yelpable/modules/Auth/Controller/auth_controller.dart';

class ReelyController extends GetxController {
  final supabase = Supabase.instance.client;

  RxString sharedUrl = ''.obs;
  RxBool isProcessing = false.obs;
  RxList<Map<String, dynamic>> reels = <Map<String, dynamic>>[].obs;
  RxBool isLoadingReels = false.obs;

  StreamSubscription? _reelsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadReels();
    subscribeToReels();
  }

  /// Load reels from Supabase (initial load)
  Future<void> loadReels() async {
    try {
      isLoadingReels.value = true;

      final AuthController authController = Get.put(AuthController());
      final user = authController.currentUser.value;
      if (user == null) {
        print('❌ No authenticated user');
        return;
      }

      final response = await supabase
          .from('reels')
          .select()
          .eq('email', user.email!)
          .order('created_at', ascending: false);

      reels.value = List<Map<String, dynamic>>.from(response);
      print('✅ Loaded ${reels.length} reels');
    } catch (e) {
      print('❌ Error loading reels: $e');
      Get.snackbar(
        'Error',
        'Failed to load reels: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoadingReels.value = false;
    }
  }

  /// Subscribe to real-time updates using Supabase Realtime
  void subscribeToReels() {
    try {
      final AuthController authController = Get.find<AuthController>();
      final email = authController.currentUser.value?.email;

      if (email == null) {
        print('❌ Cannot subscribe: No user email');
        return;
      }

      print('🔄 Setting up real-time subscription for: $email');

      // Use Supabase Realtime stream
      _reelsSubscription = supabase
          .from('reels')
          .stream(primaryKey: ['id'])
          .eq('email', email)
          .order('created_at', ascending: false)
          .listen(
            (List<Map<String, dynamic>> data) {
              print('🔄 Real-time update received: ${data.length} reels');
              reels.value = data;
            },
            onError: (error) {
              print('❌ Real-time subscription error: $error');
            },
          );

      print('✅ Real-time subscription active');
    } catch (e) {
      print('❌ Error setting up real-time subscription: $e');
    }
  }

  /// Process Instagram URL
  Future<void> processInstagramUrl(String url) async {
    if (url.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter an Instagram URL',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    // Validate Instagram URL format
    if (!url.contains('instagram.com')) {
      Get.snackbar(
        'Error',
        'Please enter a valid Instagram URL',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isProcessing.value = true;

      final AuthController authController = Get.find<AuthController>();
      final email = authController.currentUser.value?.email;

      if (email == null) {
        Get.snackbar(
          'Error',
          'Please log in first',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }

      print('📤 Sending URL to backend: $url');
      // Reload reels
      // loadReels();
      // Call Supabase Edge Function
      final response = await supabase.functions.invoke(
        'process-instagram-reel',
        body: {'instagram_url': url, 'email': email},
      );

      if (response.status == 200) {
        print('✅ Reel processing started successfully');

        // Clear shared URL
        sharedUrl.value = '';
        loadReels();
        // The real-time subscription will automatically update the UI
        // No need to manually reload
      } else {
        throw Exception('Server returned status ${response.status}');
      }
    } catch (e) {
      print('❌ Error processing URL: $e');
      Get.snackbar(
        'Error',
        'Failed to process reel: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Extract Reel ID from URL (helper function)
  String? getReelId(String url) {
    if (url.isEmpty) return null;

    final match = RegExp(r'/(?:reel|p|tv)/([A-Za-z0-9_-]+)').firstMatch(url);
    return match?.group(1);
  }

  /// Clear the shared URL
  void clearUrl() {
    sharedUrl.value = '';
  }

  /// Delete a reel
  Future<void> deleteReel(String reelId) async {
    try {
      await supabase.from('reels').delete().eq('id', reelId);

      Get.snackbar(
        '✓ Deleted',
        'Reel deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      // The real-time subscription will automatically update the UI
    } catch (e) {
      print('❌ Error deleting reel: $e');
      Get.snackbar(
        'Error',
        'Failed to delete reel: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    print('🔴 Cancelling real-time subscription');
    _reelsSubscription?.cancel();
    super.onClose();
  }
}

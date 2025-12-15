import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yelpable/core/supabase_config.dart';
import 'package:yelpable/models/user_model.dart';

class UserService {
  static const String _userKey = 'cached_user';
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Save user to SharedPreferences
  Future<void> saveUserLocally(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toJsonString());
  }

  // Get user from SharedPreferences
  Future<UserModel?> getUserLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        return UserModel.fromJsonString(userJson);
      }
      return null;
    } catch (e) {
      print('Error getting local user: $e');
      return null;
    }
  }

  // Clear user from SharedPreferences
  Future<void> clearUserLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Upload profile picture to Supabase Storage
  Future<String?> uploadProfilePicture(File imageFile, String userId) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId/profile.$fileExt';
      final filePath = fileName;

      // Upload to Supabase Storage
      await _supabase.storage
          .from('profile-pictures')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$fileExt',
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from('profile-pictures')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  // Create user in Supabase
  Future<UserModel?> createUser({
    required String name,
    required String email,
    required List<String> preferences,
    File? profileImage,
  }) async {
    try {
      // Step 1: Insert user WITHOUT the profile picture first
      // This lets Supabase generate the UUID
      final userData = {
        'name': name,
        'email': email,
        'preferences': preferences,
      };

      // Insert into Supabase and get the created user with auto-generated UUID
      final response = await _supabase
          .from('users')
          .insert(userData)
          .select()
          .single();

      print("User created in database: ${response['id']}");

      // Step 2: Now upload profile picture if provided, using the generated UUID
      String? profilePictureUrl;
      if (profileImage != null) {
        final userId = response['id'] as String;
        profilePictureUrl = await uploadProfilePicture(profileImage, userId);

        // Step 3: Update user with profile picture URL
        if (profilePictureUrl != null) {
          await _supabase
              .from('users')
              .update({'profile_picture_url': profilePictureUrl})
              .eq('id', userId);

          // Update the response with the profile picture URL
          response['profile_picture_url'] = profilePictureUrl;
        }
      }

      // Create UserModel from the response
      final user = UserModel.fromJson(response);

      // Save to local storage
      await saveUserLocally(user);

      print("User saved locally with ID: ${user.id}");

      return user;
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  // Get user from Supabase by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // Get user from Supabase by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error fetching user by email: $e');
      return null;
    }
  }

  // Update user in Supabase
  Future<UserModel?> updateUser(UserModel user, {File? newProfileImage}) async {
    try {
      // Upload new profile image if provided
      String? profilePictureUrl = user.profilePictureUrl;
      if (newProfileImage != null) {
        final uploadedUrl = await uploadProfilePicture(
          newProfileImage,
          user.id,
        );
        if (uploadedUrl != null) {
          profilePictureUrl = uploadedUrl;
        }
      }

      final updateData = {
        'name': user.name,
        'email': user.email,
        'preferences': user.preferences,
        'profile_picture_url': profilePictureUrl,
      };

      final response = await _supabase
          .from('users')
          .update(updateData)
          .eq('id', user.id)
          .select()
          .single();

      final updatedUser = UserModel.fromJson(response);
      await saveUserLocally(updatedUser);

      return updatedUser;
    } catch (e) {
      print('Error updating user: $e');
      return null;
    }
  }

  // Delete user profile picture
  Future<bool> deleteProfilePicture(String userId) async {
    try {
      // Delete from storage
      final filePath = '$userId/profile.jpg'; // Adjust extension if needed
      await _supabase.storage.from('profile-pictures').remove([filePath]);

      // Update database
      await _supabase
          .from('users')
          .update({'profile_picture_url': null})
          .eq('id', userId);

      return true;
    } catch (e) {
      print('Error deleting profile picture: $e');
      return false;
    }
  }
}

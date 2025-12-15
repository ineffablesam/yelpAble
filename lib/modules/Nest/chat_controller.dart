import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yelpable/core/supabase_config.dart';
import 'package:yelpable/models/message_model.dart';
import 'package:yelpable/models/room_model.dart';
import 'package:yelpable/modules/Auth/Controller/auth_controller.dart';

class ChatController extends GetxController {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final AuthController _authController = Get.find<AuthController>();

  // Observable lists
  final RxList<RoomModel> rooms = <RoomModel>[].obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxList<RoomMemberModel> roomMembers = <RoomMemberModel>[].obs;
  final RxList<String> typingUsers = <String>[].obs;
  final Rx<RoomModel?> currentRoom = Rx<RoomModel?>(null);

  // Loading states
  final RxBool isLoadingRooms = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool isSendingMessage = false.obs;
  final RxBool isAIProcessing = false.obs;

  // Text controller for message input
  final TextEditingController messageController = TextEditingController();

  // Reply functionality
  final Rx<MessageModel?> replyingTo = Rx<MessageModel?>(null);

  // @Mention functionality
  final RxBool showMentionSuggestions = false.obs;
  final RxList<RoomMemberModel> filteredMembers = <RoomMemberModel>[].obs;
  final RxString mentionQuery = ''.obs;

  // Realtime subscriptions
  RealtimeChannel? _roomsSubscription;
  RealtimeChannel? _messagesSubscription;
  RealtimeChannel? _typingChannel; // Changed to single channel for typing

  // Typing indicator timers
  Timer? _stopTypingTimer;
  Timer? _typingCleanupTimer;

  // Store typing users with timestamps
  final Map<String, DateTime> _typingUsersMap = {};

  // AI User ID constant
  static const String AI_USER_ID = "00000000-0000-0000-0000-000000000001";

  @override
  void onInit() {
    super.onInit();
    loadRooms();
    subscribeToRooms();

    // Listen to message controller for @mentions
    messageController.addListener(_handleMessageInput);
  }

  // Handle message input for @mentions
  void _handleMessageInput() {
    final text = messageController.text;
    final cursorPosition = messageController.selection.baseOffset;

    if (cursorPosition == -1) return;

    // Find @ symbol before cursor
    final textBeforeCursor = text.substring(0, cursorPosition);
    final lastAtIndex = textBeforeCursor.lastIndexOf('@');

    if (lastAtIndex != -1) {
      // Check if there's a space between @ and cursor
      final textAfterAt = textBeforeCursor.substring(lastAtIndex + 1);
      if (!textAfterAt.contains(' ')) {
        showMentionSuggestions.value = true;
        mentionQuery.value = textAfterAt.toLowerCase();
        _filterMembers(textAfterAt);
        return;
      }
    }

    showMentionSuggestions.value = false;
  }

  // Filter members based on query
  void _filterMembers(String query) {
    if (query.isEmpty) {
      filteredMembers.value = roomMembers.toList();
    } else {
      filteredMembers.value = roomMembers
          .where(
            (member) => member.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  // Select a mention
  void selectMention(RoomMemberModel member) {
    final text = messageController.text;
    final cursorPosition = messageController.selection.baseOffset;
    final textBeforeCursor = text.substring(0, cursorPosition);
    final lastAtIndex = textBeforeCursor.lastIndexOf('@');

    if (lastAtIndex != -1) {
      final beforeAt = text.substring(0, lastAtIndex);
      final afterCursor = text.substring(cursorPosition);
      final newText = '$beforeAt@${member.name} $afterCursor';

      messageController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: lastAtIndex + member.name.length + 2,
        ),
      );
    }

    showMentionSuggestions.value = false;
  }

  // Load all rooms for current user
  Future<void> loadRooms() async {
    try {
      isLoadingRooms.value = true;
      final userId = _authController.currentUser.value?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('room_members')
          .select('rooms(*)')
          .eq('user_id', userId)
          .order('joined_at', ascending: false);

      if (response == null || (response as List).isEmpty) {
        rooms.value = [];
        return;
      }

      rooms.value = (response as List)
          .map(
            (item) => RoomModel.fromJson(item['rooms'] as Map<String, dynamic>),
          )
          .toList();

      for (var room in rooms) {
        await _loadLastMessageForRoom(room.id);
      }
    } catch (e) {
      debugPrint('Error loading rooms: $e');
      Get.snackbar('Error', 'Failed to load rooms');
    } finally {
      isLoadingRooms.value = false;
    }
  }

  // Load last message for a room
  Future<void> _loadLastMessageForRoom(String roomId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('*, users!messages_sender_id_fkey(name, profile_picture_url)')
          .eq('room_id', roomId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        final roomIndex = rooms.indexWhere((r) => r.id == roomId);
        if (roomIndex != -1) {
          rooms[roomIndex] = rooms[roomIndex].copyWith(
            lastMessageContent: response['content'] as String?,
            lastMessageTime: DateTime.parse(response['created_at'] as String),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading last message: $e');
    }
  }

  // Subscribe to realtime room updates
  void subscribeToRooms() {
    final userId = _authController.currentUser.value?.id;
    if (userId == null) return;

    _roomsSubscription = _supabase
        .channel('public:rooms')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'rooms',
          callback: (payload) {
            debugPrint('Room change: ${payload.eventType}');
            loadRooms();
          },
        )
        .subscribe();

    _supabase
        .channel('public:room_members')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'room_members',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            debugPrint('Room member change: ${payload.eventType}');
            loadRooms();
          },
        )
        .subscribe();
  }

  // Create a new room
  Future<bool> createRoom(String roomName, String? description) async {
    try {
      final userId = _authController.currentUser.value?.id;
      if (userId == null) return false;

      // Step 1: Create the room using RPC
      final response = await _supabase
          .rpc(
            'create_room',
            params: {
              'p_name': roomName,
              'p_description': description,
              'p_owner_id': userId,
            },
          )
          .single();

      final roomId = response['room_id'] as String;
      final inviteCode = response['invite_code'] as String;

      debugPrint('Room created: $roomId');

      // Step 2: Initialize Yelp AI chat session
      try {
        await _initializeYelpChat(
          roomId: roomId,
          roomName: roomName,
          roomDescription: description,
        );
      } catch (e) {
        debugPrint('Warning: Failed to initialize Yelp chat: $e');
        // Don't fail room creation if Yelp initialization fails
      }

      // Step 3: Reload rooms to show the new one
      await loadRooms();

      Get.snackbar(
        'Success',
        'Room created! Invite code: $inviteCode',
        duration: const Duration(seconds: 5),
      );

      return true;
    } catch (e) {
      debugPrint('Error creating room: $e');
      Get.snackbar('Error', 'Failed to create room');
      return false;
    }
  }

  // Initialize Yelp AI chat for a room
  Future<void> _initializeYelpChat({
    required String roomId,
    required String roomName,
    String? roomDescription,
  }) async {
    try {
      // Get user's location if available (you can implement location services)
      // For now, we'll send without location

      final response = await _supabase.functions.invoke(
        'initialize-yelp-chat',
        body: {
          'room_id': roomId,
          'room_name': roomName,
          'room_description': roomDescription,
          // Optional: Add user location if you have it
          // 'user_latitude': latitude,
          // 'user_longitude': longitude,
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('Yelp chat initialized: ${data['chat_id']}');
        debugPrint('AI welcome message: ${data['ai_response']}');
      } else {
        throw Exception('Failed to initialize Yelp chat: ${response.status}');
      }
    } catch (e) {
      debugPrint('Error initializing Yelp chat: $e');
      rethrow;
    }
  }

  // Send message to Yelp AI (call this when user mentions @AI or sends to AI)
  Future<void> sendMessageToYelpAI(String message, String roomId) async {
    try {
      // Get the room's yelp_chat_id
      final roomData = await _supabase
          .from('rooms')
          .select('yelp_chat_id')
          .eq('id', roomId)
          .single();

      final chatId = roomData['yelp_chat_id'] as String?;

      if (chatId == null) {
        throw Exception('Room does not have a Yelp chat session');
      }

      // Call Yelp AI API through your backend or directly
      // You may want to create another Edge Function for this
      final response = await _supabase.functions.invoke(
        'query-yelp-ai',
        body: {
          'room_id': roomId,
          'chat_id': chatId,
          'query': message,
          // Optional: Add user location
          // 'user_latitude': latitude,
          // 'user_longitude': longitude,
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('Yelp AI response: ${data['response']}');

        // The Edge Function will handle inserting the AI's response into messages
      } else {
        throw Exception('Failed to query Yelp AI: ${response.status}');
      }
    } catch (e) {
      debugPrint('Error sending message to Yelp AI: $e');
      Get.snackbar('Error', 'Failed to get AI response');
    }
  }

  // Join room by invite code
  Future<bool> joinRoomByInvite(String inviteCode) async {
    try {
      final userId = _authController.currentUser.value?.id;
      if (userId == null) return false;

      final response = await _supabase
          .rpc(
            'join_room_by_invite',
            params: {
              'p_invite_code': inviteCode.toUpperCase(),
              'p_user_id': userId,
            },
          )
          .single();

      if (response['success'] == true) {
        await loadRooms();
        Get.snackbar('Success', response['message'] as String);
        return true;
      } else {
        Get.snackbar('Error', response['message'] as String);
        return false;
      }
    } catch (e) {
      debugPrint('Error joining room: $e');
      Get.snackbar('Error', 'Failed to join room');
      return false;
    }
  }

  // Load room members
  Future<void> loadRoomMembers(String roomId) async {
    try {
      final response = await _supabase.rpc(
        'get_room_members',
        params: {'p_room_id': roomId},
      );

      roomMembers.value = (response as List)
          .map((json) => RoomMemberModel.fromJson(json))
          .toList();

      // Always add AI Assistant to members list for @mentions
      final aiMember = RoomMemberModel(
        userId: AI_USER_ID,
        name: 'AI Assistant',
        profilePictureUrl: null,
      );

      // Check if AI is not already in the list
      final hasAI = roomMembers.any((m) => m.userId == AI_USER_ID);
      if (!hasAI) {
        roomMembers.insert(0, aiMember); // Add AI at the beginning
      }

      filteredMembers.value = roomMembers.toList();
    } catch (e) {
      debugPrint('Error loading room members: $e');
    }
  }

  // Enter a room and load messages
  Future<void> enterRoom(RoomModel room) async {
    try {
      currentRoom.value = room;
      messages.clear();
      replyingTo.value = null;
      typingUsers.clear();
      _typingUsersMap.clear();

      await loadMessages(room.id);
      await loadRoomMembers(room.id);
      subscribeToMessages(room.id);
      subscribeToTypingBroadcast(room.id); // NEW: Use broadcast instead

      final userId = _authController.currentUser.value?.id;
      if (userId != null) {
        await _supabase
            .from('room_members')
            .update({'last_read_at': DateTime.now().toIso8601String()})
            .eq('room_id', room.id)
            .eq('user_id', userId);
      }
    } catch (e) {
      debugPrint('Error entering room: $e');
    }
  }

  // Load messages for a room
  Future<void> loadMessages(String roomId) async {
    try {
      isLoadingMessages.value = true;

      final response = await _supabase
          .from('messages')
          .select('*, users!messages_sender_id_fkey(name, profile_picture_url)')
          .eq('room_id', roomId)
          .order('created_at', ascending: true);

      final messagesList = (response as List).map((json) {
        final userData = json['users'] as Map<String, dynamic>?;
        return MessageModel.fromJson(json).copyWith(
          senderName: userData?['name'] as String?,
          senderProfilePicture: userData?['profile_picture_url'] as String?,
        );
      }).toList();

      // Populate reply messages
      for (int i = 0; i < messagesList.length; i++) {
        if (messagesList[i].replyToId != null) {
          final replyMsg = messagesList.firstWhereOrNull(
            (m) => m.id == messagesList[i].replyToId,
          );
          if (replyMsg != null) {
            messagesList[i] = messagesList[i].copyWith(
              replyToMessage: replyMsg,
            );
          }
        }
      }

      messages.value = messagesList;
    } catch (e) {
      debugPrint('Error loading messages: $e');
      Get.snackbar('Error', 'Failed to load messages');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  // Subscribe to realtime messages for a room
  void subscribeToMessages(String roomId) {
    _messagesSubscription?.unsubscribe();

    _messagesSubscription = _supabase
        .channel('room:$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) async {
            debugPrint('New message received: ${payload.newRecord}');

            final senderId = payload.newRecord['sender_id'];
            final userResponse = await _supabase
                .from('users')
                .select('name, profile_picture_url')
                .eq('id', senderId)
                .maybeSingle();

            var newMessage = MessageModel.fromJson(payload.newRecord).copyWith(
              senderName: userResponse?['name'] as String?,
              senderProfilePicture:
                  userResponse?['profile_picture_url'] as String?,
            );

            // Load reply message if exists
            if (newMessage.replyToId != null) {
              final replyMsg = messages.firstWhereOrNull(
                (m) => m.id == newMessage.replyToId,
              );
              if (replyMsg != null) {
                newMessage = newMessage.copyWith(replyToMessage: replyMsg);
              }
            }

            messages.add(newMessage);
            await _loadLastMessageForRoom(roomId);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) async {
            debugPrint('Message updated: ${payload.newRecord}');

            final messageId = payload.newRecord['id'] as String;
            final index = messages.indexWhere((m) => m.id == messageId);

            if (index != -1) {
              final senderId = payload.newRecord['sender_id'];
              final userResponse = await _supabase
                  .from('users')
                  .select('name, profile_picture_url')
                  .eq('id', senderId)
                  .maybeSingle();

              final updatedMessage = MessageModel.fromJson(payload.newRecord)
                  .copyWith(
                    senderName: userResponse?['name'] as String?,
                    senderProfilePicture:
                        userResponse?['profile_picture_url'] as String?,
                  );

              messages[index] = updatedMessage;
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            debugPrint('Message deleted: ${payload.oldRecord}');

            final messageId = payload.oldRecord['id'] as String;
            messages.removeWhere((m) => m.id == messageId);
            _loadLastMessageForRoom(roomId);
          },
        )
        .subscribe();
  }

  // NEW: Subscribe to typing indicators using Broadcast (INSTANT!)
  void subscribeToTypingBroadcast(String roomId) {
    _typingChannel?.unsubscribe();

    final userId = _authController.currentUser.value?.id;
    final userName = _authController.currentUser.value?.name;

    if (userId == null || userName == null) return;

    _typingChannel = _supabase
        .channel('typing:$roomId')
        .onBroadcast(
          event: 'typing',
          callback: (payload) {
            debugPrint('🔥 Typing broadcast received: $payload');

            final senderId = payload['user_id'] as String?;
            final senderName = payload['user_name'] as String?;
            final isTyping = payload['is_typing'] as bool? ?? false;

            // Ignore own typing events
            if (senderId == userId) return;

            if (senderName != null) {
              if (isTyping) {
                _typingUsersMap[senderId!] = DateTime.now();
              } else {
                _typingUsersMap.remove(senderId);
              }

              _updateTypingUsersList();
            }
          },
        )
        .subscribe();

    // Start cleanup timer to remove stale typing indicators
    _typingCleanupTimer?.cancel();
    _typingCleanupTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _cleanupStaleTypingUsers();
    });
  }

  // Clean up typing users who haven't updated in 3 seconds
  void _cleanupStaleTypingUsers() {
    final now = DateTime.now();
    final staleUsers = <String>[];

    _typingUsersMap.forEach((userId, lastUpdate) {
      if (now.difference(lastUpdate).inSeconds > 3) {
        staleUsers.add(userId);
      }
    });

    if (staleUsers.isNotEmpty) {
      for (var userId in staleUsers) {
        _typingUsersMap.remove(userId);
      }
      _updateTypingUsersList();
    }
  }

  // Update the observable typing users list
  void _updateTypingUsersList() {
    final userIds = _typingUsersMap.keys.toList();

    // Get names from room members
    final names = <String>[];
    for (var userId in userIds) {
      final member = roomMembers.firstWhereOrNull((m) => m.userId == userId);
      if (member != null) {
        names.add(member.name);
      }
    }

    typingUsers.value = names;
    debugPrint('👤 Typing users: $names');
  }

  // NEW: Send typing indicator using Broadcast (INSTANT!)
  void sendTypingIndicator(bool isTyping) {
    final userId = _authController.currentUser.value?.id;
    final userName = _authController.currentUser.value?.name;
    final roomId = currentRoom.value?.id;

    if (userId == null ||
        userName == null ||
        roomId == null ||
        _typingChannel == null)
      return;

    debugPrint('📤 Sending typing: $isTyping');

    _typingChannel!.sendBroadcastMessage(
      event: 'typing',
      payload: {
        'user_id': userId,
        'user_name': userName,
        'is_typing': isTyping,
      },
    );

    if (isTyping) {
      // Auto stop typing after 3 seconds
      _stopTypingTimer?.cancel();
      _stopTypingTimer = Timer(const Duration(seconds: 3), () {
        sendTypingIndicator(false);
      });
    }
  }

  // Set reply to message
  void setReplyTo(MessageModel message) {
    replyingTo.value = message;
  }

  // Cancel reply
  void cancelReply() {
    replyingTo.value = null;
  }

  // Send a message
  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty || currentRoom.value == null) return;

    try {
      isSendingMessage.value = true;
      final userId = _authController.currentUser.value?.id;
      if (userId == null) return;

      // Check if message mentions AI
      final containsAIMention = _detectAIMention(content);

      // Insert user's message
      await _supabase.from('messages').insert({
        'room_id': currentRoom.value!.id,
        'sender_id': userId,
        'content': content,
        'message_type': 'text',
        'reply_to_id': replyingTo.value?.id,
      });

      // Clear input immediately after sending
      messageController.clear();
      replyingTo.value = null;
      sendTypingIndicator(false);

      // If @AI mentioned, trigger Yelp AI response
      if (containsAIMention) {
        debugPrint('🤖 AI mentioned, sending to Yelp AI...');
        // Don't await - let it run in background so UI doesn't block
        _sendToYelpAI(content, currentRoom.value!.id);
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message');
    } finally {
      isSendingMessage.value = false;
    }
  }

  // Send message to Yelp AI in background
  Future<void> _sendToYelpAI(String message, String roomId) async {
    isAIProcessing.value = true; // Show AI is thinking

    try {
      // Get the room's yelp_chat_id
      final roomData = await _supabase
          .from('rooms')
          .select('yelp_chat_id')
          .eq('id', roomId)
          .single();

      final chatId = roomData['yelp_chat_id'] as String?;

      if (chatId == null) {
        debugPrint('⚠️ Room does not have a Yelp chat session');

        await _supabase.from('messages').insert({
          'room_id': roomId,
          'sender_id': AI_USER_ID,
          'content':
              "I'm sorry, but I'm not initialized for this room yet. Please contact the room admin.",
          'message_type': 'text',
          'is_system': false,
        });

        return;
      }

      debugPrint('🔄 Querying Yelp AI with chat_id: $chatId');

      // Call Yelp AI API through Edge Function
      final response = await _supabase.functions.invoke(
        'query-yelp-ai',
        body: {'room_id': roomId, 'chat_id': chatId, 'query': message},
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('✅ Yelp AI response received: ${data['response']}');
      } else {
        throw Exception('Yelp AI returned status: ${response.status}');
      }
    } catch (e) {
      debugPrint('❌ Error sending to Yelp AI: $e');

      try {
        await _supabase.from('messages').insert({
          'room_id': roomId,
          'sender_id': AI_USER_ID,
          'content':
              "I'm having trouble processing your request right now. Please try again later.",
          'message_type': 'text',
          'is_system': false,
        });
      } catch (insertError) {
        debugPrint('Failed to insert error message: $insertError');
      }
    } finally {
      isAIProcessing.value = false; // Hide AI thinking indicator
    }
  }

  Future<void> sendReservationConfirmation({
    required String businessName,
    required int partySize,
    required String timeSlot,
    String? businessAddress,
  }) async {
    final roomId = currentRoom.value?.id;
    if (roomId == null) return;

    try {
      // Create a special metadata structure for reservation confirmation
      final metadata = {
        'message_type': 'reservation_confirmation',
        'business_name': businessName,
        'party_size': partySize,
        'time_slot': timeSlot,
        'business_address': businessAddress,
        'confirmed_at': DateTime.now().toIso8601String(),
      };

      // Insert the AI's confirmation message
      await _supabase.from('messages').insert({
        'room_id': roomId,
        'sender_id': AI_USER_ID,
        'content':
            '✅ Your reservation has been confirmed! Here are the details:',
        'message_type': 'reservation_confirmation',
        'metadata': metadata,
        // 'is_system': false,
      });

      debugPrint('✅ Reservation confirmation message sent');
    } catch (e) {
      debugPrint('❌ Error sending reservation confirmation: $e');
    }
  }

  bool _detectAIMention(String content) {
    final lowerContent = content.toLowerCase();

    // Check for various @AI patterns
    return lowerContent.contains('@ai') ||
        lowerContent.contains('@ ai') ||
        lowerContent.contains('@ai assistant') ||
        lowerContent.contains('@yelp') ||
        lowerContent.contains('@assistant');
  }

  // Leave room
  void leaveRoom() {
    sendTypingIndicator(false);
    _messagesSubscription?.unsubscribe();
    _messagesSubscription = null;
    _typingChannel?.unsubscribe();
    _typingChannel = null;
    _stopTypingTimer?.cancel();
    _typingCleanupTimer?.cancel();

    currentRoom.value = null;
    messages.clear();
    typingUsers.clear();
    _typingUsersMap.clear();
    replyingTo.value = null;
    showMentionSuggestions.value = false;
  }

  @override
  void onClose() {
    messageController.removeListener(_handleMessageInput);
    messageController.dispose();
    _roomsSubscription?.unsubscribe();
    _messagesSubscription?.unsubscribe();
    _typingChannel?.unsubscribe();
    _stopTypingTimer?.cancel();
    _typingCleanupTimer?.cancel();
    super.onClose();
  }
}

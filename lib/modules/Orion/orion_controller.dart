import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yelpable/modules/Auth/Controller/auth_controller.dart';

import '../../models/yelp_metadata_model.dart';

class Message {
  final String text;
  final bool isUser;
  final bool isThinking;
  final DateTime timestamp;
  final String id;
  final String? audioUrl;
  final bool isAudioPlaying;
  final bool isFromHistory;
  final List<Business>? businesses;

  Message({
    required this.text,
    required this.isUser,
    this.isThinking = false,
    this.audioUrl,
    this.isAudioPlaying = false,
    this.isFromHistory = false,
    this.businesses, // NEW
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now(),
       id = DateTime.now().millisecondsSinceEpoch.toString();

  Message copyWith({
    String? text,
    bool? isThinking,
    String? audioUrl,
    bool? isAudioPlaying,
    bool? isFromHistory,
    List<Business>? businesses, // NEW
  }) {
    return Message(
      text: text ?? this.text,
      isUser: this.isUser,
      isThinking: isThinking ?? this.isThinking,
      audioUrl: audioUrl ?? this.audioUrl,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
      isFromHistory: isFromHistory ?? this.isFromHistory,
      businesses: businesses ?? this.businesses, // NEW
      timestamp: this.timestamp,
    );
  }

  @override
  String toString() {
    return 'Message{id: $id, text: "${text.substring(0, text.length > 50 ? 50 : text.length)}...", isUser: $isUser, isThinking: $isThinking, hasAudio: ${audioUrl != null}, hasBusinesses: ${businesses?.length ?? 0}, isFromHistory: $isFromHistory}';
  }
}

class OrionController extends GetxController {
  ScrollController scrollController = ScrollController();
  final AudioPlayer audioPlayer = AudioPlayer();

  final RxList<Message> messages = <Message>[].obs;
  final RxString liveTranscript = ''.obs;
  final RxString entireTranscript = ''.obs;
  final RxBool isListening = false.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isAudioLoading = false.obs;
  final RxBool isLoadingHistory = true.obs;

  String _lastValidLiveText = '';
  String? _currentYelpChatId;
  RealtimeChannel? _realtimeChannel;

  final supabase = Supabase.instance.client;

  int _speechCallCount = 0;
  int _messageAddCount = 0;

  @override
  void onInit() {
    super.onInit();
    _setupAudioPlayer();
    _loadChatHistory();
    _setupRealtimeSubscription();
  }

  @override
  void onClose() {
    _realtimeChannel?.unsubscribe();
    audioPlayer.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _setupAudioPlayer() {
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        _updateMessageAudioState(false);
      }
    });
  }

  Future<void> _loadChatHistory() async {
    try {
      isLoadingHistory.value = true;
      final AuthController authController = Get.find<AuthController>();
      final userEmail = authController.currentUser.value?.email;
      if (userEmail == null) {
        print('❌ No userEmail found for loading chat history');
        isLoadingHistory.value = false;
        return;
      }

      print('📚 Loading chat history for user: $userEmail');

      final response = await supabase
          .from('orion_chats')
          .select()
          .eq('email', userEmail)
          .eq('status', 'completed')
          .order('created_at', ascending: true);

      if (response == null || (response as List).isEmpty) {
        print('📭 No chat history found');
        isLoadingHistory.value = false;
        return;
      }

      final List<dynamic> chats = response as List;
      print('✅ Loaded ${chats.length} chat messages');

      if (chats.isNotEmpty) {
        final lastChat = chats.last;
        if (lastChat['yelp_chat_id'] != null) {
          _currentYelpChatId = lastChat['yelp_chat_id'] as String;
          print('💬 Restored Yelp Chat ID: $_currentYelpChatId');
        }
      }

      for (final chat in chats) {
        // Add user message
        messages.add(
          Message(
            text: chat['user_message'] as String,
            isUser: true,
            isFromHistory: true,
            timestamp: DateTime.parse(chat['created_at'] as String),
          ),
        );

        // Add AI response with businesses
        if (chat['ai_response_text'] != null) {
          List<Business>? businesses;
          if (chat['yelp_entities'] != null) {
            try {
              businesses = _parseBusinessEntities(chat['yelp_entities']);
            } catch (e) {
              print('❌ Error parsing businesses from history: $e');
            }
          }

          messages.add(
            Message(
              text: chat['ai_response_text'] as String,
              isUser: false,
              audioUrl: chat['audio_url'] as String?,
              businesses: businesses, // NEW: Add businesses from history
              isFromHistory: true,
              timestamp: DateTime.parse(chat['updated_at'] as String),
            ),
          );
        }
      }

      print('✅ Chat history loaded: ${messages.length} messages');
      _scrollToBottom();
    } catch (e) {
      print('❌ Error loading chat history: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  void _setupRealtimeSubscription() {
    final AuthController authController = Get.find<AuthController>();
    final userEmail = authController.currentUser.value?.email;
    if (userEmail == null) {
      print('❌ No user ID found for realtime subscription');
      return;
    }

    print('🔄 Setting up realtime subscription...');

    _realtimeChannel = supabase
        .channel('orion_chats_channel_$userEmail')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orion_chats',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'email',
            value: userEmail,
          ),
          callback: (payload) {
            print('🔔 Realtime event: ${payload.eventType}');
            print('🔔 Payload: ${payload.newRecord}');
            _handleRealtimeUpdate(payload);
          },
        )
        .subscribe((status, error) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            print('✅ Realtime subscription active');
          } else if (status == RealtimeSubscribeStatus.closed) {
            print('⚠️ Realtime subscription closed');
          } else if (error != null) {
            print('❌ Realtime subscription error: $error');
          }
        });

    print('✅ Realtime subscription setup for user: $userEmail');
  }

  void _handleRealtimeUpdate(PostgresChangePayload payload) {
    print('📦 Processing realtime update...');

    if (payload.eventType == PostgresChangeEvent.insert) {
      print('📥 INSERT event - ignoring (we already added user message)');
      return;
    }

    if (payload.eventType == PostgresChangeEvent.update) {
      final record = payload.newRecord;
      final chatId = record['id'] as String;
      final status = record['status'] as String;
      final aiResponseText = record['ai_response_text'] as String?;
      final audioUrl = record['audio_url'] as String?;
      final yelpEntitiesJson =
          record['yelp_entities']; // NEW: Get yelp_entities

      print('📊 Update - Chat: $chatId, Status: $status');
      print(
        '📊 AI Response: ${aiResponseText?.substring(0, aiResponseText.length > 50 ? 50 : aiResponseText.length)}',
      );
      print('📊 Audio URL: $audioUrl');
      print('📊 Yelp Entities: $yelpEntitiesJson');

      // Store yelp_chat_id for conversation continuity
      if (record['yelp_chat_id'] != null) {
        _currentYelpChatId = record['yelp_chat_id'] as String;
        print('💬 Yelp Chat ID updated: $_currentYelpChatId');
      }

      // Find the thinking message and update it
      final thinkingIndex = messages.indexWhere((m) => m.isThinking);
      print('🔍 Looking for thinking message... Index: $thinkingIndex');

      if (thinkingIndex != -1) {
        if (status == 'yelp_querying') {
          print('🔄 Updating to: Searching Yelp...');
          final updatedMessage = messages[thinkingIndex].copyWith(
            text: 'Searching Yelp...',
          );
          messages[thinkingIndex] = updatedMessage;
        } else if (status == 'generating_audio') {
          print('🔄 Updating to: Generating voice...');
          final updatedMessage = messages[thinkingIndex].copyWith(
            text: 'Generating voice...',
          );
          messages[thinkingIndex] = updatedMessage;
        } else if (status == 'completed' && aiResponseText != null) {
          print('✅ Completed! Replacing thinking with AI response');

          // NEW: Parse business entities
          List<Business>? businesses;
          if (yelpEntitiesJson != null) {
            try {
              businesses = _parseBusinessEntities(yelpEntitiesJson);
              print('🏢 Parsed ${businesses.length} businesses');
            } catch (e) {
              print('❌ Error parsing businesses: $e');
            }
          }

          // Replace thinking with AI response
          messages.removeAt(thinkingIndex);
          final aiMessage = Message(
            text: aiResponseText,
            isUser: false,
            audioUrl: audioUrl,
            businesses: businesses, // NEW: Add businesses
            isFromHistory: false,
          );
          messages.add(aiMessage);

          print('✅ AI response added: ${aiMessage.toString()}');

          _startAnimatedScrollToBottom(aiResponseText);

          if (audioUrl != null && audioUrl.isNotEmpty) {
            print('🎵 Auto-playing audio...');
            _playAudio(audioUrl);
          }

          isProcessing.value = false;
        } else if (status == 'failed') {
          print('❌ Failed status received');
          messages.removeAt(thinkingIndex);
          final errorMessage = Message(
            text:
                record['error_message'] as String? ??
                'Sorry, something went wrong.',
            isUser: false,
            isFromHistory: false,
          );
          messages.add(errorMessage);
          isProcessing.value = false;
          _scrollToBottom();
        }
      } else {
        print('⚠️ No thinking message found to update');
      }
    }
  }

  List<Business> _parseBusinessEntities(dynamic yelpEntitiesJson) {
    final List<Business> allBusinesses = [];

    if (yelpEntitiesJson is List) {
      for (final entity in yelpEntitiesJson) {
        if (entity is Map<String, dynamic> && entity['businesses'] != null) {
          final businessList = entity['businesses'] as List;
          for (final businessJson in businessList) {
            try {
              final business = Business.fromMap(businessJson);
              allBusinesses.add(business);
            } catch (e) {
              print('❌ Error parsing individual business: $e');
            }
          }
        }
      }
    }

    return allBusinesses;
  }

  // NEW: Animated scroll that follows the text reveal animation
  void _startAnimatedScrollToBottom(String text) {
    final wordCount = text.split(' ').length;
    final totalAnimationTime = wordCount * 60; // 60ms per word

    print(
      '📜 Starting animated scroll for $wordCount words over ${totalAnimationTime}ms',
    );

    // Start scrolling immediately
    _scrollToBottom();

    // Continue scrolling as text reveals
    int scrollUpdates = (totalAnimationTime / 100).ceil(); // Update every 100ms
    for (int i = 1; i <= scrollUpdates; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (scrollController.hasClients) {
          _scrollToBottom(fast: false);
        }
      });
    }

    // Final scroll to ensure we're at bottom
    Future.delayed(Duration(milliseconds: totalAnimationTime + 200), () {
      if (scrollController.hasClients) {
        _scrollToBottom(fast: false);
      }
    });
  }

  void _scrollToBottom({bool fast = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        final position = scrollController.position.maxScrollExtent;
        if (fast) {
          // Instant scroll
          scrollController.jumpTo(position);
        } else {
          // Smooth animated scroll
          scrollController.animateTo(
            position,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  void _debugLog(String method, String message, {bool isError = false}) {
    final prefix = isError ? '❌ ERROR' : '🔍 DEBUG';
    final time = DateTime.now()
        .toIso8601String()
        .split('T')[1]
        .substring(0, 12);
    print('[$time] $prefix [$method]: $message');
  }

  void onSpeechResult(String liveText, String finalText, bool listening) {
    _speechCallCount++;
    _debugLog(
      'onSpeechResult',
      'Call #$_speechCallCount: liveText="${liveText.substring(0, liveText.length > 30 ? 30 : liveText.length)}...", '
          'finalText="${finalText.substring(0, finalText.length > 30 ? 30 : finalText.length)}...", '
          'listening=$listening',
    );

    liveTranscript.value = liveText;

    if (liveText.trim().isNotEmpty) {
      _lastValidLiveText = liveText;
    }

    final trimmedFinal = finalText.trim();
    if (trimmedFinal.isNotEmpty) {
      _debugLog('onSpeechResult', 'Valid final text detected');
      entireTranscript.value = trimmedFinal;
    }

    final bool wasListening = isListening.value;
    isListening.value = listening;

    if (wasListening && !listening) {
      _debugLog('onSpeechResult', 'Speech JUST stopped, processing...');
      _processSpeechCompletion();
    }
  }

  void _processSpeechCompletion() async {
    if (isProcessing.value) {
      _debugLog('_processSpeechCompletion', 'Already processing, skipping');
      return;
    }

    await Future.delayed(const Duration(milliseconds: 300));

    String textToUse = '';

    if (entireTranscript.value.trim().isNotEmpty) {
      textToUse = entireTranscript.value;
    } else if (_lastValidLiveText.trim().isNotEmpty) {
      textToUse = _lastValidLiveText;
    } else {
      _debugLog('_processSpeechCompletion', 'No valid text found, aborting');
      _resetSpeechState();
      return;
    }

    await onSpeechComplete(textToUse);
  }

  Future<void> onSpeechComplete(String userText) async {
    if (isProcessing.value) {
      _debugLog(
        'onSpeechComplete',
        'Already processing, ABORTING',
        isError: true,
      );
      return;
    }

    final trimmedUserText = userText.trim();
    if (trimmedUserText.isEmpty) {
      _debugLog('onSpeechComplete', 'Empty user text, ABORTING');
      _resetSpeechState();
      return;
    }

    isProcessing.value = true;
    _debugLog(
      'onSpeechComplete',
      'Starting processing for: "$trimmedUserText"',
    );

    try {
      HapticFeedback.mediumImpact();

      // Add user message
      await _addUserMessage(trimmedUserText);
      _resetSpeechState();

      await Future.delayed(const Duration(milliseconds: 300));

      // Add thinking message
      await _addThinkingMessage();

      // Call Supabase function
      await _callOrionVoiceChat(trimmedUserText);
    } catch (e) {
      _debugLog('onSpeechComplete', 'ERROR: $e', isError: true);

      // Remove thinking message and show error
      if (messages.isNotEmpty && messages.last.isThinking) {
        messages.removeLast();
      }

      final errorMessage = Message(
        text: 'Sorry, I encountered an error processing your request.',
        isUser: false,
      );
      messages.add(errorMessage);

      isProcessing.value = false;
    }
  }

  Future<void> _callOrionVoiceChat(String userMessage) async {
    try {
      final AuthController authController = Get.find<AuthController>();
      final email = authController.currentUser.value?.email;
      if (email == null) {
        throw Exception('User email not found');
      }

      _debugLog('_callOrionVoiceChat', 'Calling edge function...');
      _debugLog('_callOrionVoiceChat', 'Yelp Chat ID: $_currentYelpChatId');

      final response = await supabase.functions.invoke(
        'orion-voice-chat',
        body: {
          'user_message': userMessage,
          'email': email,
          'yelp_chat_id': _currentYelpChatId,
          // Optional: Add location if available
          // 'user_latitude': _latitude,
          // 'user_longitude': _longitude,
        },
      );

      _debugLog('_callOrionVoiceChat', 'Response status: ${response.status}');
      _debugLog('_callOrionVoiceChat', 'Response data: ${response.data}');

      if (response.status != 200) {
        throw Exception(
          'Function returned ${response.status}: ${response.data}',
        );
      }

      _debugLog('_callOrionVoiceChat', 'Edge function called successfully');

      // The realtime subscription will handle the updates
    } catch (e) {
      _debugLog('_callOrionVoiceChat', 'ERROR: $e', isError: true);
      rethrow;
    }
  }

  Future<void> _addUserMessage(String text) async {
    _messageAddCount++;
    final userMessage = Message(text: text, isUser: true);
    messages.add(userMessage);
    _debugLog('_addUserMessage', 'Added user message #$_messageAddCount');
    _scrollToBottom();
  }

  Future<void> _addThinkingMessage() async {
    final thinkingMessage = Message(
      text: 'Processing...',
      isUser: false,
      isThinking: true,
    );
    messages.add(thinkingMessage);
    _debugLog('_addThinkingMessage', 'Added thinking message');
    _scrollToBottom();
  }

  Future<void> _playAudio(String audioUrl) async {
    try {
      isAudioLoading.value = true;
      _updateMessageAudioState(true);

      await audioPlayer.play(UrlSource(audioUrl));

      _debugLog('_playAudio', 'Audio playback started');
    } catch (e) {
      _debugLog('_playAudio', 'ERROR: $e', isError: true);
    } finally {
      isAudioLoading.value = false;
    }
  }

  void _updateMessageAudioState(bool isPlaying) {
    final lastMessageIndex = messages.length - 1;
    if (lastMessageIndex >= 0 && !messages[lastMessageIndex].isUser) {
      messages[lastMessageIndex] = messages[lastMessageIndex].copyWith(
        isAudioPlaying: isPlaying,
      );
    }
  }

  Future<void> toggleAudioPlayback(int messageIndex) async {
    final message = messages[messageIndex];
    if (message.audioUrl == null) return;

    if (message.isAudioPlaying) {
      await audioPlayer.pause();
      _updateMessageAudioState(false);
    } else {
      await _playAudio(message.audioUrl!);
    }
  }

  void _resetSpeechState() {
    liveTranscript.value = '';
    entireTranscript.value = '';
    _lastValidLiveText = '';
    _debugLog('_resetSpeechState', 'Speech state reset');
  }

  void debugForceClear() {
    _debugLog('debugForceClear', 'Forcing clear of all state');
    messages.clear();
    _resetSpeechState();
    isProcessing.value = false;
    _currentYelpChatId = null;
    _speechCallCount = 0;
    _messageAddCount = 0;
  }
}

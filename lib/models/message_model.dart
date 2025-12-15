import 'dart:convert';

import 'package:yelpable/models/yelp_metadata_model.dart';

class MessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String? content;
  final String messageType; // 'text', 'system', 'image', 'file'
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? replyToId;

  final Welcome? yelpData;

  // Additional fields for UI
  final String? senderName;
  final String? senderProfilePicture;

  // Reply message details
  final MessageModel? replyToMessage;

  MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    this.content,
    required this.messageType,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.replyToId,
    this.senderName,
    this.senderProfilePicture,
    this.replyToMessage,
    this.yelpData,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    Welcome? parsedYelpData;

    // Parse Yelp metadata if exists
    if (json['metadata'] != null) {
      try {
        parsedYelpData = Welcome.fromMap(
          json['metadata'] as Map<String, dynamic>,
        );
      } catch (e) {
        print('Error parsing Yelp metadata: $e');
      }
    }

    return MessageModel(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String?,
      messageType: json['message_type'] as String? ?? 'text',
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      replyToId: json['reply_to_id'] as String?,
      senderName: json['sender_name'] as String?,
      senderProfilePicture: json['sender_profile_picture'] as String?,
      replyToMessage: null, // Will be populated separately
      yelpData: parsedYelpData,
    );
  }
  bool get hasYelpData =>
      yelpData != null &&
      yelpData!.yelpEntities?.isNotEmpty == true &&
      yelpData!.yelpEntities!.first.businesses?.isNotEmpty == true;

  List<Business> get yelpBusinesses {
    if (!hasYelpData) return [];
    return yelpData!.yelpEntities!.first.businesses ?? [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'reply_to_id': replyToId,
      'sender_name': senderName,
      'sender_profile_picture': senderProfilePicture,
    };
  }

  String toJsonString() => json.encode(toJson());

  factory MessageModel.fromJsonString(String jsonString) =>
      MessageModel.fromJson(json.decode(jsonString));

  bool get isSystem => messageType == 'system';
  bool get hasReply => replyToId != null;

  MessageModel copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? content,
    String? messageType,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? replyToId,
    String? senderName,
    String? senderProfilePicture,
    MessageModel? replyToMessage,
    Welcome? yelpData,
  }) {
    return MessageModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replyToId: replyToId ?? this.replyToId,
      senderName: senderName ?? this.senderName,
      senderProfilePicture: senderProfilePicture ?? this.senderProfilePicture,
      replyToMessage: replyToMessage ?? this.replyToMessage,
      yelpData: yelpData ?? this.yelpData,
    );
  }
}

class RoomMemberModel {
  final String userId;
  final String name;
  final String? profilePictureUrl;

  RoomMemberModel({
    required this.userId,
    required this.name,
    this.profilePictureUrl,
  });

  factory RoomMemberModel.fromJson(Map<String, dynamic> json) {
    return RoomMemberModel(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'profile_picture_url': profilePictureUrl,
    };
  }
}

// typing_indicator_model.dart
class TypingIndicatorModel {
  final String userId;
  final String userName;
  final bool isTyping;

  TypingIndicatorModel({
    required this.userId,
    required this.userName,
    required this.isTyping,
  });

  factory TypingIndicatorModel.fromJson(Map<String, dynamic> json) {
    return TypingIndicatorModel(
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? 'Unknown',
      isTyping: json['is_typing'] as bool? ?? false,
    );
  }
}

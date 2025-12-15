// room_model.dart
import 'dart:convert';

class RoomModel {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final String inviteCode;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields for UI
  final String? lastMessageContent;
  final DateTime? lastMessageTime;
  final int unreadCount;

  RoomModel({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.inviteCode,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageContent,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['owner_id'] as String,
      inviteCode: json['invite_code'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastMessageContent: json['last_message_content'] as String?,
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'owner_id': ownerId,
      'invite_code': inviteCode,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_message_content': lastMessageContent,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'unread_count': unreadCount,
    };
  }

  String toJsonString() => json.encode(toJson());

  factory RoomModel.fromJsonString(String jsonString) =>
      RoomModel.fromJson(json.decode(jsonString));

  RoomModel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    String? inviteCode,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessageContent,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      inviteCode: inviteCode ?? this.inviteCode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

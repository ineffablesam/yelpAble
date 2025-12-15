import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:yelpable/models/room_model.dart';
import 'package:yelpable/modules/Auth/Controller/auth_controller.dart';
import 'package:yelpable/modules/Nest/reservation_business_card.dart';
import 'package:yelpable/modules/Nest/yelp_business_carousel.dart';
import 'package:yelpable/utils/sf_font.dart';

import '../../models/yelp_metadata_model.dart';
import 'chat_controller.dart';

class RoomView extends StatefulWidget {
  final RoomModel room;

  const RoomView({super.key, required this.room});

  @override
  State<RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> {
  final ChatController _chatController = Get.find<ChatController>();
  final AuthController _authController = Get.find<AuthController>();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final Map<String, GlobalKey> _messageKeys = {};
  String? _highlightedMessageId;

  @override
  void initState() {
    super.initState();
    _chatController.enterRoom(widget.room);

    ever(_chatController.messages, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });

    _chatController.messageController.addListener(_onTextChanged);
  }

  bool _wasTyping = false;
  void _onTextChanged() {
    final text = _chatController.messageController.text;
    final isTyping = text.isNotEmpty;

    if (isTyping != _wasTyping) {
      _chatController.sendTypingIndicator(isTyping);
      _wasTyping = isTyping;
    }
  }

  @override
  void dispose() {
    _chatController.messageController.removeListener(_onTextChanged);
    _chatController.leaveRoom();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _scrollToMessage(String messageId) {
    final key = _messageKeys[messageId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );

      setState(() => _highlightedMessageId = messageId);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() => _highlightedMessageId = null);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back, color: Color(0xFF1A1A1A)),
            onPressed: () {
              _chatController.leaveRoom();
              Get.back();
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.room.name,
                style: SFPro.font(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Obx(() {
                if (_chatController.typingUsers.isEmpty) {
                  return Text(
                    'Room • ${widget.room.inviteCode}',
                    style: SFPro.font(
                      fontSize: 12.sp,
                      color: const Color(0xFF8E8E93),
                    ),
                  );
                }

                final typingText = _chatController.typingUsers.length == 1
                    ? '${_chatController.typingUsers.first} is typing...'
                    : '${_chatController.typingUsers.join(", ")} are typing...';

                return Text(
                  typingText,
                  style: SFPro.font(
                    fontSize: 12.sp,
                    color: const Color(0xFF007AFF),
                  ),
                );
              }),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                CupertinoIcons.info_circle,
                color: Color(0xFF1A1A1A),
              ),
              onPressed: () => _showRoomInfo(),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (_chatController.isLoadingMessages.value) {
                  return const Center(
                    child: CupertinoActivityIndicator(radius: 14),
                  );
                }

                if (_chatController.messages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 12.h,
                  ),
                  itemCount: _chatController.messages.length,
                  itemBuilder: (context, index) {
                    final message = _chatController.messages[index];
                    final isCurrentUser =
                        message.senderId ==
                        _authController.currentUser.value?.id;

                    final showDateSeparator =
                        index == 0 ||
                        !_isSameDay(
                          message.createdAt,
                          _chatController.messages[index - 1].createdAt,
                        );

                    _messageKeys[message.id] = GlobalKey();

                    return Column(
                      key: _messageKeys[message.id],
                      children: [
                        if (showDateSeparator)
                          _buildDateSeparator(message.createdAt),
                        if (message.isSystem)
                          _buildSystemMessage(message)
                        else
                          _SwipeableMessage(
                            message: message,
                            isCurrentUser: isCurrentUser,
                            isHighlighted: _highlightedMessageId == message.id,
                            onReply: () {
                              _chatController.setReplyTo(message);
                              _messageFocusNode.requestFocus();
                            },
                            child: _buildMessage(message, isCurrentUser),
                          ),
                      ],
                    );
                  },
                );
              }),
            ),
            // Add AI processing indicator here
            Obx(() {
              if (!_chatController.isAIProcessing.value) {
                return const SizedBox.shrink();
              }
              return _buildAIProcessingIndicator();
            }),
            Obx(() {
              if (_chatController.replyingTo.value == null) {
                return const SizedBox.shrink();
              }
              return _buildReplyPreview();
            }),
            Obx(() {
              if (!_chatController.showMentionSuggestions.value ||
                  _chatController.filteredMembers.isEmpty) {
                return const SizedBox.shrink();
              }
              return _buildMentionSuggestions();
            }),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.chat_bubble_text,
            size: 64.sp,
            color: const Color(0xFFD1D1D6),
          ),
          SizedBox(height: 16.h),
          Text(
            'No messages yet',
            style: SFPro.font(
              fontSize: 17.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8E8E93),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Start the conversation!',
            style: SFPro.font(fontSize: 14.sp, color: const Color(0xFFC7C7CC)),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    final reply = _chatController.replyingTo.value!;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE5E5EA), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF),
              borderRadius: BorderRadius.circular(1.5.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reply.senderName ?? "Unknown",
                  style: SFPro.font(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF007AFF),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  reply.content ?? '',
                  style: SFPro.font(
                    fontSize: 14.sp,
                    color: const Color(0xFF3C3C43),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () => _chatController.cancelReply(),
            child: Icon(
              CupertinoIcons.xmark,
              color: const Color(0xFF8E8E93),
              size: 18.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentionSuggestions() {
    return Container(
      constraints: BoxConstraints(maxHeight: 200.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE5E5EA), width: 0.5),
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _chatController.filteredMembers.length,
        itemBuilder: (context, index) {
          final member = _chatController.filteredMembers[index];

          return CupertinoButton(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            onPressed: () => _chatController.selectMention(member),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: const Color(0xFFE5E5EA),
                  backgroundImage: member.profilePictureUrl != null
                      ? NetworkImage(member.profilePictureUrl!)
                      : null,
                  child: member.profilePictureUrl == null
                      ? Icon(
                          CupertinoIcons.person_fill,
                          size: 16.sp,
                          color: const Color(0xFF8E8E93),
                        )
                      : null,
                ),
                SizedBox(width: 12.w),
                Text(
                  member.name,
                  style: SFPro.font(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5EA).withOpacity(0.6),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            _formatDate(date),
            style: SFPro.font(
              fontSize: 12.sp,
              color: const Color(0xFF8E8E93),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemMessage(message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5EA).withOpacity(0.6),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            message.content ?? '',
            style: SFPro.font(
              fontSize: 13.sp,
              color: const Color(0xFF8E8E93),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIProcessingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        border: Border(
          top: BorderSide(color: const Color(0xFFE5E5EA), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF8B5CF6),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'AI is thinking...',
            style: SFPro.font(
              fontSize: 13.sp,
              color: const Color(0xFF8B5CF6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(message, bool isCurrentUser) {
    final isAI = message.senderId == ChatController.AI_USER_ID;
    final isReservationConfirmation =
        message.messageType == 'reservation_confirmation';

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: isCurrentUser ? 60.w : 0,
            right: isCurrentUser ? 0 : 60.w,
            bottom: 2.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: isCurrentUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!isCurrentUser) ...[
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: isAI
                      ? const Color(0xFFE5DEFF)
                      : const Color(0xFFE5E5EA),
                  backgroundImage: message.senderProfilePicture != null
                      ? NetworkImage(message.senderProfilePicture!)
                      : null,
                  child: message.senderProfilePicture == null
                      ? Icon(
                          isAI
                              ? CupertinoIcons.sparkles
                              : CupertinoIcons.person_fill,
                          size: 16.sp,
                          color: isAI
                              ? const Color(0xFF8B5CF6)
                              : const Color(0xFF8E8E93),
                        )
                      : null,
                ),
                SizedBox(width: 8.w),
              ],
              Flexible(
                flex: 1,
                child: GestureDetector(
                  onTap: message.hasReply && message.replyToMessage != null
                      ? () => _scrollToMessage(message.replyToMessage!.id)
                      : null,
                  child: Column(
                    crossAxisAlignment: isCurrentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (!isCurrentUser)
                        Padding(
                          padding: EdgeInsets.only(left: 12.w, bottom: 2.h),
                          child: Text(
                            isAI
                                ? 'AI Assistant'
                                : (message.senderName ?? 'Unknown'),
                            style: SFPro.font(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8E8E93),
                            ),
                          ),
                        ),
                      // Main message bubble
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        clipBehavior: Clip.none,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? const Color(0xFF007AFF)
                              : isAI
                              ? const Color(0x27E8E8E8)
                              : Colors.white,
                          border: Border.all(
                            color: (message.id == _highlightedMessageId)
                                ? isAI
                                      ? Colors.grey.shade300
                                      : const Color(0xFF007AFF)
                                : Colors.grey.shade300,
                            width: 1.w,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                              isCurrentUser ? 18.r : 4.r,
                            ),
                            topRight: Radius.circular(
                              isCurrentUser ? 4.r : 18.r,
                            ),
                            bottomLeft: Radius.circular(18.r),
                            bottomRight: Radius.circular(18.r),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Reply preview
                            if (message.hasReply &&
                                message.replyToMessage != null)
                              Container(
                                margin: EdgeInsets.only(bottom: 6.h),
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? Colors.white.withOpacity(0.2)
                                      : const Color(0xFFF7F8FA),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border(
                                    left: BorderSide(
                                      color: isCurrentUser
                                          ? Colors.white
                                          : const Color(0xFF007AFF),
                                      width: 2.w,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.replyToMessage!.senderName ??
                                          'Unknown',
                                      style: SFPro.font(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: isCurrentUser
                                            ? Colors.white
                                            : const Color(0xFF007AFF),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      message.replyToMessage!.content ?? '',
                                      style: SFPro.font(
                                        fontSize: 13.sp,
                                        color: isCurrentUser
                                            ? Colors.white.withOpacity(0.9)
                                            : const Color(0xFF3C3C43),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            // Message content with highlighted text
                            _buildMessageContent(message, isCurrentUser),
                            SizedBox(height: 4.h),
                            // Timestamp
                            Text(
                              timeago.format(message.createdAt),
                              style: SFPro.font(
                                fontSize: 11.sp,
                                color: isCurrentUser
                                    ? Colors.white.withOpacity(0.7)
                                    : const Color(0xFF8E8E93),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Yelp Business Carousel OR Reservation Confirmation Card
        if (isReservationConfirmation && message.metadata != null)
          ReservationConfirmationCard(
            businessName: message.metadata!['business_name'] ?? 'Unknown',
            partySize: message.metadata!['party_size'] ?? 2,
            timeSlot: message.metadata!['time_slot'] ?? '7:00 PM',
            businessAddress: message.metadata!['business_address'],
            isCurrentUser: isCurrentUser,
          )
        else if (message.hasYelpData)
          YelpBusinessCarousel(
            businesses: message.yelpBusinesses,
            isCurrentUser: isCurrentUser,
            yelpTypes: message.yelpData?.yelpTypes,
            roomId: widget.room.id,
          ),
      ],
    );
  }

  Widget _buildMessageContent(message, bool isCurrentUser) {
    final content = message.content ?? '';

    // Check if there are highlight tags
    if (message.yelpData?.yelpTags?.any((tag) => tag.tagType == 'highlight') !=
        true) {
      return Text(
        content,
        style: SFPro.font(
          fontSize: 15.sp,
          color: isCurrentUser ? Colors.white : const Color(0xFF1A1A1A),
          height: 1.3,
        ),
      );
    }

    // Build text with highlights
    final highlights = message.yelpData!.yelpTags!
        .where((tag) => tag.tagType == 'highlight')
        .toList();

    final spans = <TextSpan>[];
    int lastIndex = 0;

    // Sort highlights by start position
    highlights.sort(
      (YelpTag a, YelpTag b) => (a.start ?? 0).compareTo(b.start ?? 0),
    );

    for (final highlight in highlights) {
      final start = highlight.start ?? 0;
      final end = highlight.end ?? content.length;

      // Add text before highlight
      if (start > lastIndex) {
        spans.add(
          TextSpan(
            text: content.substring(lastIndex, start),
            style: SFPro.font(
              fontSize: 15.sp,
              color: isCurrentUser ? Colors.white : const Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
        );
      }

      // Add highlighted text
      spans.add(
        TextSpan(
          text: content.substring(start, end),
          style: SFPro.font(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: isCurrentUser ? Colors.white : const Color(0xFF007AFF),
            height: 1.3,
          ),
        ),
      );

      lastIndex = end;
    }

    // Add remaining text
    if (lastIndex < content.length) {
      spans.add(
        TextSpan(
          text: content.substring(lastIndex),
          style: SFPro.font(
            fontSize: 15.sp,
            color: isCurrentUser ? Colors.white : const Color(0xFF1A1A1A),
            height: 1.3,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE5E5EA), width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: TextField(
                  controller: _chatController.messageController,
                  focusNode: _messageFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Message',
                    hintStyle: SFPro.font(
                      fontSize: 15.sp,
                      color: const Color(0xFFC7C7CC),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: SFPro.font(fontSize: 15.sp),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Obx(
              () => CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: _chatController.isSendingMessage.value
                    ? null
                    : _chatController.sendMessage,
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    shape: BoxShape.circle,
                  ),
                  child: _chatController.isSendingMessage.value
                      ? Padding(
                          padding: EdgeInsets.all(10.w),
                          child: const CupertinoActivityIndicator(
                            color: Colors.white,
                            radius: 8,
                          ),
                        )
                      : Icon(
                          CupertinoIcons.arrow_up,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoomInfo() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 36.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D1D6),
                  borderRadius: BorderRadius.circular(2.5.r),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                widget.room.name,
                style: SFPro.font(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              if (widget.room.description != null) ...[
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Text(
                    widget.room.description!,
                    style: SFPro.font(
                      fontSize: 15.sp,
                      color: const Color(0xFF8E8E93),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              SizedBox(height: 24.h),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.link,
                      color: const Color(0xFF007AFF),
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invite Code',
                            style: SFPro.font(
                              fontSize: 13.sp,
                              color: const Color(0xFF8E8E93),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            widget.room.inviteCode,
                            style: SFPro.font(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: widget.room.inviteCode),
                        );
                        Get.back();
                        Get.snackbar(
                          'Copied',
                          'Invite code copied to clipboard',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.black87,
                          colorText: Colors.white,
                          margin: EdgeInsets.all(16.w),
                          borderRadius: 12.r,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      child: Icon(
                        CupertinoIcons.doc_on_clipboard,
                        color: const Color(0xFF007AFF),
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _SwipeableMessage extends StatefulWidget {
  final Widget child;
  final VoidCallback onReply;
  final bool isCurrentUser;
  final dynamic message;
  final bool isHighlighted;

  const _SwipeableMessage({
    required this.child,
    required this.onReply,
    required this.isCurrentUser,
    required this.message,
    this.isHighlighted = false,
  });

  @override
  State<_SwipeableMessage> createState() => _SwipeableMessageState();
}

class _SwipeableMessageState extends State<_SwipeableMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _dragExtent = 0;
  bool _dragUnderway = false;
  static const double _kSwipeThreshold = 60.0;
  static const double _kMaxSwipeDistance = 100.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation =
        Tween<double>(begin: 0, end: 0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
        )..addListener(() {
          setState(() {
            _dragExtent = _animation.value;
          });
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _dragUnderway = true;
    _controller.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragUnderway) return;

    final delta = details.primaryDelta ?? 0;
    final direction = widget.isCurrentUser ? -1 : 1;

    // Only allow swipe in the correct direction
    if ((direction > 0 && delta > 0) || (direction < 0 && delta < 0)) {
      setState(() {
        _dragExtent = (_dragExtent + delta).clamp(
          widget.isCurrentUser ? -_kMaxSwipeDistance : 0,
          widget.isCurrentUser ? 0 : _kMaxSwipeDistance,
        );
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragUnderway) return;
    _dragUnderway = false;

    final shouldTrigger = _dragExtent.abs() >= _kSwipeThreshold;

    if (shouldTrigger) {
      widget.onReply();
      HapticFeedback.mediumImpact();
    }

    _animation = Tween<double>(
      begin: _dragExtent,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final swipeProgress = (_dragExtent.abs() / _kSwipeThreshold).clamp(
      0.0,
      1.0,
    );

    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        alignment: widget.isCurrentUser
            ? Alignment.centerRight
            : Alignment.centerLeft,
        children: [
          // Reply icon that appears during swipe
          Positioned(
            right: widget.isCurrentUser ? 20.w : null,
            left: !widget.isCurrentUser ? 20.w : null,
            child: Opacity(
              opacity: swipeProgress,
              child: Transform.scale(
                scale: swipeProgress,
                child: Icon(
                  CupertinoIcons.reply,
                  color: const Color(0xFF8E8E93),
                  size: 24.sp,
                ),
              ),
            ),
          ),
          // Message with elastic transform and highlight
          AnimatedContainer(
            duration: widget.isHighlighted
                ? const Duration(milliseconds: 300)
                : Duration.zero,
            clipBehavior: Clip.none,
            decoration: BoxDecoration(
              color: widget.isHighlighted
                  ? const Color(0xFF007AFF).withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Transform.translate(
              offset: Offset(_dragExtent, 0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

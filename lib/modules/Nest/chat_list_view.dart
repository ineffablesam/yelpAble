import 'dart:ui';

import 'package:blobs/blobs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:yelpable/modules/Nest/room_view.dart';
import 'package:yelpable/utils/sf_font.dart';

import '../../utils/colors.dart';
import '../../utils/custom_tap.dart';
import 'chat_controller.dart';

class ChatListView extends StatelessWidget {
  ChatListView({super.key});

  final ChatController _chatController = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFEEEEEE), const Color(0xFFDDDAF8)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.scaffoldBg,
              surfaceTintColor: AppColors.scaffoldBg,
              pinned: true,
              title: Text(
                'Nest',
                style: SFPro.font(fontSize: 26.sp, fontWeight: FontWeight.w600),
              ),
              actions: [AddAvatar(), BlobAvatar(), 10.horizontalSpace],
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Obx(() {
                    if (_chatController.isLoadingRooms.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_chatController.rooms.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () => _chatController.loadRooms(),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        itemCount: _chatController.rooms.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, indent: 80.w, endIndent: 16.w),
                        itemBuilder: (context, index) {
                          final room = _chatController.rooms[index];
                          return _buildRoomTile(room);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          40.verticalSpace,
          // Image.asset('assets/images/no-rooms.png', width: 280.w),
          Lottie.asset(
            'assets/lottie/empty-room.json',
            width: 200.w,
            repeat: true,
            fit: BoxFit.contain,
          ),
          Text(
            '🌿 Welcome to Nest',
            style: SFPro.font(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text.rich(
              TextSpan(
                text:
                    'Create a Nest to chat, plan, and discover together — with ',
                style: SFPro.font(fontSize: 14.sp, color: Colors.grey.shade500),
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 0.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '@AI',
                        style: SFPro.font(
                          fontSize: 12.sp,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  TextSpan(text: ' ready to help.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTap(
                onTap: () => _showCreateRoomSheet(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        SolarIconsOutline.addCircle,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      8.horizontalSpace,
                      Text(
                        'Create Room',
                        style: SFPro.font(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTile(room) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: CircleAvatar(
        radius: 28.r,
        backgroundColor: Colors.blue.shade100,
        child: Icon(
          CupertinoIcons.group_solid,
          color: Colors.blue.shade700,
          size: 24.sp,
        ),
      ),
      title: Text(
        room.name,
        style: SFPro.font(fontSize: 16.sp, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: room.lastMessageContent != null
          ? Text(
              room.lastMessageContent!,
              style: SFPro.font(fontSize: 14.sp, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : Text(
              'No messages yet',
              style: SFPro.font(fontSize: 14.sp, color: Colors.grey.shade400),
            ),
      trailing: room.lastMessageTime != null
          ? Text(
              timeago.format(room.lastMessageTime!),
              style: SFPro.font(fontSize: 12.sp, color: Colors.grey.shade500),
            )
          : null,
      onTap: () {
        Get.to(() => RoomView(room: room));
      },
    );
  }

  void _showCreateRoomSheet() {
    HapticFeedback.mediumImpact();
    Get.bottomSheet(
      _BuildCreateView(),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      enableDrag: true,
    );
  }
}

class _BuildCreateView extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  _BuildCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController _chatController = Get.find<ChatController>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    return Padding(
      padding: EdgeInsets.all(0.w),
      child: Container(
        height: 0.58.sh,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: CustomTap(
                  onTap: () async {
                    if (formKey.currentState!.validate()) {
                      Get.back();
                      await _chatController.createRoom(
                        nameController.text.trim(),
                        descController.text.trim().isEmpty
                            ? null
                            : descController.text.trim(),
                      );
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Create Room",
                            style: SFPro.font(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // holder
                    SizedBox(height: 0.h),
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    10.verticalSpace,
                    Text(
                      "Create a Room",
                      style: SFPro.font(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Create a space to chat and collaborate",
                      style: SFPro.font(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Room Name",
                      style: SFPro.font(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a room name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "My Awesome Room",
                        hintStyle: SFPro.font(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black38,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: Colors.black87,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.red, width: 1.5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.red, width: 1.5),
                        ),
                        errorStyle: SFPro.font(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.red,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                      style: SFPro.font(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Description (Optional)",
                      style: SFPro.font(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "What's this room about?",
                        hintStyle: SFPro.font(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black38,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: Colors.black87,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                      style: SFPro.font(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BuildJoinView extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  _BuildJoinView({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController _chatController = Get.find<ChatController>();
    final TextEditingController codeController = TextEditingController();

    return Padding(
      padding: EdgeInsets.all(0.w),
      child: Container(
        height: 0.39.sh,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: CustomTap(
                  onTap: () async {
                    if (formKey.currentState!.validate()) {
                      Get.back();
                      await _chatController.joinRoomByInvite(
                        codeController.text.trim(),
                      );
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Join Room",
                            style: SFPro.font(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // holder
                  SizedBox(height: 0.h),
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  6.verticalSpace,
                  Text(
                    "Join a Room",
                    style: SFPro.font(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Enter the invite code to join a room",
                    style: SFPro.font(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Invite Code",
                    style: SFPro.font(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: codeController,
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the invite code';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "ABC123",
                      hintStyle: SFPro.font(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black38,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.black87,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.red, width: 1.5),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.red, width: 1.5),
                      ),
                      errorStyle: SFPro.font(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.red,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                    ),
                    style: SFPro.font(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BlobAvatar extends StatelessWidget {
  const BlobAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomTap(
      onTap: () {
        HapticFeedback.mediumImpact();
        Get.bottomSheet(
          _BuildJoinView(),
          backgroundColor: Colors.white,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          enableDrag: true,
        );
      },
      child: CircleAvatar(
        radius: 22.r,
        backgroundColor: Colors.white.withOpacity(0.1),
        child: CircleAvatar(
          radius: 20.r,
          backgroundImage: Image.asset(
            'assets/images/splash-bg.png',
            fit: BoxFit.scaleDown,
          ).image,
          child: ClipOval(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Blob.animatedRandom(
                  size: 40,
                  loop: true,
                  edgesCount: 5,
                  minGrowth: 2,
                  duration: Duration(milliseconds: 1000),
                  styles: BlobStyles(color: Color(0xFFCF7987)),
                ),
                Blob.animatedRandom(
                  size: 30,
                  loop: true,
                  edgesCount: 5,
                  minGrowth: 4,
                  duration: Duration(milliseconds: 1000),
                  styles: BlobStyles(color: Colors.blue),
                ),
                Blob.animatedRandom(
                  size: 20,
                  loop: true,
                  edgesCount: 9,
                  minGrowth: 4,
                  duration: Duration(milliseconds: 1000),
                  styles: BlobStyles(color: Color(0xFFC934A3)),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Icon(SolarIconsBold.qrCode, size: 16.sp, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddAvatar extends StatelessWidget {
  const AddAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomTap(
      onTap: () {
        HapticFeedback.mediumImpact();
        Get.bottomSheet(
          _BuildCreateView(),
          backgroundColor: Colors.white,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          enableDrag: true,
        );
      },
      child: CircleAvatar(
        radius: 22.r,
        backgroundColor: Colors.white.withOpacity(0.1),
        child: Icon(CupertinoIcons.add_circled),
      ),
    );
  }
}

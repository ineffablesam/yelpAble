import 'dart:ui';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:speech_to_text_ultra/speech_to_text_ultra.dart';
import 'package:yelpable/utils/colors.dart';
import 'package:yelpable/utils/sf_font.dart';

import 'orion_business_card.dart';
import 'orion_controller.dart';

class OrionView extends StatelessWidget {
  const OrionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrionController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: CustomScrollView(
        physics: NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.scaffoldBg,
            surfaceTintColor: AppColors.scaffoldBg,
            elevation: 0,
            centerTitle: true,
            stretch: true,
            title: Row(
              children: [
                Text(
                  'Orion',
                  style: SFPro.font(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                10.horizontalSpace,
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Supercharged by',
                          style: SFPro.font(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
                          ),
                        ),
                        VerticalDivider(
                          indent: 3,
                          endIndent: 2,
                          color: Colors.black.withOpacity(0.2),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 0.h),
                          child: SvgPicture.asset(
                            'assets/images/yelp.svg',
                            width: 32.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            child: Stack(
              children: [
                // Background gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFEEEEEE),
                        const Color(0xFFDDDAF8),
                      ],
                    ),
                  ),
                ),
                // Chat messages
                Positioned(
                  top: 10.h,
                  left: 0,
                  right: 0,
                  bottom: 300.h,
                  child: Obx(() {
                    // Show loading indicator while loading history
                    if (controller.isLoadingHistory.value) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: const Color(0xFF6366F1),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Loading chat history...',
                              style: SFPro.font(
                                fontSize: 14.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (controller.messages.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80.w,
                                height: 80.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF6366F1,
                                      ).withOpacity(0.1),
                                      blurRadius: 30,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 40.sp,
                                  color: const Color(0xFF6366F1),
                                ),
                              ),
                              SizedBox(height: 24.h),
                              Text(
                                'Talk to Orion',
                                textAlign: TextAlign.center,
                                style: SFPro.font(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E293B),
                                  letterSpacing: -0.4,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'Ask anything. Discover places.\nGet instant answers.',
                                textAlign: TextAlign.center,
                                style: SFPro.font(
                                  fontSize: 15.sp,
                                  height: 1.5,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              SizedBox(height: 80.h),
                            ],
                          ),
                        ),
                      );
                    }

                    return FadingEdgeScrollView.fromScrollView(
                      gradientFractionOnStart: 0.6,
                      gradientFractionOnEnd: 0.6,
                      child: ListView.builder(
                        controller: controller.scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        shrinkWrap: true,
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          final message = controller.messages[index];
                          return ChatBubbleAnimated(
                            message: message,
                            index: index,
                            onAudioToggle: () =>
                                controller.toggleAudioPlayback(index),
                          );
                        },
                      ),
                    );
                  }),
                ),

                // Live transcript overlay
                Obx(() {
                  final combinedText = controller.entireTranscript.value.isEmpty
                      ? controller.liveTranscript.value
                      : '${controller.entireTranscript.value} ${controller.liveTranscript.value}';

                  if (combinedText.isNotEmpty && controller.isListening.value) {
                    return Positioned(
                      bottom: 540.h,
                      left: 20.w,
                      right: 20.w,
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 400),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withOpacity(0.2),
                                  width: 1.5,
                                ),
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: const Color(
                                //       0xFF6366F1,
                                //     ).withOpacity(0.15),
                                //     blurRadius: 30,
                                //     spreadRadius: 0,
                                //     offset: Offset(0, 8.h),
                                //   ),
                                // ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 6.w, // outer circle (12.w diameter)
                                    backgroundColor: const Color(0x5110B981),
                                    child: CircleAvatar(
                                      radius:
                                          4.w, // inner circle (8.w diameter)
                                      backgroundColor: const Color(0xFF10B981),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      combinedText,
                                      style: SFPro.font(
                                        fontSize: 15.sp,
                                        color: const Color(0xFF232323),
                                        height: 1.5,
                                        fontWeight: FontWeight.w500,
                                      ),
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
                  return SizedBox.shrink();
                }),

                // Bottom control panel
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32.r),
                      topRight: Radius.circular(32.r),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        height: 270.h,
                        decoration: BoxDecoration(color: Colors.transparent),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 90.r,
                              backgroundImage: Image.asset(
                                'assets/images/mic-bg.png',
                              ).image,
                              backgroundColor: Colors.transparent,
                              child: SpeechToTextUltra(
                                ultraCallback:
                                    (liveText, finalText, isListening) {
                                      controller.onSpeechResult(
                                        liveText,
                                        finalText,
                                        isListening,
                                      );
                                    },
                                toPauseIcon: _buildCustomButton(true),
                                toStartIcon: _buildCustomButton(false),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Obx(
                              () => AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  controller.isListening.value
                                      ? 'Listening...'
                                      : 'Tap & hold to speak',
                                  key: ValueKey(controller.isListening.value),
                                  style: SFPro.font(
                                    fontSize: 15.sp,
                                    color: controller.isListening.value
                                        ? const Color(0xFF6366F1)
                                        : const Color(0xFF64748B),
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Obx(
                              () => controller.isListening.value
                                  ? _buildWaveform()
                                  : SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Icon _buildCustomButton(bool isListening) {
    // if is listening,trigger haptic feedback
    if (isListening) {
      HapticFeedback.mediumImpact();
    }
    return Icon(
      isListening ? LucideIcons.micOff : LucideIcons.mic,
      size: 48.sp,
      color: const Color(0xFFFFFFFF),
    );
  }

  Widget _buildWaveform() {
    return SizedBox(
      height: 30.h,
      width: 120.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(5, (index) {
          return AnimatedWaveBar(index: index);
        }),
      ),
    );
  }
}

class AnimatedWaveBar extends StatefulWidget {
  final int index;

  const AnimatedWaveBar({Key? key, required this.index}) : super(key: key);

  @override
  State<AnimatedWaveBar> createState() => _AnimatedWaveBarState();
}

class _AnimatedWaveBarState extends State<AnimatedWaveBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 4.w,
          height: 30.h * _animation.value,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: const Color(0xFFD4D4D5),
            borderRadius: BorderRadius.circular(2.r),
          ),
        );
      },
    );
  }
}

class ChatBubbleAnimated extends StatefulWidget {
  final Message message;
  final int index;
  final VoidCallback? onAudioToggle;

  const ChatBubbleAnimated({
    Key? key,
    required this.message,
    required this.index,
    this.onAudioToggle,
  }) : super(key: key);

  @override
  State<ChatBubbleAnimated> createState() => _ChatBubbleAnimatedState();
}

class _ChatBubbleAnimatedState extends State<ChatBubbleAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _blurAnimation = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Skip bubble animation for messages from history
    if (widget.message.isFromHistory) {
      _controller.value = 1.0; // Jump to end
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var iconSize = 15.sp;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: _blurAnimation.value,
                sigmaY: _blurAnimation.value,
              ),
              child: child,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: widget.message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Main chat bubble
          Align(
            alignment: widget.message.isUser
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              constraints: BoxConstraints(maxWidth: 280.w),
              decoration: BoxDecoration(
                gradient: widget.message.isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      )
                    : null,
                color: widget.message.isUser ? null : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: widget.message.isUser
                        ? const Color(0xFF6366F1).withOpacity(0.3)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.message.isThinking
                      ? _buildThinkingDots()
                      : TypewriterText(
                          text: widget.message.text,
                          isUser: widget.message.isUser,
                          isFromHistory: widget.message.isFromHistory,
                        ),
                  if (widget.message.audioUrl != null &&
                      !widget.message.isUser) ...[
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: widget.onAudioToggle,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PlayPauseIcon(
                                  isPlaying: widget.message.isAudioPlaying,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 0.h),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 12,
                                  children: [
                                    Icon(
                                      LucideIcons.thumbsUp,
                                      size: iconSize,
                                      color: Colors.grey.shade700,
                                    ),
                                    Icon(
                                      LucideIcons.thumbsDown,
                                      size: iconSize,
                                      color: Colors.grey.shade700,
                                    ),
                                    Icon(
                                      LucideIcons.share2,
                                      size: iconSize,
                                      color: Colors.grey.shade700,
                                    ),
                                    Icon(
                                      LucideIcons.copy,
                                      size: iconSize,
                                      color: Colors.grey.shade700,
                                    ),
                                    Icon(
                                      LucideIcons.ellipsisVertical,
                                      size: iconSize,
                                      color: Colors.grey.shade700,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Business carousel (if businesses exist)
          if (widget.message.businesses != null &&
              widget.message.businesses!.isNotEmpty &&
              !widget.message.isUser) ...[
            SizedBox(height: 8.h),
            BusinessCarouselCard(businesses: widget.message.businesses!),
            SizedBox(height: 8.h),
          ],
        ],
      ),
    );
  }

  Widget _buildThinkingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return ThinkingDot(index: index);
      }),
    );
  }
}

class PlayPauseIcon extends StatefulWidget {
  final bool isPlaying;
  const PlayPauseIcon({super.key, required this.isPlaying});

  @override
  State<PlayPauseIcon> createState() => _PlayPauseIconState();
}

class _PlayPauseIconState extends State<PlayPauseIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: widget.isPlaying ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant PlayPauseIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedIcon(
      icon: AnimatedIcons.play_pause,
      progress: _controller,
      size: 20.sp,
      color: const Color(0xFF6366F1),
    );
  }
}

class ThinkingDot extends StatefulWidget {
  final int index;

  const ThinkingDot({Key? key, required this.index}) : super(key: key);

  @override
  State<ThinkingDot> createState() => _ThinkingDotState();
}

class _ThinkingDotState extends State<ThinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          widget.index * 0.2,
          0.6 + (widget.index * 0.2),
          curve: Curves.easeInOut,
        ),
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8.w,
          height: 8.h,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: const Color(0xFF94A3B8).withOpacity(_animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final bool isUser;
  final bool isFromHistory; // NEW: Flag to skip animation for old messages

  const TypewriterText({
    Key? key,
    required this.text,
    required this.isUser,
    this.isFromHistory = false, // Default false for new messages
  }) : super(key: key);

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  List<String> words = [];
  List<bool> wordVisibility = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Split text into words
    words = widget.text.split(' ');
    wordVisibility = List.filled(words.length, false);

    // Skip animation for user messages or history messages
    if (widget.isUser || widget.isFromHistory) {
      // Show all words immediately
      wordVisibility = List.filled(words.length, true);
      setState(() {});
    } else {
      // Animate new AI messages
      _controller = AnimationController(
        duration: Duration(milliseconds: words.length * 80), // Adjust timing
        vsync: this,
      );
      _animateWords();
    }
  }

  void _animateWords() async {
    for (int i = 0; i < words.length; i++) {
      if (mounted) {
        await Future.delayed(Duration(milliseconds: 60)); // Word delay
        setState(() {
          wordVisibility[i] = true;
        });
      }
    }
  }

  @override
  void dispose() {
    if (!widget.isUser && !widget.isFromHistory) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(words.length, (index) {
        return AnimatedWordReveal(
          word: words[index],
          isVisible: wordVisibility[index],
          isUser: widget.isUser,
          isLast: index == words.length - 1,
        );
      }),
    );
  }
}

class AnimatedWordReveal extends StatefulWidget {
  final String word;
  final bool isVisible;
  final bool isUser;
  final bool isLast;

  const AnimatedWordReveal({
    Key? key,
    required this.word,
    required this.isVisible,
    required this.isUser,
    required this.isLast,
  }) : super(key: key);

  @override
  State<AnimatedWordReveal> createState() => _AnimatedWordRevealState();
}

class _AnimatedWordRevealState extends State<AnimatedWordReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Gemini-style smooth reveal curve
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    // Opacity: 0 → 1
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curve);

    // Blur: 8 → 0 (heavy blur to clear)
    _blurAnimation = Tween<double>(begin: 8.0, end: 0.0).animate(curve);

    // Scale: 0.95 → 1.0 (subtle zoom)
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(curve);

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedWordReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: _blurAnimation.value,
                sigmaY: _blurAnimation.value,
              ),
              child: child,
            ),
          ),
        );
      },
      child: Text(
        widget.word + (widget.isLast ? '' : ' '),
        style: SFPro.font(
          fontSize: 15.sp,
          color: widget.isUser ? Colors.white : const Color(0xFF1E293B),
          height: 1.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

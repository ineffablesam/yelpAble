import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yelpable/modules/Account/account_view.dart';
import 'package:yelpable/modules/Home/home_view.dart';
import 'package:yelpable/modules/Nest/chat_list_view.dart';
import 'package:yelpable/modules/Orion/orion_view.dart';

import '../Reely/reely_view.dart';
import 'Controller/layout_controller.dart';

class LayoutView extends GetView<LayoutController> {
  const LayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LayoutController());
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF0373F3),
              strokeWidth: 1,
            ),
          ),
        );
      }

      final pages = <Widget>[
        HomeView(key: ValueKey('home')),
        ReelyPage(key: ValueKey('reely')),
        ChatListView(key: ValueKey('nest')),
        OrionView(key: ValueKey('orion')),
        AccountView(key: ValueKey('account')),
      ];

      return Scaffold(
        backgroundColor: Colors.white,
        body: AdaptiveScaffold(
          minimizeBehavior: TabBarMinimizeBehavior.never,
          enableBlur: true,

          body: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 350),
            reverse: controller.currentIndex < controller.previousPageIndex,
            transitionBuilder: (child, animation, secondaryAnimation) {
              return SharedAxisTransition(
                fillColor: Colors.white,
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              );
            },
            child: pages[controller.currentIndex],
          ),

          /// -------------------------------
          /// 🔥 Adaptive Bottom Navigation Bar
          /// -------------------------------
          bottomNavigationBar: AdaptiveBottomNavigationBar(
            selectedItemColor: Color(0xFFFF0000),
            selectedIndex: controller.currentIndex,
            unselectedItemColor: Colors.grey,
            useNativeBottomBar: true,
            onTap: (index) {
              HapticFeedback.lightImpact();
              controller.updatePageIndex(index);
            },
            items: [
              // Home – obvious & correct
              AdaptiveNavigationDestination(
                icon: "house",
                selectedIcon: "house.fill",
                label: "Home",
              ),

              // Reely – AI summaries of Instagram Reels
              // "sparkles.rectangle.stack" = content + AI processing
              AdaptiveNavigationDestination(
                icon: "sparkles.rectangle.stack",
                selectedIcon: "sparkles.rectangle.stack.fill",
                label: "Reely",
              ),

              // Nest – AI chat rooms (NOT search)
              // "bubble.left.and.bubble.right" = group conversations
              AdaptiveNavigationDestination(
                icon: "bubble.left.and.bubble.right",
                selectedIcon: "bubble.left.and.bubble.right.fill",
                label: "Nest",
              ),

              // Orion – AI voice-based chat
              // "waveform" strongly implies voice / audio AI
              AdaptiveNavigationDestination(
                icon: "waveform",
                selectedIcon: "waveform.circle.fill",
                label: "Orion",
              ),

              // Account (replaced Favorites)
              AdaptiveNavigationDestination(
                icon: "person",
                selectedIcon: "person.fill",
                label: "Account",
              ),
            ],
          ),
        ),
      );
    });
  }
}

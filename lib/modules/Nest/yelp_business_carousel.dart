import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:yelpable/models/yelp_metadata_model.dart';
import 'package:yelpable/modules/Nest/chat_controller.dart';
import 'package:yelpable/modules/Nest/reservation_business_card.dart';
import 'package:yelpable/modules/Nest/yelp_business_card.dart';

class YelpBusinessCarousel extends StatelessWidget {
  final List<Business> businesses;
  final bool isCurrentUser;
  final List<String>? yelpTypes;
  final String? roomId;

  const YelpBusinessCarousel({
    super.key,
    required this.businesses,
    this.isCurrentUser = false,
    this.yelpTypes,
    this.roomId,
  });

  bool get isReservationType {
    return yelpTypes?.contains('reservation') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (businesses.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 8.h, bottom: 4.h, left: 30.w, right: 0.w),
      clipBehavior: Clip.none,
      height: _calculateCardHeight(),
      padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
      child: ListView.builder(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: businesses.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (isReservationType) {
            return ReservationBusinessCard(
              business: businesses[index],
              isCurrentUser: isCurrentUser,
              onReservationConfirmed: () =>
                  _sendConfirmationMessage(context, businesses[index]),
            );
          } else {
            return YelpBusinessCard(
              business: businesses[index],
              isCurrentUser: isCurrentUser,
            );
          }
        },
      ),
    );
  }

  void _sendConfirmationMessage(BuildContext context, Business business) {
    final ChatController chatController = Get.find<ChatController>();

    // Send a system message with reservation confirmation
    chatController.sendReservationConfirmation(
      businessName: business.name ?? 'Unknown Business',
      businessAddress: business.location?.formattedAddress,
      partySize: 2, // You can pass this from the reservation card if needed
      timeSlot:
          '7:00 PM', // You can pass this from the reservation card if needed
    );
  }

  double _calculateCardHeight() {
    // Base heights
    double height = 105.h;

    final hasPhotos = businesses.any(
      (b) => b.contextualInfo?.photos?.isNotEmpty == true,
    );
    if (hasPhotos) {
      height += 160.h;
    }

    final hasSummary = businesses.any((b) => b.summaries?.short != null);
    if (hasSummary) {
      height += 55.h;
    }

    final hasCategories = businesses.any(
      (b) => b.categories?.isNotEmpty == true,
    );
    if (hasCategories) {
      height += 32.h;
    }

    final hasAttributes = businesses.any(
      (b) =>
          b.attributes?.goodForKids == true ||
          b.attributes?.wiFi == 'free' ||
          b.attributes?.restaurantsTakeOut == true ||
          b.attributes?.restaurantsDelivery == true,
    );
    if (hasAttributes) {
      height += 32.h;
    }

    // If it's reservation type, add extra height for party size and time slots
    if (isReservationType) {
      height += 110.h; // Party size + Time slots
    }

    height += 30.h;

    return height.clamp(280.h, 550.h);
  }
}

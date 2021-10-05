import 'package:flutter/material.dart';
import 'package:hotel_booking_app/features/detail/ui/review/review_item.dart';
import 'package:hotel_booking_app/model/review_model.dart';

class HotelReviewTab extends StatelessWidget {
  const HotelReviewTab({
    Key? key,
    this.reviews,
  }) : super(key: key);

  final List<Review>? reviews;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: reviews!.length,
        itemBuilder: (context, index) => ReviewItem(review: reviews![index]),
      ),
    );
  }
}

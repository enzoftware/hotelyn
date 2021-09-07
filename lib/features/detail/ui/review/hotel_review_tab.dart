import 'package:buscatelo/model/review_model.dart';
import 'package:flutter/material.dart';

import 'review_item.dart';

class HotelReviewTab extends StatelessWidget {
  final List<Review>? reviews;
  const HotelReviewTab({
    Key? key,
    this.reviews,
  }) : super(key: key);

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

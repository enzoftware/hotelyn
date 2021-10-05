import 'package:flutter/material.dart';
import 'package:hotel_booking_app/model/review_model.dart';

class ReviewItem extends StatelessWidget {
  const ReviewItem({
    Key? key,
    this.review,
  }) : super(key: key);

  final Review? review;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(review!.userImage!),
        title: Text(review!.message!),
        subtitle: Text(review!.user!),
        trailing: Text(review!.rate.toString()),
      ),
    );
  }
}

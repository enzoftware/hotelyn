import 'package:buscatelo/model/hotel_model.dart';
import 'package:flutter/material.dart';

class ReviewItem extends StatelessWidget {
  final Review review;
  const ReviewItem({
    Key key,
    this.review,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(review.userImage),
        title: Text(review.message),
        subtitle: Text(review.user),
        trailing: Text(review.rate.toString()),
      ),
    );
  }
}

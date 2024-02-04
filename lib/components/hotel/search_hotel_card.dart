import 'package:flutter/material.dart';
import 'package:hotelyn/core/domain/hotel/hotel.dart';

class SearchHotelCard extends StatelessWidget {
  const SearchHotelCard({super.key, required this.hotel});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Image.asset('name'),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(hotel.name),
              Text(hotel.price),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(hotel.location),
              const Text('Per night'),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

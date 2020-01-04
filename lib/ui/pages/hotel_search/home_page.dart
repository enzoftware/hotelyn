import 'package:buscatelo/model/hotel_model.dart';
import 'package:buscatelo/ui/pages/hotel_search/hotel_item.dart';
import 'package:buscatelo/ui/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';

class HotelSearchPage extends StatelessWidget {
  final List<Widget> hotels = [
    HotelItem(
      hotel: HotelModel(
        name: 'ArtHouse New York City',
        address: '90% Upper West Side',
        price: 1440.0,
      ),
    ),
    HotelItem(
      hotel: HotelModel(
        name: 'ArtHouse New York City',
        address: '90% Upper West Side',
        price: 1440.0,
      ),
    ),
    HotelItem(
      hotel: HotelModel(
        name: 'ArtHouse New York City',
        address: '90% Upper West Side',
        price: 1440.0,
      ),
    ),
    HotelItem(
      hotel: HotelModel(
        name: 'ArtHouse New York City',
        address: '90% Upper West Side',
        price: 1440.0,
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: hotels.length,
                itemBuilder: (_, index) => hotels[index],
              ),
            ),
            BottomBar(),
          ],
        ),
      ),
    );
  }
}

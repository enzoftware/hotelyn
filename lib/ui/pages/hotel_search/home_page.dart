import 'package:buscatelo/model/hotel_model.dart';
import 'package:buscatelo/ui/pages/hotel_search/hotel_item.dart';
import 'package:buscatelo/ui/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';

class HotelSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Container(
                    child: HotelItem(
                      hotel: HotelModel(
                        name: 'eL MATI',
                        address: 'el mati no se bana',
                        price: 233.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            BottomBar(),
          ],
        ),
      ),
    );
  }
}

import 'package:buscatelo/model/hotel_model.dart';
import 'package:flutter/material.dart';

class HotelDetailPage extends StatefulWidget {
  final HotelModel hotelModel;

  HotelDetailPage({Key key, this.hotelModel}) : super(key: key);

  @override
  _HotelDetailPageState createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  bool isFav = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
        )
    );
  }
}
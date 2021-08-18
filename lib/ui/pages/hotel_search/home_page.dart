import 'package:buscatelo/bloc/hotel_bloc.dart';
import 'package:buscatelo/ui/pages/hotel_search/hotel_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HotelSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hotelBloc = Provider.of<HotelBloc>(context);
    return Scaffold(
      body: HotelListBody(hotelBloc: hotelBloc),
    );
  }
}

class HotelListBody extends StatelessWidget {
  const HotelListBody({
    Key? key,
    required this.hotelBloc,
  }) : super(key: key);

  final HotelBloc hotelBloc;

  @override
  Widget build(BuildContext context) {
    if (hotelBloc.failure != null) {
      return Center(child: Text(hotelBloc.failure.toString()));
    }
    if (hotelBloc.hotels == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            height: 280,
            width: 320,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(220),
                topRight: Radius.circular(30),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 64.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discover\nSuitable Hotel',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Icon(Icons.search, size: 36)
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 105, 0, 0),
          child: ListView.builder(
            itemCount: hotelBloc.hotels!.length,
            itemBuilder: (_, index) => HotelItem(
              hotel: hotelBloc.hotels![index],
              key: UniqueKey(),
            ),
          ),
        ),
      ],
    );
  }
}

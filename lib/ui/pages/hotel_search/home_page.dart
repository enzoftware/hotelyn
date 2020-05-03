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
    Key key,
    @required this.hotelBloc,
  }) : super(key: key);

  final HotelBloc hotelBloc;

  @override
  Widget build(BuildContext context) {
    if (hotelBloc.hotels == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: hotelBloc.hotels.length,
            itemBuilder: (_, index) => HotelItem(
              hotel: hotelBloc.hotels[index],
              key: UniqueKey(),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:buscatelo/model/hotel_model.dart';
import 'package:flutter/material.dart';

class HotelItem extends StatelessWidget {
  final HotelModel hotel;
  static const String HOTEL_IMG_URL =
      'https://r-cf.bstatic.com/images/hotel/max1024x768/146/146489863.jpg';

  const HotelItem({Key key, this.hotel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Image.network(HOTEL_IMG_URL),
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Card(
              margin: const EdgeInsets.only(
                top: 150,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color: Colors.blue,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('FOR RENT'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(hotel.price.toString()),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text(hotel.name),
                    subtitle: Text(hotel.address),
                    trailing: Container(
                      child: Icon(
                        Icons.navigation,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

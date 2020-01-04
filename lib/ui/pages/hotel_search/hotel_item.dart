import 'package:buscatelo/commons/theme.dart';
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(HOTEL_IMG_URL),
            ),
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
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                8.00,
                              ),
                            ),
                            color: primaryColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'FOR RENT',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'S/. ${hotel.price.toString()}',
                          style: priceTextStyle,
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text(
                      hotel.name,
                      style: titleTextStyle,
                    ),
                    subtitle: Text(hotel.address),
                    trailing: Container(
                      decoration: BoxDecoration(
                          color: accentColor, shape: BoxShape.circle),
                      child: Transform.rotate(
                        angle: 25 * 3.1416 / 180,
                        child: IconButton(
                          icon: Icon(Icons.navigation),
                          onPressed: () {},
                          color: Colors.white,
                        ),
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

  final TextStyle priceTextStyle = const TextStyle(
    color: Colors.black,
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
  );

  final TextStyle titleTextStyle = const TextStyle(
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );
}

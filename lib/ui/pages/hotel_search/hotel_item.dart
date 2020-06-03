import 'package:buscatelo/commons/theme.dart';
import 'package:buscatelo/model/hotel_model.dart';
import 'package:buscatelo/ui/pages/hotel_detail/hotel_detail_page.dart';
import 'package:flutter/material.dart';

class HotelItem extends StatelessWidget {
  final HotelModel hotel;

  const HotelItem({Key key, this.hotel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HotelDetailPage(hotel),
        ),
      ),
      child: Container(
        child: Stack(
          children: <Widget>[
            Hero(
              tag: Key('key' + hotel.imageUrl),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(hotel.imageUrl),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                margin: const EdgeInsets.only(top: 200),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: primaryColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'FOR RENT',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'S/ ${hotel.price.toString()}',
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

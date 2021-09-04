import 'package:buscatelo/commons/theme.dart';
import 'package:buscatelo/model/hotel_model.dart';
import 'package:buscatelo/features/detail/ui/hotel_detail_page.dart';
import 'package:buscatelo/widgets/hotel_price_text.dart';
import 'package:buscatelo/widgets/ticket_rent.dart';
import 'package:flutter/material.dart';

class HotelItem extends StatelessWidget {
  final HotelModel hotel;

  const HotelItem({Key? key, required this.hotel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HotelDetailPage.init(hotel.name),
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
                  child: Image.network(
                    hotel.imageUrl,
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: 240,
                  ),
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
                          child: TicketRent(
                            color: primaryColor,
                            title: 'FOR RENT',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: HotelPriceText(price: hotel.price.toDouble()),
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

  final TextStyle titleTextStyle = const TextStyle(
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );
}

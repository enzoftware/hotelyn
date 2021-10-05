import 'package:flutter/material.dart';
import 'package:hotel_booking_app/commons/theme.dart';
import 'package:hotel_booking_app/features/detail/ui/hotel_detail_page.dart';
import 'package:hotel_booking_app/model/hotel_model.dart';
import 'package:hotel_booking_app/widgets/hotel_price_text.dart';
import 'package:hotel_booking_app/widgets/ticket_rent.dart';

class HotelItem extends StatelessWidget {
  const HotelItem({Key? key, required this.hotel}) : super(key: key);

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (_) => HotelDetailPage.init(hotel.name),
        ),
      ),
      child: Stack(
        children: <Widget>[
          Hero(
            tag: Key('key${hotel.imageUrl}'),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
            padding: const EdgeInsets.all(40),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.only(top: 200),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: TicketRent(
                          color: primaryColor,
                          title: 'FOR RENT',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
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
                      decoration: const BoxDecoration(
                          color: accentColor, shape: BoxShape.circle),
                      child: Transform.rotate(
                        angle: 25 * 3.1416 / 180,
                        child: IconButton(
                          icon: const Icon(Icons.navigation),
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
}

TextStyle titleTextStyle = const TextStyle(
  color: Colors.black,
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

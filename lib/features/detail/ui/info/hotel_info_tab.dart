import 'package:flutter/material.dart';
import 'package:hotel_booking_app/commons/theme.dart';
import 'package:hotel_booking_app/features/detail/ui/info/amenitie_item.dart';
import 'package:hotel_booking_app/model/hotel_model.dart';
import 'package:hotel_booking_app/widgets/hotel_price_text.dart';
import 'package:hotel_booking_app/widgets/ticket_rent.dart';

class HotelInformationTab extends StatefulWidget {
  const HotelInformationTab({
    Key? key,
    required this.hotel,
  }) : super(key: key);

  final Hotel hotel;

  @override
  _HotelInformationTabState createState() => _HotelInformationTabState();
}

class _HotelInformationTabState extends State<HotelInformationTab> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TicketRent(
              title: 'FOR RENT',
              color: primaryColor,
            ),
            HotelPriceText(price: widget.hotel.price.toDouble())
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.hotel.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontFamily: 'Avenir',
            fontWeight: FontWeight.w700,
          ),
        ),
        const Divider(height: 2, color: Colors.grey),
        const SizedBox(height: 14),
        AnimatedContainer(
          width: 200,
          height: selected ? 250.0 : 100.0,
          alignment:
              selected ? Alignment.center : AlignmentDirectional.topCenter,
          duration: const Duration(seconds: 2),
          curve: Curves.fastOutSlowIn,
          child: Text(widget.hotel.description),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              selected = !selected;
            });
          },
          child: Text(
            selected ? 'Less information' : 'More information',
            style: const TextStyle(color: primaryColor),
          ),
        ),
        Text('Amenities', style: Theme.of(context).textTheme.headline6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 90),
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: widget.hotel.amenities.length,
            itemBuilder: (_, index) =>
                AmenitieItem(amenitie: widget.hotel.amenities[index]),
          ),
        ),
      ],
    );
  }
}

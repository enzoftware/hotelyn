import 'package:buscatelo/features/home/provider/hotel_provider.dart';
import 'package:buscatelo/features/home/ui/hotel_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../dependencies.dart';

class HotelSearchPage extends StatelessWidget {
  const HotelSearchPage({Key? key}) : super(key: key);

  static Widget init() {
    final provider = getIt<HotelProvider>();
    return ChangeNotifierProvider.value(
      value: provider..retrieveHotels(),
      child: const HotelSearchPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HotelListBody(provider: Provider.of<HotelProvider>(context)),
    );
  }
}

class HotelListBody extends StatelessWidget {
  const HotelListBody({
    Key? key,
    required this.provider,
  }) : super(key: key);

  final HotelProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.failure != null) {
      return Center(child: Text(provider.failure.toString()));
    }
    if (provider.hotels == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            height: 280,
            width: 320,
            decoration: const BoxDecoration(
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
            children: const [
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
            itemCount: provider.hotels!.length,
            itemBuilder: (_, index) => HotelItem(
              hotel: provider.hotels![index],
              key: UniqueKey(),
            ),
          ),
        ),
      ],
    );
  }
}

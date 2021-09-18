import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_booking_app/data/repository/hotel_repository.dart';
import 'package:hotel_booking_app/dependencies.dart';
import 'package:hotel_booking_app/features/base/result_state.dart';
import 'package:hotel_booking_app/features/home/cubit/hotel_cubit.dart';
import 'package:hotel_booking_app/features/home/ui/hotel_item.dart';
import 'package:hotel_booking_app/model/hotel_model.dart';

class HotelSearchPage extends StatelessWidget {
  const HotelSearchPage({Key? key}) : super(key: key);

  static Widget init() {
    return BlocProvider(
      create: (_) => HotelCubit(getIt.get<HotelRepository>()),
      child: const HotelSearchPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HotelListBody(),
    );
  }
}

class HotelListBody extends StatefulWidget {
  const HotelListBody({Key? key}) : super(key: key);

  @override
  State<HotelListBody> createState() => _HotelListBodyState();
}

class _HotelListBodyState extends State<HotelListBody> {
  @override
  void initState() {
    context.read<HotelCubit>().loadHotels();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HotelCubit, ResultState<List<Hotel>>>(
      builder: (context, state) {
        return state.when(
          initial: () => Container(),
          loading: () => const Center(child: CircularProgressIndicator()),
          data: (data) => HotelBodyData(data: data),
          error: (e) => Center(child: Text(e.toString())),
        );
      },
      listener: (context, state) {},
    );
  }
}

class HotelBodyData extends StatelessWidget {
  const HotelBodyData({
    Key? key,
    required this.data,
  }) : super(key: key);

  final List<Hotel> data;

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
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
            itemCount: data.length,
            itemBuilder: (_, index) => HotelItem(
              hotel: data[index],
              key: UniqueKey(),
            ),
          ),
        ),
      ],
    );
  }
}

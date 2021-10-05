import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_booking_app/data/repository/hotel_repository.dart';
import 'package:hotel_booking_app/dependencies.dart';
import 'package:hotel_booking_app/features/base/result_state.dart';
import 'package:hotel_booking_app/features/detail/cubit/hotel_detail_cubit.dart';
import 'package:hotel_booking_app/features/detail/ui/info/hotel_info_tab.dart';
import 'package:hotel_booking_app/features/detail/ui/review/hotel_review_tab.dart';
import 'package:hotel_booking_app/features/detail/ui/room/hotel_room_tab.dart';
import 'package:hotel_booking_app/model/hotel_model.dart';
import 'package:hotel_booking_app/widgets/error_widget.dart';

class HotelDetailPage extends StatefulWidget {
  const HotelDetailPage({Key? key, required this.name}) : super(key: key);

  final String name;

  static Widget init(String name) {
    return BlocProvider(
      create: (_) => HotelDetailCubit(getIt.get<HotelRepository>()),
      child: Scaffold(body: HotelDetailPage(name: name)),
    );
  }

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  @override
  void initState() {
    context.read<HotelDetailCubit>().loadHotelDetail(widget.name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HotelDetailCubit, ResultState<Hotel>>(
      builder: (context, state) {
        return state.when(
          initial: () => Container(),
          loading: () => const Center(child: CircularProgressIndicator()),
          data: (data) => Container(
            color: Theme.of(context).canvasColor,
            child: Stack(
              children: <Widget>[
                HotelFeedBodyBackground(hotel: data),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Scaffold(
                    appBar: AppBar(
                      iconTheme: const IconThemeData(
                        color: Colors.white,
                        size: 32,
                      ),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    backgroundColor: Colors.transparent,
                    body: HotelFeedBody(hotel: data),
                  ),
                ),
              ],
            ),
          ),
          error: (e) => const CustomErrorWidget(),
        );
      },
      listener: (context, state) {},
    );
  }
}

class HotelFeedBodyBackground extends StatelessWidget {
  const HotelFeedBodyBackground({
    Key? key,
    required this.hotel,
  }) : super(key: key);

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: MediaQuery.of(context).size.height * .60,
      child: Hero(
        tag: Key('key${hotel.imageUrl}'),
        child: Container(
          height: MediaQuery.of(context).size.height * .25,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(hotel.imageUrl), fit: BoxFit.cover),
          ),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * .25,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0, .8),
                end: Alignment.center,
                colors: [
                  Color(0xEE000000),
                  Color(0x33000000),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HotelFeedBody extends StatelessWidget {
  const HotelFeedBody({Key? key, required this.hotel}) : super(key: key);
  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 60, top: 220),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 8),
          Expanded(
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              elevation: 8,
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: TabBarView(
                          children: [
                            HotelInformationTab(hotel: hotel),
                            HotelRoomTab(rooms: hotel.rooms),
                            HotelReviewTab(reviews: hotel.reviews),
                          ],
                        ),
                      ),
                    ),
                    const TabBar(
                      indicator: UnderlineTabIndicator(
                        borderSide:
                            BorderSide(color: Color(0xDD613896), width: 4),
                        insets: EdgeInsets.fromLTRB(20, 0, 20, 40),
                      ),
                      tabs: [
                        Tab(
                          child: Text(
                            'INFO',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'ROOMS',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'REVIEW',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

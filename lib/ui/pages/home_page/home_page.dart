import 'package:buscatelo/commons/app_constants.dart';
import 'package:buscatelo/data/hotels_fake_data.dart';
import 'package:buscatelo/model/hotel_model.dart';
import 'package:buscatelo/network/hotel_api.dart';
import 'package:buscatelo/ui/pages/hotel_detail/hotel_detail_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[_buildBackground(), _buildTopBar(), _buildBody()],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: ExactAssetImage("assets/img/buscatelo_bg_home.png"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.7), BlendMode.hardLight),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Builder(builder: (BuildContext context) {
      return Positioned(
        top: 30,
        height: 70,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    "Rodrigo",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Guadalupe",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              CircleAvatar(
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(AppConstants.avatarImage),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBody() {
    var api = HotelApi();
    return Builder(
      builder: (BuildContext context) {
        return Positioned(
          top: 90,
          child: Container(
            height: MediaQuery.of(context).size.height - 100,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Descubre",
                        style: TextStyle(
                            fontSize: 35, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "nuestros hoteles",
                        style: TextStyle(fontSize: 35),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: FutureBuilder(
                    future: api.getHotels(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<HotelModel>> snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            final HotelModel item = snapshot.data[index];
                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (c) => HotelDetailPage(
                                          hotelModel: item,
                                        )));
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(right: 15, left: 15),
                                child: Stack(
                                  children: <Widget>[
                                    LayoutBuilder(
                                      builder: (BuildContext context,
                                          BoxConstraints constraints) {
                                        return Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.65,
                                          height: constraints.maxHeight - 20,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                  'https://t-ec.bstatic.com/images/hotel/max500/798/79872273.jpg'), // TODO : CHANGE IMG API
                                              colorFilter: ColorFilter.mode(
                                                Colors.black.withOpacity(0.2),
                                                BlendMode.hardLight,
                                              ),
                                            ),
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(35),
                                                bottomLeft: Radius.circular(35),
                                                bottomRight:
                                                    Radius.circular(35),
                                                topRight: Radius.circular(35)),
                                          ),
                                        );
                                      },
                                    ),
                                    Positioned(
                                      top: 15,
                                      left: 15,
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 55.0,
                                        width: 55.0,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              width: 2.0,
                                              color: Colors.white,
                                            ),
                                            color: AppConstants.primaryColor),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              '10%',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              ' DSCT',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        height: 45.0,
                                        width: 45.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppConstants.accentColor,
                                        ),
                                        child: Icon(
                                          Icons.navigate_next,
                                          size: 40.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 35.0,
                                      left: 10.0,
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
                                      child: ListTile(
                                        title: Text(
                                          item.name,
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.white),
                                        ),
                                        subtitle: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              Icons.room,
                                              color: Colors.white,
                                              size: 18.0,
                                            ),
                                            Flexible(
                                              child: Text(
                                                item.address,
                                                textAlign: TextAlign.justify,
                                                overflow: TextOverflow.fade,
                                                maxLines: 2,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return Container();
                    },
                  ),
                ),
                // BottomBar(),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:buscatelo/commons/app_constants.dart';
import 'package:buscatelo/data/hotels_fake_data.dart';
import 'package:buscatelo/model/hotel_model.dart';
import 'package:buscatelo/ui/widget/bottom_bar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          _buildBackground(),
          _buildTopBar(),
          _buildBody()
        ],
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
    return Builder(
        builder: (BuildContext context) {
          return Positioned(
            top: 30,
            height: 70,
            width: MediaQuery
                .of(context)
                .size
                .width,
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
                      SizedBox(width: 5,),
                      Text(
                        "Guadalupe",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  ),
                  CircleAvatar(
                    foregroundColor: Theme
                        .of(context)
                        .primaryColor,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(
                        AppConstants.avatarImage
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _buildBody() {
    return Builder(
      builder: (BuildContext context) {
        return Positioned(
          top: 90,
          child: Container(
            height: MediaQuery
                .of(context)
                .size
                .height - 100,
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Discover",
                  style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold
                  ),
                ),
                Text(
                  "Suitable Hotels",
                  style: TextStyle(
                      fontSize: 35
                  ),
                ),
                SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppConstants.backgroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppConstants.primaryColor,
                            ),
                            hintText: "Find a good hotel",
                            hintStyle: TextStyle(
                                color: AppConstants.primaryColor,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 50,
                      alignment: Alignment.center,
                      child: Stack(
                        children: <Widget>[
                          Icon(
                            Icons.notifications_none,
                            size: 35,
                            color: AppConstants.primaryColor,
                          ),
                          Positioned(
                            top: -1,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppConstants.accentColor,
                              ),
                              child: Text(
                                '2',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20,),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: hotels.length,
                    itemBuilder: (BuildContext context, int index) {
                      final HotelModel item = hotels[index];

                      return InkWell(
                        onTap: () {
                          // TODO : implement go to detail page of hotel passing the item object
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15, left: 15),
                          child: Stack(
                            children: <Widget>[
                              LayoutBuilder(
                                builder: (BuildContext context,
                                    BoxConstraints constraints) {
                                  return Container(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.65,
                                    height: constraints.maxHeight - 20,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(item.img),
                                          colorFilter: ColorFilter.mode(
                                            Colors.black.withOpacity(0.2),
                                            BlendMode.hardLight,
                                          ),
                                        ),
                                        borderRadius: BorderRadius.only(

                                        )
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                BottomBar(),
              ],
            ),
          ),
        );
      },
    );
  }
}

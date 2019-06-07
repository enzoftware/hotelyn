import 'package:buscatelo/commons/app_constants.dart';
import 'package:buscatelo/model/hotel_model.dart';
import 'package:buscatelo/ui/pages/room_detail/room_detail_page.dart';
import 'package:buscatelo/ui/widget/star_display.dart';
import 'package:flutter/material.dart';

class HotelDetailPage extends StatefulWidget {
  final HotelModel hotelModel;

  HotelDetailPage({Key key, this.hotelModel}) : super(key: key);

  @override
  _HotelDetailPageState createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  bool isFav = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.40,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(widget.hotelModel.img),
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.2),
                    BlendMode.hardLight,
                  ),
                ),
              ),
            ),
            Positioned(
              width: MediaQuery.of(context).size.width,
              top: MediaQuery.of(context).size.height * 0.4 - 90,
              child: Padding(
                padding: const EdgeInsets.only(left: 30, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _buildIndicator(),
                        SizedBox(
                          width: 5.0,
                        ),
                        _buildIndicator(),
                        SizedBox(
                          width: 5.0,
                        ),
                        _buildIndicator(),
                        SizedBox(
                          width: 5.0,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .6 + 50,
              top: MediaQuery.of(context).size.height * .4 - 50,
              child: Container(
                padding: const EdgeInsets.only(left: 30, right: 20, top: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(80),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "${widget.hotelModel.name}",
                          style: TextStyle(
                            color: Color(0xff632bbf),
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          child: Icon(
                            isFav 
                            ? Icons.favorite
                            : Icons.favorite_border,
                            size: 30,
                          ),
                          onTap: (){
                            setState(() {
                              isFav = !isFav;
                            });
                          },
                        )
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _buildRow(Icons.wifi),
                              _buildRow(Icons.fastfood),
                              _buildRow(Icons.tv),
                            ],
                          ),
                        ),
                        IconTheme(
                          data: IconThemeData(
                            color: Colors.amber,
                            size: 18,
                          ),
                          child: StarDisplay(value: 4),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Divider(
                      color: Colors.grey,
                      height: 2,
                    ),
                    SizedBox(height: 15),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Tipos de habitaciones",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            title: Text(
                              "Habitacion normal",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              "Desde S/50 por hora",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            trailing: Container(
                              alignment: Alignment.center,
                              width: 80,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF632bbf),
                                    ),
                                    child: Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (c) => RoomDetailPage(
                                        imageUrl:
                                            'http://www.lapintahotel.mx/wp-content/uploads/2015/10/pinta46.jpg',
                                      )));
                            },
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            title: Text(
                              "Habitacion premium",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              "Desde S/80 por hora",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            trailing: Container(
                              alignment: Alignment.center,
                              width: 80,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF632bbf),
                                    ),
                                    child: Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (c) => RoomDetailPage(
                                        imageUrl:
                                            'https://sofiabarcelona.com/wp-content/uploads/sites/4/2018/02/SOFIA_Hotel_HARMONI-HABITACION-06-1024x682.jpg',
                                      )));
                            },
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: <Widget>[
                        _buildCustomButton('Hacer una pregunta'),
                        SizedBox(width: 8),
                        _buildCustomButton('Productos'),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedBtn(String msg) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        height: 50,
        decoration: BoxDecoration(
          color: AppConstants.backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Text(
          msg,
          style: TextStyle(
            color: AppConstants.primaryColor,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomButton(String msg) {
    return RaisedButton(
      onPressed: () {},
      shape:
          RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
      child: Text(
        msg,
        style: TextStyle(
          color: AppConstants.primaryColor,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildRow(IconData iconData) {
    return Row(
      children: <Widget>[
        Icon(
          iconData,
          size: 16,
          color: Colors.grey,
        ),
        SizedBox(width: 1),
      ],
    );
  }

  Widget _buildIndicator() {
    return Container(width: 20, height: 5, color: Colors.white);
  }
}

import 'package:buscatelo/commons/app_constants.dart';
import 'package:buscatelo/model/hotel_model.dart';
import 'package:buscatelo/ui/pages/room_detail/room_detail_page.dart';
import 'package:buscatelo/ui/widget/star_display.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

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
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${widget.hotelModel.name}",
                        style: TextStyle(
                          color: Color(0xff632bbf),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        IconTheme(
                          data: IconThemeData(
                            color: Colors.amber,
                            size: 18,
                          ),
                          child: StarDisplay(value: 4),
                        ),
                        InkWell(
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 30,
                          ),
                          onTap: () {
                            setState(() {
                              isFav = !isFav;
                            });
                          },
                        )
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Desde S/50 por hora",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      _buildRow(Icons.wifi),
                                      _buildRow(Icons.radio),
                                    ],
                                  ),
                                ),
                              ],
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
                                        listImageUrl:[
                                          'https://losmejoresdelima.com/wp-content/uploads/2019/01/hotel-el-gaucho-sjl.jpg',
                                          'http://www.lapintahotel.mx/wp-content/uploads/2015/10/pinta46.jpg',
                                          'http://compras.cuponidad.pe/images/Deals/12459b.jpg'
                                        ],
                                        roomName: 'Habitacion normal',
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Desde S/80 por hora",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      _buildRow(Icons.wifi),
                                      _buildRow(Icons.radio),
                                      _buildRow(Icons.tv),
                                      _buildRow(Icons.movie),
                                    ],
                                  ),
                                ),
                              ],
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
                                        listImageUrl:[
                                          'https://sofiabarcelona.com/wp-content/uploads/sites/4/2018/02/SOFIA_Hotel_HARMONI-HABITACION-06-1024x682.jpg',
                                          'http://adsensr.com/g/b/ro/romantic-decorations-for-bedroom-things-to-do-in-hotel-room-with-your-boyfriend-ideas-candles-and-rose-petals-as-the-best-place-celebrate-photo-gallery-of-valentines-day-him-how-decorate.jpg',
                                          'https://static.laterooms.com/hotelphotos/laterooms/286423/gallery/falls-of-lora-hotel-oban_260520141227477461.jpg'
                                        ],
                                        roomName: 'Habitacion premium',
                                            
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
                        _buildExpandedBtn('Productos'),
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
      child: RaisedButton(
        child: Text(
          msg,
          style: TextStyle(
            color: AppConstants.primaryColor,
            fontSize: 18,
          ),
        ),
        onPressed: () {},
        shape:
          RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
      ),
    );
  }

  Widget _buildCustomButton(String msg) {
    return RaisedButton(
      onPressed: () {
        Alert(
            context: context,
            title: "Pregunta",
            image: Image.network(
              'https://img.pngio.com/question-png-solar-in-the-community-vector-freeuse-download-question-png-512_512.png',
              height: 50,
              width: 50,
            ),
            content: TextField(
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                icon: Icon(Icons.input),
                labelText: 'Pregunta',
              ),
            ),
            buttons: [
              DialogButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Enviar",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              )
            ]).show();
      },
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
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            iconData,
            size: 16,
            color: Colors.grey,
          ),
        ),
        SizedBox(width: 1),
      ],
    );
  }

  Widget _buildIndicator() {
    return Container(width: 20, height: 5, color: Colors.white);
  }
}

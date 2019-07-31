import 'package:buscatelo/commons/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fluid_slider/flutter_fluid_slider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:buscatelo/ui/pages/booking_page/booking_page.dart';

class RoomDetailPage extends StatefulWidget {
  final List<String> listImageUrl;
  final String roomName;
  final int startPrice;

  RoomDetailPage({Key key, this.listImageUrl, this.roomName, this.startPrice})
      : super(key: key);

  _RoomDetailPageState createState() => _RoomDetailPageState(startPrice);
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  int _sliderValue = 1;
  int _price;
  _RoomDetailPageState(int price) {
    this._price = price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            CarouselSlider(
              height: MediaQuery.of(context).size.height * 0.40,
              items: widget.listImageUrl.map((image) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(color: Colors.amber),
                        child: Image.network(
                          '$image',
                          fit: BoxFit.cover,
                        ));
                  },
                );
              }).toList(),
            ),
            Positioned(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .6 + 40,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.roomName,
                      style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w900,
                          color: primaryColor),
                    ),
                    Text(
                      'S/.$_price',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Horas',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                        ),
                        FluidSlider(
                          value: _sliderValue.toDouble(),
                          onChanged: (double newValue) {
                            setState(() {
                              _sliderValue = newValue.round();
                              _price = _sliderValue * widget.startPrice;
                            });
                          },
                          min: 1.0,
                          max: 12.0,
                          sliderColor: accentColor,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Servicios',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: CustomScrollView(
                        primary: false,
                        slivers: <Widget>[
                          SliverPadding(
                            padding: const EdgeInsets.all(20.0),
                            sliver: SliverGrid.count(
                              crossAxisSpacing: 5.0,
                              crossAxisCount: 3,
                              children:
                                  List.generate(widget.startPrice < 15 ? _services.length ~/ 2 : _services.length, (index) {
                                return Card(
                                  child: Image.network(_services[index]),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        alignment: Alignment.center,
                        child: MaterialButton(
                          shape: StadiumBorder(),
                          child: Text(
                            'Reservar',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          color: accentColor,
                          minWidth: MediaQuery.of(context).size.width * 0.7,
                          textColor: primaryColor,
                          onPressed: () {
                            _showDialog();
                          },
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

  var _services = [
    'http://icons.iconarchive.com/icons/papirus-team/papirus-apps/256/netflix-icon.png',
    'https://cdn3.iconfinder.com/data/icons/home-appliances-24/512/015-512.png',
    'https://cdn1.iconfinder.com/data/icons/airport-set-1/512/29-512.png',
    'https://banner2.kisspng.com/20180504/vye/kisspng-shower-bathtub-computer-icons-clip-art-take-a-shower-5aebdd3c512092.2282529015254070363323.jpg',
    'https://cdn0.iconfinder.com/data/icons/food-2-11/128/food-13-512.png'
  ];

//  final _showDialog = showDialog(
  void _showDialog (){ showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: new Text("¿Deseas confirmar la reserva?"),
          content: new Text("Si confirmas tendrás un plazo de máximo 30 minutos para acercarte al hostal que reservaste"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Aceptar"),
              onPressed: (){
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookingPage())
                );
              },
            ),
            new FlatButton(
              child: new Text("Cerrar"),
              onPressed: (){
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }
}

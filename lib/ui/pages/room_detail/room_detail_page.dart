import 'package:buscatelo/commons/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fluid_slider/flutter_fluid_slider.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
  _RoomDetailPageState(int price){
    this._price = price;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
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
                          fontSize: 16.0,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                        ),
                      ),
                      Container(
                        child: FluidSlider(
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
                        margin: EdgeInsets.only(top: 64.0),
                      ),
                      Spacer(),
                      Container(
                        alignment: Alignment.center,
                        child: MaterialButton(
                          shape: StadiumBorder(),
                          child: Text('Reservar'),
                          color: accentColor,
                          textColor: primaryColor,
                          onPressed: () {

                          },
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

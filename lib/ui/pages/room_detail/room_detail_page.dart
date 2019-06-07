import 'package:buscatelo/commons/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fluid_slider/flutter_fluid_slider.dart';

class RoomDetailPage extends StatefulWidget {
  String imageUrl;

  RoomDetailPage({Key key, this.imageUrl}) : super(key: key);

  _RoomDetailPageState createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  int _price = 50;
  double _sliderValue = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('Habitaciones'),
                background: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverFillRemaining(
                child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(top: 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "S/.$_price",
                      style: TextStyle(
                          fontSize: 32.0,
                          color: primaryColor,
                          fontWeight: FontWeight.w900),
                    ),
                    Container(
                      margin: EdgeInsets.all(72.0),
                      child: FluidSlider(
                        thumbColor: Colors.white,
                        sliderColor: accentColor,
                        value: _sliderValue,
                        onChanged: (double newValue) {
                          setState(() {
                            _sliderValue = newValue;
                            _price = _sliderValue.round() * 50;
                          });
                        },
                        min: 1.0,
                        max: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}

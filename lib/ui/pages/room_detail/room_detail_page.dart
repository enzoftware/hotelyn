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
                                  List.generate(_services.length, (index) {
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
                          onPressed: () {},
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
    'https://cdn3.iconfinder.com/data/icons/dark-side-of-web/64/xxx_adult_content_porn_sex_doll_sexual_online_pornography-512.png',
    'https://banner2.kisspng.com/20180504/vye/kisspng-shower-bathtub-computer-icons-clip-art-take-a-shower-5aebdd3c512092.2282529015254070363323.jpg',
    'https://i.pinimg.com/originals/b6/a5/5f/b6a55fbc10e424116aa4a8dfa1858ae0.jpg',
    'https://cdn0.iconfinder.com/data/icons/food-2-11/128/food-13-512.png'
  ];
}

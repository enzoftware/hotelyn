import 'package:buscatelo/ui/widget/active_tab.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  @override
  BottomBarState createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar>
    with SingleTickerProviderStateMixin {
  Animation animation;
  AnimationController animationController;
  int currentTab = 0;

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.elasticOut));

    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(right: 16, bottom: 5, top: 10, left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildTab("Hoteles", Icons.hotel, 0),
          _buildTab("Favoritos", Icons.favorite, 1),
          _buildTab("Mapa", Icons.map, 2),
        ],
      ),
    );
  }

  Widget _buildTab(String text, IconData icon, int index) {
    return currentTab == index
        ? ActiveTab(
      animation: animation,
      key: Key(text),
      text: text,
      iconData: icon,
    )
        : Material(
      child: InkWell(
        onTap: () {
          setState(() {
            currentTab = index;
            animationController.reset();
            animationController.forward();
          });
        },
        child: Icon(
          icon,
          size: 35,
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

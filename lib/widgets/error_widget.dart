import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.network(
          'https://i.pinimg.com/originals/3f/87/c5/3f87c5b2a2e06bfaf5d37d974f607a02.jpg',
          width: 200,
          height: 200,
        ),
        Text(
          'Something its wrong. Please open an issue :(',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ));
  }
}

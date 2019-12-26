import 'package:buscatelo/ui/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';

class HotelSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.red,
              ),
            ),
            BottomBar(),
          ],
        ),
      ),
    );
  }
}

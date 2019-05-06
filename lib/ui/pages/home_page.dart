import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          _buildBackground(),
          //_buildTopBar(),
          //_buildBody()
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
    return null;
  }

  Widget _buildBody() {
    return null;
  }
}

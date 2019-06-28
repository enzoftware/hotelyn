import 'package:flutter/material.dart';

class OneProductPage extends StatefulWidget{
  @override
  _ProductPageState createState()=>_ProductPageState();
}

class _ProductPageState extends State<OneProductPage>{
  @override
  Widget build(BuildContext context) {
    Widget _titleSection = new Container(
      padding: const EdgeInsets.all(10.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: new Text("Name of Product",
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0 
                    ),
                  ),
                ),
                new Text("This is a Description",
                  style: new TextStyle(
                    color: Colors.grey[850],
                    fontSize: 16.0
                  )
                )
              ],
            )
          ),
        ],
        )
    );

    return new Scaffold(
      body: new ListView(
        children: <Widget>[
          new Image.asset(
            'assets/img/botella.jpg',
            fit: BoxFit.cover
          ),
          _titleSection
        ],
      ),
    );

  }
}
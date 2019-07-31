import 'package:buscatelo/model/product_model.dart';
import 'package:flutter/material.dart';

class OneProductPage extends StatefulWidget {
  final ProductModel product;
  OneProductPage(this.product);
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<OneProductPage> {
  @override
  Widget build(BuildContext context) {
    Widget _titleSection = Container(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(
                    bottom: 10.0,
                  ),
                  child: Text(
                    widget.product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                Text(
                  widget.product.description,
                  style: TextStyle(
                    color: Colors.grey[850],
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  "S/. ${widget.product.price}",
                  style: TextStyle(
                    color: Colors.grey[850],
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            )),
          ],
        ));

    return Scaffold(
      body: ListView(
        children: <Widget>[
          Image.network(widget.product.imgUrl, fit: BoxFit.cover),
          _titleSection
        ],
      ),
    );
  }
}

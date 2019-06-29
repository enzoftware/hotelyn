import 'package:buscatelo/network/product_api.dart';
import 'package:flutter/material.dart';
import 'package:buscatelo/ui/pages/products_detail/one_product_detail_page.dart';
import 'package:buscatelo/model/product_model.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    final api = ProductApi();
    return Scaffold(
      body: Container(
        child: FutureBuilder(
          future: api.getProducts(),
          builder: (BuildContext context,
              AsyncSnapshot<List<ProductModel>> snapshot) {
            if (snapshot.hasData) {
              return GridView.extent(
                maxCrossAxisExtent: 150.0,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 5.0,
                children: _buildGridTiles(snapshot.data.length, snapshot.data),
              );
            }
            return Center(
              child: Text('Cargando...'),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildGridTiles(int numberOfTiles, List<ProductModel> products ) {
    List<Stack> containers = List<Stack>.generate(numberOfTiles, (int index) {
      // final imageUrl = 'assets/img/botella.jpg';
      return Stack(
        alignment: const Alignment(1.0, 1.0),
        children: <Widget>[
          GestureDetector(
              child: Container(
                child: Image.network(products[index].imgUrl,
                    width: 150.0, height: 150.0, fit: BoxFit.fill),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OneProductPage(products[index])),
                );
              }),
          Container(
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(color: Color.fromARGB(150, 71, 150, 236)),
            //child: new Text('${index+1}',style: new TextStyle(
            child: Text(
              products[index].name,
              style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          )
        ],
      );
    });
    return containers;
  }
}

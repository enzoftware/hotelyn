import 'package:buscatelo/ui/pages/products_detail/one_product_detail_page.dart';
import 'package:buscatelo/model/product_model.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget{
  final List<ProductModel> products;
  ProductPage({Key key, this.products}) : super(key: key);
  @override
  _ProductPageState createState()=>_ProductPageState();

}

class _ProductPageState extends State<ProductPage>{
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      body: new GridView.extent(
        maxCrossAxisExtent: 150.0,
        mainAxisSpacing: 5.0,
        crossAxisSpacing: 5.0,
        children: _buildGridTiles(2)
      )
    );
  }

  List<Widget> _buildGridTiles(numberOfTiles){
    List<Stack> containers= new List<Stack>.generate(numberOfTiles, 
    (int index){
      //final imageName='assets/img/botella.jpg';
      final imageUrl=widget.products[0].imgUrl;
      final imageName=widget.products[0].name;
      return new Stack(
        alignment: const Alignment(1.0, 1.0),
        children: <Widget>[
          new GestureDetector (
            child: Container(
              child: new Image.asset(
                imageUrl,
                width: 150.0,
                height: 150.0,
                fit: BoxFit.fill
                ),
            ),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OneProductPage()),
              );
            }
          ) ,
          new Container(
            padding: const EdgeInsets.all(5.0),
            decoration: new BoxDecoration(
              color: new Color.fromARGB(150, 71, 150, 236)
            ),
            //child: new Text('${index+1}',style: new TextStyle(
            child: new Text(imageName,style: new TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: Colors.white
              ),
            ),
          )
        ],
      );
    }
    );
    return containers;
  }





}
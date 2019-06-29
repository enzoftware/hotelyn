import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:buscatelo/model/product_model.dart';
import 'package:barbarian/barbarian.dart';

class ProductApi {
  final String _baseUrl = 'buscatelo-api-rest.herokuapp.com';
  final String _getProductsUrl = '/product';

  ProductApi(){
    Barbarian.init();
  }

  Future<List<ProductModel>> getProducts() async {
    final uri = Uri.https(_baseUrl, _getProductsUrl);
    final response = await _getJson(uri);
    if (response == null) {
      print('Api.getProducts() : Error jwt');
      return null;
    }
    return _convert(response);
  }

  Future<List<dynamic>> _getJson(Uri uri) async {
    try {
      final headers = {
        'auth':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJpYXQiOjE1NjE3ODAxODcsImV4cCI6MTU2MTc4Mzc4N30.Lc_xZbPZZDujWCevOB9SwopcKKTm0pJhjYcTK4wMyKE'
      };
      var response = await get(uri, headers: headers);

      if (response.statusCode == HttpStatus.ok) {
        return json.decode(response.body);
      } else {
        print('Api get products status is ${response.statusCode}');
        return null;
      }
    } on Exception catch (e) {
      print('Api._getProducts($uri) exception thrown $e');
      return null;
    }
  }

  List<ProductModel> _convert(List productJson) {
    List<ProductModel> items = <ProductModel>[];
    productJson.forEach((item) {
      items.add(ProductModel.fromJson(item));
    });
    return items;
  }
}

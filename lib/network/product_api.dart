import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:buscatelo/model/product_model.dart';
import 'package:barbarian/barbarian.dart';

class ProductApi {
  final String _baseUrl = 'buscatelo-api-rest.herokuapp.com';
  final String _getProductsUrl = '/product';

  ProductApi() {
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
      String jwt = Barbarian.read('userJwt') ?? 'webadaDeJwt';
      final headers = {'auth': jwt};
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

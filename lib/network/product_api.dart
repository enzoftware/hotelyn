import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';//compute
import 'package:http/http.dart' as http;
import 'package:buscatelo/model/product_model.dart';


class ProductApi {
  final String _baseUrl = 'buscatelo-api-rest.herokuapp.com';
  final headers = {'Content-Type': 'application/json'};
  final String _getProducts = '/product/';

  final HttpClient _httpClient = HttpClient();


  Future<List<ProductModel>> getProducts(http.Client client) async {
  final response = await client.get('https://jsonplaceholder.typicode.com/photos');
    if (response == null) {
      print('Api._getProducts(): Error while retriving products');
      return null;
    }
    // Use the compute function to run parsePhotos in a separate isolate.
    return compute(parsePhotos, response.body);

  }
  
  List<ProductModel> parsePhotos(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<ProductModel>((json) => ProductModel.fromJson(json)).toList();
  }
/*
  final _loadProducts = FutureBuilder<List<ProductModel>>(
        future: widget.productApi.getProducts(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? PhotosList(photos: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      );*/
/*
  Future<Map<String, dynamic>> _getJson(Uri uri, dynamic body) async {
    try {
      print(body);
      var response = await post(uri,
          body: json.encode(body),
          encoding: Encoding.getByName("utf-8"),
          headers: headers);

      if (response.statusCode == HttpStatus.created ||
          response.statusCode == HttpStatus.ok) {
        return json.decode(response.body);
      } else {
        print('Api._getJson($uri) status code is ${response.statusCode}');
        return null;
      }
    } on Exception catch (e) {
      print('Api._getJson($uri) exception thrown $e');
      return null;
    }
  }*/


}

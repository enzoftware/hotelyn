import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:buscatelo/model/product_model.dart';


class BuscateloApi {
  final String _baseUrl = 'buscatelo-api-rest.herokuapp.com';
  final headers = {'Content-Type': 'application/json'};
  final String _authLogin = '/auth/login';
  final String _registerNewUser = '/user';
  final String _getProducts = '/product/';

  final HttpClient _httpClient = HttpClient();

  Future<String> login(String username, String password) async {
    // ! todo : change to login request model
    var body = {"username": username, "password": password};
    final uri = Uri.https(_baseUrl, _authLogin);
    final response = await _getJson(uri, body);
    if (response == null || response['token'] == null) {
      print('Api.login(): Error while retriving jwt');
      return null;
    }
    return response['token'];
  }

  Future<String> register(
      String username, String email, String password) async {
    // ! todo : change to register request model
    var body = {
      "username": username,
      "password": password,
      "email": email,
      "role": "USER"
    };
    final uri = Uri.https(_baseUrl, _registerNewUser);
    final response = await _getJson(uri, body);
    if (response.toString() == null) {
      print('Api.register(): Error while register');
      return null;
    }
    print(response.toString());
    return response.toString();
  }


  Future<List<ProductModel>> getProducts() async {
    final uri = Uri.https(_baseUrl, _getProducts);
    final response = await _get(uri);

    if (response == null) {
      print('Api._getProducts(): Error while retriving products');
      return null;
    }
    
    return _convert(response[_getProducts]);

  }

  List<ProductModel> _convert(List productsJson) {
    List<ProductModel> products = <ProductModel>[];
    productsJson.forEach((character){
      products.add(ProductModel.fromJson(character));
    });
    return products;
  }

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
  }
  
  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final request = await _httpClient.getUrl(uri);
      final response = await request.close();

      if (response.statusCode != HttpStatus.OK) {
        print('Api._getJson($uri) status code is ${response.statusCode}');
        return null;
      }
      final responseBody = await response.transform(utf8.decoder).join();
      return json.decode(responseBody);
    } on Exception catch (e) {
      print('Api._getJson($uri) exception thrown $e');
      return null;
    }
  }


}

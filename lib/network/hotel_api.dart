import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';

class HotelApi {
  final String _baseUrl = 'buscatelo-api-rest.herokuapp.com';
  final headers = {'Content-Type': 'application/json'};
  final String _authLogin = '/hotel';

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
}

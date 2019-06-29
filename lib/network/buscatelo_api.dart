import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';

class BuscateloApi {
  final String _baseUrl = 'buscatelo-api-rest.herokuapp.com';
  final headers = {'Content-Type': 'application/json'};
  final String _authLogin = '/auth/login';
  final String _registerNewUser = '/user';


  Future<String> login(String username, String password) async {
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

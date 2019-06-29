import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:buscatelo/model/user_model.dart';
import 'package:http/http.dart';

class BuscateloApi {
  final String _baseUrl = 'buscatelo-api-rest.herokuapp.com';
  final headers = {'Content-Type': 'application/json'};
  final String _authLogin = '/auth/login';
  final String _registerNewUser = '/user';
  final String _getUser = '/user/';

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
      print('Api.login(): Error while register');
      return null;
    }
    print(response.toString());
    return response.toString();
  }

  Future<int> getUser(String username, String token) async{
    final uri = Uri.https(_baseUrl, _getUser+username);
    final response = await _get(uri, token);
    if(response.toString() == null){
      print('Api(): Error getting user info');
      return null;
    }
    UserModel user = UserModel.fromJson(response);
    return user.id;
  }

  Future<UserModel> getUserbyId(int id, String token) async{
    final uri = Uri.https(_baseUrl, _getUser+id.toString());
    final response = await _get(uri, token);
    if(response.toString() == null){
      print('Api(): Error getting user info');
      return null;
    }
    print(response);
    UserModel user = UserModel.fromJson(response);
    return user;
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

  Future<Map<String, dynamic>> _get(Uri uri, String token) async {
    try{
      headers['auth'] = token;
      var response = await get(uri,
          headers: headers);

      if (response.statusCode == HttpStatus.created ||
          response.statusCode == HttpStatus.ok) {
        print(json.decode(response.body));
        return json.decode(response.body)[0];
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

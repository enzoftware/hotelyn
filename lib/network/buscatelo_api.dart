import 'dart:async';
import 'dart:convert';
import 'dart:io';

class BuscateloApi {
  final String _baseUrl = 'https://buscatelo-api-rest.herokuapp.com';
  final String _authLogin = '/auth/login';
  final String _registerNewUser = '/user';
  final HttpClient _httpClient = HttpClient();

  Future<Map<String, dynamic>> login(Uri uri) async {
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

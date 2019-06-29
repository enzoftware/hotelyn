import 'dart:async';

import 'package:flutter/material.dart';
import 'package:buscatelo/ui/pages/home_page/home_page.dart';
import 'package:buscatelo/network/buscatelo_api.dart';

class RegisterPage extends StatefulWidget {
  static String tag = 'register-page';
  @override
  RegisterPageState createState() => new RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final emailController = TextEditingController();
  int userId;

  @override
  Widget build(BuildContext context) {
    final username = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: usernameController,
      decoration: InputDecoration(
        hintText: 'Username',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );
    final email = TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );
    final password = TextFormField(
      controller: passwordController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final confirmPassword = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: passwordConfirmController,
      decoration: InputDecoration(
        hintText: 'Confirm Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final registerButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.all(12),
        onPressed: () {
          if (password.controller.text == confirmPassword.controller.text) {
            register(username.controller.text, password.controller.text,
                email.controller.text);
          } else {
            _showRegisterErrorDialog("Las contrasenas no son iguales");
          }
        },
        color: Colors.lightBlueAccent,
        child: Text('Registrar', style: TextStyle(color: Colors.white)),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 24.0, right: 24.0),
              children: <Widget>[
            username,
            SizedBox(height: 15.0),
            email,
            SizedBox(height: 15.0),
            password,
            SizedBox(height: 15.0),
            confirmPassword,
            SizedBox(height: 15.0),
            registerButton,
          ])),
    );
  }

  Future<void> register(String username, String password, String email) async {
    final api = BuscateloApi();
    await api.register(username, email, password).then((response) {
      if (response != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userId: this.userId, token: response,)),
        );
      } else {
        _showRegisterErrorDialog("Error al registrar usuario");
      }
    });
  }

  Future<int> getUserId(String username, String token) async{
    final api = BuscateloApi();
    int id;
    await api.getUser(username, token ).then((userId){
      id = userId;
    });
    if (id != null){
      return id;
    }
    return null;
  }

  void _showRegisterErrorDialog(String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Error"),
          content: new Text(description),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

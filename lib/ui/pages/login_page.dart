import 'dart:async';

import 'package:flutter/material.dart';
import 'package:buscatelo/ui/pages/home_page/home_page.dart';
import 'package:buscatelo/ui/pages/register_page.dart';
import 'package:buscatelo/network/buscatelo_api.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'login-page',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 90.0,
        child: Text(
          'BuscaTelo',
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.w800,
            color: Colors.black
          ),
        ),
      ),
    );
    final email = TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: usernameController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: passwordController,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.all(12),
        onPressed: () {
          login(email.controller.text, password.controller.text);
        },
        color: Colors.lightBlueAccent,
        child: Text('Iniciar sesión', style: TextStyle(color: Colors.white)),
      ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        '¿Olvidaste tu contraseña?',
        style: TextStyle(color: Colors.black54),
      ),
    );

    final registerLabel = GestureDetector(
        child: Text(
          'Si no tienes cuenta Registrate aquí',
          style: TextStyle(
              decoration: TextDecoration.underline, color: Colors.blue),
          textAlign: TextAlign.center,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterPage()),
          );
        });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 24.0, right: 24.0),
              children: <Widget>[
            logo,
            SizedBox(height: 34.0),
            email,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 15.0),
            loginButton,
            forgotLabel,
            registerLabel
          ])),
    );
  }

  Future<void> login(String username, String password) async {
    final api = BuscateloApi();
    await api.login(username, password).then((jwt) {
      if (jwt != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        _showLoginErrorDialog();
      }
    });
  }

  void _showLoginErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Error"),
          content: new Text("Error al iniciar sesion"),
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

import 'dart:async';
import 'dart:ui';
import 'package:buscatelo/ui/utils/base_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:buscatelo/ui/pages/home_page/home_page.dart';
import 'package:buscatelo/ui/pages/register_page/register_page.dart';
import 'package:buscatelo/network/buscatelo_api.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> with BaseDialogs {
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
              fontSize: 40.0, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );

    final email = TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: usernameController,
      autofocus: false,
      style: TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintStyle: TextStyle(
          color: Colors.white,
        ),
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: passwordController,
      style: TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintStyle: TextStyle(
          color: Colors.white,
        ),
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
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {},
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

    final coverPhoto = Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: ExactAssetImage('assets/img/background-ui.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: new ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
        child: new Container(
          decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
        ),
      ),
    );

    return Scaffold(
      //backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          children: <Widget>[
            coverPhoto,
            ListView(
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> login(String username, String password) async {
    final api = BuscateloApi();
    showLoadingDialog(context);
    await api.login(username, password).then((jwt) {
      hideDialog(context);
      if (jwt != null) {
        getUserId(username, jwt).then((result){
          Navigator.pushReplacement(
           context,
            MaterialPageRoute(builder: (context) => HomePage(userId: result, token: jwt,)),
          );
        });
      } else {
        _showLoginErrorDialog();
      }
    });
  }

  Future<int> getUserId(String username, String token) async{
    final api = BuscateloApi();
    int id;
    await api.getUser(username, token).then((userId){
      id = userId;
    });
    if (id != null){
      return id;
    }
    return null;
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

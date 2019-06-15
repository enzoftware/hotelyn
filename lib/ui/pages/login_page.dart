import 'package:flutter/material.dart';
import 'package:buscatelo/ui/pages/home_page/home_page.dart';
import 'package:buscatelo/ui/pages/register_page.dart';

class LoginPage extends StatefulWidget{
  static String tag = 'login-page';
  @override
  LoginPageState createState() => new LoginPageState();

}

class LoginPageState extends State<LoginPage>{

  @override
  Widget build(BuildContext context) {
    final logo=Hero(
      tag: 'login-page',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 90.0,
        child: Image.asset('assets/img/logo.png'),
      ),
    );
    final email=TextFormField(
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Email',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );
      final password=TextFormField(
        autofocus: false,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Password',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );
      final loginButton=Padding(
        padding: EdgeInsets.symmetric(vertical:16.0),
        child:RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: EdgeInsets.all(12),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          color: Colors.lightBlueAccent,
          child: Text('Iniciar sesión', style:TextStyle(color: Colors.white)),
        ),
      );

      final forgotLabel=FlatButton(
        child: Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(color:Colors.black54),
        ),
      );

      final registerLabel=
        GestureDetector(
          child: Text(
            'Si no tienes cuenta Registrate aquí', 
            style: TextStyle(
              decoration: TextDecoration.underline, 
              color: Colors.blue
              ),
            textAlign: TextAlign.center,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterPage()),
            );
          }
        
      );


      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child:ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24.0,right: 24.0),
            children:<Widget>[
              logo,
              SizedBox(height: 34.0),
              email,
              SizedBox(height: 8.0),
              password,
              SizedBox(height: 15.0),
              loginButton,
              forgotLabel,
              registerLabel
            ]
          )
        ),
        );

  }

}
import 'package:flutter/material.dart';
import 'package:buscatelo/ui/pages/home_page.dart';


class RegisterPage extends StatefulWidget{
  static String tag = 'register-page';
  @override
  RegisterPageState createState() => new RegisterPageState();

}

class RegisterPageState extends State<RegisterPage>{

  @override
  Widget build(BuildContext context) {
    final username=TextFormField(
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Username',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
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

  final confirmPassword=TextFormField(
    autofocus: false,
    obscureText: true,
    decoration: InputDecoration(
      hintText: 'Confirm Password',
      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
    ),
  );

  final registerButton=Padding(
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
      child: Text('Registrar', style:TextStyle(color: Colors.white)),
    ),
  );

  return Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child:ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 24.0,right: 24.0),
        children:<Widget>[
          username,
          SizedBox(height: 15.0),
          email,
          SizedBox(height: 15.0),
          password,
          SizedBox(height: 15.0),
          confirmPassword,
          SizedBox(height: 15.0),
          registerButton,
        ]
      )
    ),
    );

  }

}
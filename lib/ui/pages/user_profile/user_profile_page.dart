import 'package:buscatelo/commons/app_constants.dart';
import 'package:buscatelo/model/user_model.dart';
import 'package:buscatelo/network/buscatelo_api.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class UserProfilePage extends StatefulWidget {

  final int userId;
  final String token;

  UserProfilePage({Key key, @required this.userId, @required this.token}):super(key:key);

  _UserProfileState createState() => _UserProfileState(userId, token);

}

class _UserProfileState extends State<UserProfilePage>{
  int _userId;
  UserModel user;
  String _token;

  _UserProfileState(int userId, String token){
    getUser(userId, token).then((result){
       this.user = result;
    });
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      body: new Stack(
        children: <Widget>[
          ClipPath(
            child: Container(
              color:Colors.black.withOpacity(0.8)
            ),
            clipper: getClipper(),
          ),
          ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(top:MediaQuery.of(context).size.height / 8),
            children: <Widget>[
              Center(
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 200.0,
                        height: 200.0,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          image: DecorationImage(
                            image: AssetImage("assets/img/profile.jpg"),
                            fit: BoxFit.cover
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(100.0)
                          ),
                          boxShadow: [
                          BoxShadow(blurRadius: 7.0, color: Colors.black)
                          ]
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      "Rodrigo Guadalupe",
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ) ,
                    ),
                    SizedBox(height: 30.0),
                    Container(
                      margin: EdgeInsets.all(5.0),
                      width: MediaQuery.of(context).size.width*0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('First Name: '),
                            ),
                            flex:1
                            ),
                          Expanded(child: firstName,flex: 2),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(5.0),
                      width: MediaQuery.of(context).size.width*0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('Last Name: '),
                            ),
                            flex:1
                            ),
                          Expanded(child: lastName,flex: 2),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(5.0),
                      width: MediaQuery.of(context).size.width*0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('Email: '),
                            ),
                            flex:1
                            ),
                          Expanded(child: email,flex: 2),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(5.0),
                      width: MediaQuery.of(context).size.width*0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('Age: '),
                            ),
                            flex:1
                            ),
                          Expanded(child: age,flex: 2),
                        ],
                      ),
                    ),
                    SizedBox(height: 25.0),
                    Container(
                      margin: EdgeInsets.all(5.0),
                      height: 40.0,
                      width: 150.0,
                      child: _buildCustomButton("Update values")
                    )
                  ],
                )
              )
            ],
          )
        ],
      ),
    );
  }
  final firstName = TextFormField(
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'First Name',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
  );
  final lastName = TextFormField(
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Last Name',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
  );
  final email = TextFormField(
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
  );
  final age = TextFormField(
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Age',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
  );
}

class getClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    var path = new Path();

    path.lineTo(0.0, size.height/2.5);
    path.lineTo(size.width+120, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

Widget _buildCustomButton(String msg) {
    return RaisedButton(
        onPressed: () {
          
        },
        color: Color(0xfffcb813),
        elevation: 7.0,

        shape:
            RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
        child: Text(
          msg,
          style: TextStyle(
            color: AppConstants.primaryColor,
            fontSize: 16,
          ),
        ),
      );
  }

  Future<UserModel> getUser(int userId, String token) async{
    final api = BuscateloApi();
    UserModel userMod;
    var v = userId;
    var b = token;
    await api.getUserbyId(userId, token).then((user){
      userMod = user;
    });
    if (userMod != null){
      return userMod;
    }
    return null;
  }
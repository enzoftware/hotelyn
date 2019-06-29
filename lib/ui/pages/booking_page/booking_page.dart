import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart' as random;

class BookingPage extends StatefulWidget {
  static String tag = 'booking-page';
  @override
  BookingPageState createState() => new BookingPageState();
}

class BookingPageState extends State<BookingPage> {

  @override
  Widget build(BuildContext context) {
    final qrImage=Hero(
      tag: 'booking-page',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 90.0,
        child: Image.asset('assets/img/logo.png'),
      ),
    );

    final accepted = Padding(
      padding: EdgeInsets.all(8.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.all(12),
        onPressed: () {
        },
        color: Colors.lightBlueAccent,
        child: Text('Ok', style: TextStyle(color: Colors.white)),
      ),
    );
    final cancel = Padding(
      padding: EdgeInsets.all(8.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.all(12),
        onPressed: () {
        },
        color: Colors.red,
        child: Text('Cancelar reserva', style: TextStyle(color: Colors.white)),
      ),
    );


    final codeForBooking = FlatButton(
      child: Text(
        random.randomAlphaNumeric(6),
        style: TextStyle(
          color: Colors.black54,
          fontSize: 30.0
        ),
      ), onPressed: () {},
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Container(
              padding: EdgeInsets.only(left: 24.0, right: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                qrImage,
                SizedBox(height: 34.0),
                codeForBooking,
                SizedBox(height: 35.0),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    accepted,
                    cancel
                  ],
              )
            ]
          ),
        )
      ),
    );



  }


}

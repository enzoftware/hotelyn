import 'dart:async' show Future;

import 'package:flutter/material.dart';

abstract class BaseDialogs {
  Future<T> showLoadingDialog<T>(context, [String msg = 'Conectando']) =>
      showDialog<T>(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              content: Row(
                children: <Widget>[
                  CircularProgressIndicator(),
                  Container(
                    margin: const EdgeInsets.only(left: 15.0),
                    child: Text(msg),
                  )
                ],
              ),
            ),
      );

  void hideDialog(context) => Navigator.pop(context);

  Future<T> showCustomDialog<T>(context, {String title, String message}) {
    var titleWidget = title != null ? Text(title) : null;

    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
            title: titleWidget,
            content: Text(message),
          ),
    );
  }
}
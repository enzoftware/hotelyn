import 'package:buscatelo/commons/app_constants.dart';
import 'package:flutter/material.dart';

class ActiveTab extends AnimatedWidget {
  final IconData iconData;
  final String text;

  ActiveTab({Key key, Animation animation, this.iconData, this.text})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;

    return Transform(
      transform: Matrix4.diagonal3Values(animation.value, 1, 1),
      child: Container(
        width: 120.0,
        height: 60.0,
        decoration: BoxDecoration(
          color: AppConstants.tabBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppConstants.radiusBorderValue),
            bottomLeft: Radius.circular(AppConstants.radiusBorderValue),
            bottomRight: Radius.circular(AppConstants.radiusBorderValue),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              iconData,
              color: AppConstants.tabActiveItemColor,
              size: AppConstants.activeTabIconSize,
            ),
            Text(
              text,
              style: TextStyle(
                color: AppConstants.tabActiveItemColor,
                fontSize: AppConstants.activeTabTextSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

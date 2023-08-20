import 'package:flutter/material.dart';
import 'package:hotelyn_components/utils/hwidgetbook.dart';
import 'package:widgetbook/widgetbook.dart';

import 'colors.dart';

class _WidgetBookHColors extends StatelessWidget {
  const _WidgetBookHColors(this.title, this.color);

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 8),
          Container(
            color: color,
            width: 100,
            height: 100,
          )
        ],
      ),
    );
  }
}

final colorsComponent = WidgetbookComponent(
  name: 'HColors',
  useCases: [
    primaryColorsUseCase,
    otherColorsUseCase,
  ],
);

final primaryColorsUseCase = WidgetbookUseCase(
  name: 'HColorsPrimary',
  builder: (context) {
    return HWidgetbookBuilder(
      child: Row(
        children: [
          _WidgetBookHColors(
            'Blue',
            HColorsPrimary.blue,
          ),
          _WidgetBookHColors(
            'Blue 2',
            HColorsPrimary.blue2,
          ),
          _WidgetBookHColors(
            'Blue 3',
            HColorsPrimary.blue3,
          ),
        ],
      ),
    );
  },
);

final otherColorsUseCase = WidgetbookUseCase(
  name: 'HColorsOther',
  builder: (context) {
    return HWidgetbookBuilder(
      child: Row(
        children: [
          _WidgetBookHColors(
            'Green',
            HColorsOther.green,
          ),
        ],
      ),
    );
  },
);

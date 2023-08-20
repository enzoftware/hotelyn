library hotelyn_components;

import 'package:flutter/widgets.dart';
import 'package:hotelyn_components/colors/colors_widgetbook.dart';
import 'package:hotelyn_components/components/components_widgetbook.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  runApp(const HotelynWidgetBook());
}

class HotelynWidgetBook extends StatelessWidget {
  const HotelynWidgetBook({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        WidgetbookCategory(
          name: 'Colors',
          children: [
            colorsComponent,
          ],
        ),
        WidgetbookFolder(
          name: 'Components',
          children: [
            inputsComponent,
            buttonsComponent,
          ],
        ),
      ],
    );
  }
}

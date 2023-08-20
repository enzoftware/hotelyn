import 'package:widgetbook/widgetbook.dart';

import 'inputs/inputs_widgetbook.dart';

final inputsComponent = WidgetbookComponent(
  name: 'Inputs',
  useCases: [
    hInputUseCase,
  ],
);

final buttonsComponent = WidgetbookFolder(name: 'Buttons', children: []);

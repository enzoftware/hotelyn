// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:california_ui_widgetbook/use_cases/california_button_use_cases.dart'
    as _california_ui_widgetbook_use_cases_california_button_use_cases;
import 'package:california_ui_widgetbook/use_cases/california_checkbox_use_cases.dart'
    as _california_ui_widgetbook_use_cases_california_checkbox_use_cases;
import 'package:california_ui_widgetbook/use_cases/california_input_field_use_cases.dart'
    as _california_ui_widgetbook_use_cases_california_input_field_use_cases;
import 'package:california_ui_widgetbook/use_cases/california_navigation_bar_use_cases.dart'
    as _california_ui_widgetbook_use_cases_california_navigation_bar_use_cases;
import 'package:california_ui_widgetbook/use_cases/california_product_card_use_cases.dart'
    as _california_ui_widgetbook_use_cases_california_product_card_use_cases;
import 'package:california_ui_widgetbook/use_cases/california_selector_use_cases.dart'
    as _california_ui_widgetbook_use_cases_california_selector_use_cases;
import 'package:california_ui_widgetbook/use_cases/california_theme_use_cases.dart'
    as _california_ui_widgetbook_use_cases_california_theme_use_cases;
import 'package:california_ui_widgetbook/use_cases/california_top_bar_use_cases.dart'
    as _california_ui_widgetbook_use_cases_california_top_bar_use_cases;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'theme',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'CaliforniaColors',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Palette',
            builder:
                _california_ui_widgetbook_use_cases_california_theme_use_cases
                    .buildCaliforniaColorsUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'CaliforniaSpacing',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Scale',
            builder:
                _california_ui_widgetbook_use_cases_california_theme_use_cases
                    .buildCaliforniaSpacingUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'CaliforniaTypography',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Type scale',
            builder:
                _california_ui_widgetbook_use_cases_california_theme_use_cases
                    .buildCaliforniaTypographyUseCase,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'widgets',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'CaliforniaButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'All variants',
            builder:
                _california_ui_widgetbook_use_cases_california_button_use_cases
                    .buildCaliforniaButtonAllVariantsUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Ghost',
            builder:
                _california_ui_widgetbook_use_cases_california_button_use_cases
                    .buildCaliforniaButtonGhostUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Primary',
            builder:
                _california_ui_widgetbook_use_cases_california_button_use_cases
                    .buildCaliforniaButtonPrimaryUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'CaliforniaCheckbox',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'All states',
            builder:
                _california_ui_widgetbook_use_cases_california_checkbox_use_cases
                    .buildCaliforniaCheckboxAllStatesUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Interactive',
            builder:
                _california_ui_widgetbook_use_cases_california_checkbox_use_cases
                    .buildCaliforniaCheckboxInteractiveUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'CaliforniaInputField',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'All states',
            builder:
                _california_ui_widgetbook_use_cases_california_input_field_use_cases
                    .buildCaliforniaInputFieldAllStatesUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Free-typing',
            builder:
                _california_ui_widgetbook_use_cases_california_input_field_use_cases
                    .buildCaliforniaInputFieldFreeTypingUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Selector',
            builder:
                _california_ui_widgetbook_use_cases_california_input_field_use_cases
                    .buildCaliforniaInputFieldSelectorUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'CaliforniaNavigationBar',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Interactive',
            builder:
                _california_ui_widgetbook_use_cases_california_navigation_bar_use_cases
                    .buildCaliforniaNavigationBarInteractiveUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'CaliforniaProductCard',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'All sizes',
            builder:
                _california_ui_widgetbook_use_cases_california_product_card_use_cases
                    .buildCaliforniaProductCardAllSizesUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Large',
            builder:
                _california_ui_widgetbook_use_cases_california_product_card_use_cases
                    .buildCaliforniaProductCardLargeUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Medium',
            builder:
                _california_ui_widgetbook_use_cases_california_product_card_use_cases
                    .buildCaliforniaProductCardMediumUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Small',
            builder:
                _california_ui_widgetbook_use_cases_california_product_card_use_cases
                    .buildCaliforniaProductCardSmallUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'CaliforniaSelector',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'All states',
            builder:
                _california_ui_widgetbook_use_cases_california_selector_use_cases
                    .buildCaliforniaSelectorAllStatesUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Interactive',
            builder:
                _california_ui_widgetbook_use_cases_california_selector_use_cases
                    .buildCaliforniaSelectorInteractiveUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'CaliforniaTopBar',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Detail product',
            builder:
                _california_ui_widgetbook_use_cases_california_top_bar_use_cases
                    .buildCaliforniaTopBarDetailProductUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'General',
            builder:
                _california_ui_widgetbook_use_cases_california_top_bar_use_cases
                    .buildCaliforniaTopBarGeneralUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Main screen',
            builder:
                _california_ui_widgetbook_use_cases_california_top_bar_use_cases
                    .buildCaliforniaTopBarMainScreenUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Message',
            builder:
                _california_ui_widgetbook_use_cases_california_top_bar_use_cases
                    .buildCaliforniaTopBarMessageUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Search by map',
            builder:
                _california_ui_widgetbook_use_cases_california_top_bar_use_cases
                    .buildCaliforniaTopBarSearchByMapUseCase,
          ),
        ],
      ),
    ],
  ),
];

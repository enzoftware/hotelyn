import 'package:flutter/material.dart';
import 'package:hotelyn/l10n/l10n.dart';
import 'package:hotelyn_components/components/buttons/h_button.dart';

class HotelynApp extends StatelessWidget {
  const HotelynApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'DMSans',
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Hotelyn',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HButton.ghost(
                onTap: () {},
                text: 'Press me',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

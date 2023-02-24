import 'package:discyo/components/header.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:flutter/material.dart';

class RegisterConfirmPage extends StatelessWidget {
  RegisterConfirmPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localized = DiscyoLocalizations.of(context);
    return PaletteBackground(
      colors: PaletteBackground.loginColors,
      layout: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PageHeader(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  localized.label("successful_registration_title"),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline2,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    localized.label("successful_registration_description"),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
                OutlinedButton(
                  child: Text(
                    localized.label("login"),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/login', ModalRoute.withName('/')),
                ),
              ],
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 20)),
          ],
        ),
      ),
    );
  }
}

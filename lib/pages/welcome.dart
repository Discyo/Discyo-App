import 'package:discyo/components/dialogs.dart';
import 'package:discyo/components/icons.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    required this.registerGoogle,
    required this.registerApple,
    Key? key,
  }) : super(key: key);

  final void Function() registerGoogle;
  final Future<bool> Function() registerApple;

  Widget _buildRegisterButton(BuildContext context, IconData icon, String label,
      void Function() callback) {
    return OutlinedButton.icon(
      icon: Icon(icon),
      label: Text(
        label,
        style: Theme.of(context).textTheme.subtitle1,
      ),
      onPressed: callback,
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return TextButton(
      child: Text(
        DiscyoLocalizations.of(context).label("login"),
        style: Theme.of(context).textTheme.subtitle1?.copyWith(
              decoration: TextDecoration.underline,
            ),
      ),
      onPressed: () => Navigator.pushNamed(context, "/login"),
    );
  }

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
            Padding(padding: const EdgeInsets.symmetric(vertical: 20)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildRegisterButton(
                  context,
                  DiscyoIcons.google,
                  localized.label("register_google"),
                  registerGoogle,
                ),
                _buildRegisterButton(
                  context,
                  DiscyoIcons.apple,
                  localized.label("register_apple"),
                  () async {
                    if (!await registerApple())
                      showError(context, localized.error("unexpected"));
                  },
                ),
                _buildRegisterButton(
                  context,
                  Icons.mail_outline,
                  localized.label("register_email"),
                  () => Navigator.pushNamed(context, "/register_form"),
                ),
                _buildLoginButton(context),
              ],
            ),
            SizedBox(
              height: 40,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 14),
                  children: [
                    TextSpan(
                      text: localized.label("register_acknowledge_1"),
                    ),
                    TextSpan(
                      text: localized.label("register_acknowledge_2"),
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap =
                            () => showDocument(context, "terms_and_conditions"),
                    ),
                    TextSpan(
                      text: localized.label("register_acknowledge_3"),
                    ),
                    TextSpan(
                      text: localized.label("register_acknowledge_4"),
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => showDocument(context, "privacy_policy"),
                    ),
                    TextSpan(
                      text: localized.label("register_acknowledge_5"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

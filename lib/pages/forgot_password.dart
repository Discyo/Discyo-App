import 'package:discyo/components/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:discyo/api.dart';
import 'package:discyo/components/fields.dart';
import 'package:discyo/components/header.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/localizations/localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({
    Key? key,
  }) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailKey = GlobalKey<FormFieldState>();
  final _codeKey = GlobalKey<FormFieldState>();
  final _passwordKey = GlobalKey<FormFieldState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _mailSent = false;
  bool _loading = false;

  void _sendRecoveryMail() {
    if (_emailKey.currentState?.validate() ?? false) {
      setState(() => _loading = true);
      DiscyoApi.sendRecoveryMail(_emailController.text).then(
        (value) => setState(() {
          _loading = false;
          _mailSent = true;
        }),
      );
    }
  }

  void _resetPassword(BuildContext context) {
    final localized = DiscyoLocalizations.of(context);
    if ((_codeKey.currentState?.validate() ?? false) &&
        (_passwordKey.currentState?.validate() ?? false)) {
      setState(() => _loading = true);
      DiscyoApi.resetPassword(
        _emailController.text,
        _codeController.text,
        _passwordController.text,
      ).then((value) {
        setState(() => _loading = false);
        if (value.code == 200) {
          showMessage(context, localized.label("reset_successful"));
          Navigator.of(context).pop();
        } else {
          showError(context, localized.error("code_incorrect"));
        }
      });
    }
  }

  List<Widget> _buildFields(BuildContext context) {
    final localized = DiscyoLocalizations.of(context);
    List<Widget> fields = [
      buildTextField(
        context,
        _emailController,
        localized.label("email"),
        enabled: !_mailSent,
        validator: (value) {
          if (value?.isEmpty ?? true)
            return localized.error("empty_email");
          final re =
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
          if (!RegExp(re).hasMatch(value ?? ""))
            return localized.error("invalid_email");
          return null;
        },
        key: _emailKey,
      ),
    ];

    if (_mailSent) {
      fields.addAll([
        buildTextField(
          context,
          _codeController,
          localized.label("code"),
          validator: (value) {
            if (value?.isEmpty ?? true)
              return localized.error("empty_code");
            return null;
          },
          key: _codeKey,
        ),
        buildTextField(
          context,
          _passwordController,
          localized.label("new_password"),
          obscure: true,
          validator: (value) {
            if (value?.isEmpty ?? true)
              return localized.error("empty_password");
            if ((value?.length ?? 0) < 6)
              return localized.error("invalid_password");
            return null;
          },
          key: _passwordKey,
        ),
      ]);
    }

    return fields;
  }

  Widget _buildSubmitButton(BuildContext context) {
    return OutlinedButton(
      child: _loading
          ? SizedBox(
              child: CircularProgressIndicator(strokeWidth: 2),
              height: 14,
              width: 14,
            )
          : Text(
              DiscyoLocalizations.of(context).label("submit"),
              style: Theme.of(context).textTheme.subtitle1,
            ),
      onPressed: _loading
          ? null
          : () => _mailSent ? _resetPassword(context) : _sendRecoveryMail(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PaletteBackground(
      colors: PaletteBackground.loginColors,
      layout: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            PageHeader(),
            Expanded(
              child: Form(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildFields(context) +
                        [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          _buildSubmitButton(context),
                        ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

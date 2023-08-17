/*
 * Copyright (C) 2023  Petr Buchal, Vladimír Jeřábek, Martin Ivančo
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

import 'package:discyo/components/dialogs.dart';
import 'package:discyo/components/fields.dart';
import 'package:discyo/components/header.dart';
import 'package:discyo/components/icons.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({
    required this.loginEmail,
    required this.loginGoogle,
    required this.loginApple,
    Key? key,
  }) : super(key: key);

  final Future<int> Function(String, String) loginEmail;
  final void Function() loginGoogle;
  final Future<bool> Function() loginApple;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final localized = DiscyoLocalizations.of(context);
      showProgress(
        context,
        widget.loginEmail(
          _usernameController.text,
          _passwordController.text,
        ),
        localized.label("loading"),
      ).then((response) {
        if (response == 403)
          Navigator.pushNamed(context, "/email_unconfirmed");
        else if (response != 200)
          showError(context, localized.error("login_incorrect"));
      });
    }
  }

  Widget _buildLoginButton(BuildContext context, IconData? icon, String label,
      void Function() callback) {
    final labelWidget =
        Text(label, style: Theme.of(context).textTheme.subtitle1);
    if (icon == null)
      return OutlinedButton(child: labelWidget, onPressed: callback);
    return OutlinedButton.icon(
      icon: Icon(icon),
      label: labelWidget,
      onPressed: callback,
    );
  }

  Widget _buildFields(BuildContext context) {
    final localized = DiscyoLocalizations.of(context);
    return AutofillGroup(
      child: Column(
        children: <Widget>[
          buildTextField(
            context,
            _usernameController,
            localized.label("username_or_email"),
            validator: (value) {
              if (value?.isEmpty ?? true)
                return localized.error("empty_username_or_email");
              return null;
            },
          ),
          buildTextField(
            context,
            _passwordController,
            localized.label("password"),
            hint: true,
            obscure: true,
            validator: (value) {
              if (value?.isEmpty ?? true)
                return localized.error("empty_password");
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return TextButton(
      child: Text(
        DiscyoLocalizations.of(context).label("forgot_password"),
        style: Theme.of(context).textTheme.subtitle1?.copyWith(
              decoration: TextDecoration.underline,
            ),
      ),
      onPressed: () => Navigator.pushNamed(context, "/forgot_password"),
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
          children: [
            PageHeader(),
            Expanded(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildLoginButton(
                        context,
                        DiscyoIcons.google,
                        localized.label("login_google"),
                        widget.loginGoogle,
                      ),
                      _buildLoginButton(
                        context,
                        DiscyoIcons.apple,
                        localized.label("login_apple"),
                        () async {
                          if (!await widget.loginApple())
                            showError(context, localized.error("unexpected"));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      Text(
                        localized.label("login_email"),
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                      ),
                      _buildFields(context),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      _buildLoginButton(
                        context,
                        null,
                        localized.label("login"),
                        () => _login(context),
                      ),
                      _buildForgotPasswordButton(context),
                    ],
                  ),
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 20)),
          ],
        ),
      ),
    );
  }
}

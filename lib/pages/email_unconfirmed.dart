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

import 'package:discyo/api.dart';
import 'package:discyo/components/dialogs.dart';
import 'package:discyo/components/fields.dart';
import 'package:discyo/components/header.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:flutter/material.dart';

class EmailUnconfirmedPage extends StatefulWidget {
  EmailUnconfirmedPage({
    Key? key,
  }) : super(key: key);

  @override
  _EmailUnconfirmedPageState createState() => _EmailUnconfirmedPageState();
}

class _EmailUnconfirmedPageState extends State<EmailUnconfirmedPage> {
  final _emailKey = GlobalKey<FormFieldState>();
  final _emailController = TextEditingController();

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
                  localized.label("email_not_confirmed"),
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton(
                    child: Text(
                      localized.label("login"),
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Text(
                  localized.label("resend_email_question"),
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.center,
                ),
                buildTextField(
                  context,
                  _emailController,
                  localized.label("email"),
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
                Padding(padding: const EdgeInsets.symmetric(vertical: 8)),
                OutlinedButton(
                  child: Text(
                    localized.label("resend_email"),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  onPressed: () {
                    if (_emailKey.currentState?.validate() ?? false) {
                      DiscyoApi.resendConfirmationEmail(_emailController.text);
                      Navigator.pop(context);
                      showInfoDialog(
                        context,
                        localized.label("confirmation_resent_title"),
                        localized.label("confirmation_resent_description"),
                      );
                    }
                  },
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

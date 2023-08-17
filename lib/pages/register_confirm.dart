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

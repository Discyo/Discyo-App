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
import 'package:discyo/models/media.dart';
import 'package:discyo/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InitProvidersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaType = ModalRoute.of(context)?.settings.arguments as Type;
    final localized = DiscyoLocalizations.of(context);

    return PaletteBackground(
      colors: PaletteBackground.defaultColors,
      layout: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: PageHeader(
                title: localized.label("platforms_title"),
                button: PageHeader.helpButton(
                  context,
                  localized.label("platforms_title"),
                  localized.label("platforms_description"),
                ),
              ),
            ),
            Expanded(
              child: Consumer<UserModel>(builder: (context, user, child) {
                return _InitProvidersBody(user: user, mediaType: mediaType);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitProvidersBody extends StatefulWidget {
  const _InitProvidersBody({
    required this.user,
    required this.mediaType,
    Key? key,
  }) : super(key: key);

  final UserModel user;
  final Type mediaType;

  @override
  State<_InitProvidersBody> createState() => _InitProvidersBodyState();
}

class _InitProvidersBodyState extends State<_InitProvidersBody> {
  Set<String>? _subscribed;
  Future<List<StreamingPlatform>>? _available;

  Future<List<StreamingPlatform>> _getAvailablePlatforms() async {
    var response = await WapitchApi.getProviders(
      medium: widget.mediaType,
      country: widget.user.country,
    );

    if (response.code != 200) {
      DiscyoApi.error(
        this.runtimeType.toString(),
        "Could not fetch streaming service initialization! (Code ${response.code})",
      );
      return [];
    }

    return response.body
        .map<StreamingPlatform>(
            (e) => StreamingPlatformExtension.fromId(e["id"])!)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _available = _getAvailablePlatforms();
  }

  @override
  Widget build(BuildContext context) {
    final localized = DiscyoLocalizations.of(context);
    _subscribed = _subscribed ??
        widget.user.subscribedPlatforms.map<String>((e) => e.id).toSet();
    return Column(
      children: [
        Expanded(
          child: FutureBuilder(
            future: _available,
            builder: (context, snapshot) {
              if (snapshot.hasData)
                return buildCheckboxSetField(
                  context,
                  "",
                  (snapshot.data as List<StreamingPlatform>)
                      .map<Map<String, dynamic>>((e) {
                    return {
                      "title": e.name,
                      "icon": e.logo,
                      "state": _subscribed?.contains(e.id) ?? false,
                      "value": e.id,
                    };
                  }).toList(),
                  (value) => setState(() {
                    final subscribed = _subscribed;
                    if (subscribed != null) {
                      subscribed.contains(value)
                          ? subscribed.remove(value)
                          : subscribed.add(value);
                    }
                  }),
                );
              else
                return Center(child: CircularProgressIndicator());
            },
          ),
        ),
        OutlinedButton(
          onPressed: () async {
            await showProgress(
              context,
              widget.user
                  .setInfo({"subscribed_platforms": _subscribed?.toList()}),
              localized.label("saving"),
            );
            Navigator.pop(context);
          },
          child: Text(localized.label("submit")),
        ),
      ],
    );
  }
}

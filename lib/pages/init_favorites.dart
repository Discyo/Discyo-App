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
import 'package:discyo/components/header.dart';
import 'package:discyo/components/icons.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/models/media.dart';
import 'package:discyo/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InitFavoritesPage extends StatelessWidget {
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
                title: localized.label("favorites_title"),
                button: PageHeader.helpButton(
                  context,
                  localized.label("favorites_title"),
                  localized.label("favorites_description"),
                ),
              ),
            ),
            Expanded(
              child: Consumer<UserModel>(builder: (context, user, child) {
                return _InitFavoritesBody(user: user, mediaType: mediaType);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitFavoritesBody extends StatefulWidget {
  const _InitFavoritesBody({
    required this.user,
    required this.mediaType,
    Key? key,
  }) : super(key: key);

  final UserModel user;
  final Type mediaType;

  @override
  _InitFavoritesBodyState createState() => _InitFavoritesBodyState();
}

class _InitFavoritesBodyState extends State<_InitFavoritesBody> {
  Future<List>? _media;
  Set<Medium> _selection = {};

  Future<List> _getInitMedia() async {
    // Fetch init media
    var response = await DiscyoApi.recommendations(
      widget.mediaType,
      widget.user.token,
      init: true,
    );

    // If token is invalid, try to get a new one
    if (response.code != 200) {
      await widget.user.refreshTokens();
      response = await DiscyoApi.recommendations(
        widget.mediaType,
        widget.user.token,
        init: true,
      );
      if (response.code != 200) {
        DiscyoApi.error(
          this.runtimeType.toString(),
          "Could not fetch media initialization! (Code ${response.code})",
        );
        return [];
      }
    }

    return response.body;
  }

  Widget _buildItem(BuildContext context, Map<String, dynamic> item) {
    Future<Medium>? future;
    if (widget.mediaType == Film)
      future = Film.fetch(
        item["id"],
        item["tmdb_id"],
        language: widget.user.language,
      );
    if (widget.mediaType == Show)
      future = Show.fetch(
        item["id"],
        item["tmdb_id"],
        language: widget.user.language,
      );
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return TextButton(
            style: ButtonStyle(splashFactory: NoSplash.splashFactory),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                constraints: BoxConstraints.expand(),
                padding: const EdgeInsets.all(4),
                color:
                    _selection.any((e) => e.id == (snapshot.data as Medium).id)
                        ? Theme.of(context).accentColor
                        : Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      SizedBox.expand(
                        child: (snapshot.data as Medium).getImage(
                          fit: BoxFit.cover,
                          colorBlendMode: BlendMode.srcOver,
                          color: _selection.any(
                                  (e) => e.id == (snapshot.data as Medium).id)
                              ? Colors.black38
                              : Colors.transparent,
                        ),
                      ),
                      Center(
                        child: _selection.any(
                                (e) => e.id == (snapshot.data as Medium).id)
                            ? Icon(
                                DiscyoIcons.awesome,
                                size: 48,
                                color: Colors.white,
                              )
                            : Container(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            onPressed: () => setState(() => _selection
                    .any((e) => e.id == (snapshot.data as Medium).id)
                ? _selection
                    .removeWhere((e) => e.id == (snapshot.data as Medium).id)
                : _selection.add(snapshot.data as Medium)),
          );
        else
          return Container();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _media = _getInitMedia();
  }

  @override
  Widget build(BuildContext context) {
    final localized = DiscyoLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: FutureBuilder(
            future: _media,
            builder: (context, snapshot) {
              if (snapshot.hasData)
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: (snapshot.data as List).length,
                  itemBuilder: (context, i) =>
                      _buildItem(context, (snapshot.data as List)[i]),
                );
              else
                return Center(child: CircularProgressIndicator());
            },
          ),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: _selection.length < 5
                      ? Colors.grey[600]!
                      : Colors.white)),
          onPressed: _selection.length < 5
              ? null
              : () async {
                  await showProgress(
                    context,
                    widget.user
                        .setMediaListState(_selection, MediaState.awesome),
                    localized.label("sending_init"),
                  );
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/init_providers',
                    ModalRoute.withName('/'),
                    arguments: widget.mediaType,
                  );
                },
          child: Text(
            localized.label("submit") +
                (_selection.length < 5
                    ? " (" + _selection.length.toString() + "/5)"
                    : ""),
          ),
        ),
      ],
    );
  }
}

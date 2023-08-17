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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/models/media.dart';
import 'package:flutter/material.dart';
import 'package:tmdb_dart/tmdb_dart.dart';

class CreatorsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Medium medium = ModalRoute.of(context)?.settings.arguments as Medium;
    List<Cast> cast = [];
    List<Crew> crew = [];
    if (medium is Show) {
      cast = medium.cast;
      crew = medium.crew;
    }
    if (medium is Film) {
      cast = medium.cast;
      crew = medium.crew;
    }

    return PaletteBackground(
      colors: medium.colors,
      layout: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                alignment: Alignment.centerLeft,
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.only(top: 8.0),
              ),
            ),
          ),
          Expanded(
            child: _Creators(cast: cast, crew: crew),
          )
        ],
      ),
    );
  }
}

class _Creators extends StatefulWidget {
  const _Creators({
    required this.cast,
    required this.crew,
    Key? key,
  }) : super(key: key);

  final List<Cast> cast;
  final List<Crew> crew;

  @override
  _CreatorsState createState() => _CreatorsState();
}

class _CreatorsState extends State<_Creators>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Widget _buildItem(Creator creator) {
    final ip = creator.profilePath != null
        ? CachedNetworkImageProvider(creator.profilePath!)
        : AssetImage("assets/other/missing_profile.png");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: SizedBox(
        height: 76.0,
        child: Row(
          children: <Widget>[
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0)),
            SizedBox(
              child: ClipOval(
                child: Image(image: ip as ImageProvider, fit: BoxFit.cover),
              ),
              width: 60.0,
              height: 60.0,
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 6.0)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creator.name,
                  style: Theme.of(context).textTheme.subtitle1,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  (creator.runtimeType == Cast
                          ? (creator as Cast).character
                          : (creator as Crew).job) ??
                      "",
                  style: Theme.of(context).textTheme.caption,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    final localized = DiscyoLocalizations.of(context);
    return Column(
      children: [
        SizedBox(
          height: 40.0,
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: localized.label("cast")),
              Tab(text: localized.label("crew")),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ListView.builder(
                itemBuilder: (_, i) => _buildItem(widget.cast[i]),
                itemCount: widget.cast.length,
              ),
              ListView.builder(
                itemBuilder: (_, i) => _buildItem(widget.crew[i]),
                itemCount: widget.crew.length,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

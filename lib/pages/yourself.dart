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

import 'package:discyo/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:discyo/components/icons.dart';
import 'package:discyo/components/dialogs.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/models/loader.dart';
import 'package:discyo/models/media.dart';
import 'package:discyo/models/user.dart';

class YourselfPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, user, child) {
        return PaletteBackground(
          colors: user.colors,
          layout: Column(
            children: <Widget>[
              _YourselfHeader(user: user, logout: user.logout),
              _YourselfProfile(),
              Expanded(child: _YourselfListGrid()),
            ],
          ),
        );
      },
    );
  }
}

class _YourselfHeader extends StatelessWidget {
  _YourselfHeader({
    required this.user,
    required this.logout,
    Key? key,
  }) : super(key: key);

  final UserModel user;
  final Function logout;

  Widget _buildMenuButton(BuildContext context) {
    final localized = DiscyoLocalizations.of(context);
    return PopupMenuButton<int>(
      onSelected: (int option) {
        switch (option) {
          case 1:
            Navigator.pushNamed(context, "/edit_account");
            break;
          case 2:
            showReportProblemForm(context, user);
            break;
          case 3:
            openLink("https://discord.com/invite/my4VgGv33b", context);
            break;
          case 4:
            showDocument(context, "privacy_policy");
            break;
          case 5:
            showDocument(context, "terms_and_conditions");
            break;
          case 6:
            logout();
            break;
          default:
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        PopupMenuItem<int>(
          value: 1,
          child: Text(localized.label("edit_account")),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: Text(localized.label("report_problem_title")),
        ),
        PopupMenuItem<int>(
          value: 3,
          child: Row(
            children: <Widget>[
              Image.asset("assets/other/discord.png", height: 32),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 4)),
              Text(localized.label("community_discord")),
            ],
          ),
        ),
        PopupMenuItem<int>(
          value: 4,
          child: Text(localized.label("privacy_policy")),
        ),
        PopupMenuItem<int>(
          value: 5,
          child: Text(localized.label("terms_and_conditions")),
        ),
        PopupMenuItem<int>(
          value: 6,
          child: Text(localized.label("log_out")),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(width: 40, height: 40),
        Text(
          user.username,
          style: Theme.of(context).textTheme.headline4,
        ),
        _buildMenuButton(context),
      ],
    );
  }
}

class _YourselfProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, user, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.cover, image: user.image),
                      ),
                    ),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 4)),
                    Text(
                      user.name ?? "",
                      style: Theme.of(context).textTheme.headline6,
                    )
                  ],
                ),
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: _YourselfStatsBar(stats: user.getMediaStats()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _YourselfStatsBar extends StatelessWidget {
  const _YourselfStatsBar({
    required this.stats,
  });

  final Future<Map<Type, int>> stats;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: FutureBuilder(
            future: stats,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data as Map<Type, int>;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: mediaTypes.map((mediaType) {
                    var label = "";
                    if (data[mediaType] != null && data[mediaType]! > 0) {
                      if (data[mediaType]! > 1000)
                        label = (data[mediaType]! / 1000)
                                .toStringAsFixed(1)
                                .replaceFirst(".0", "") +
                            "K";
                      else
                        label = data[mediaType]!.toString();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(label,
                              style: Theme.of(context).textTheme.bodyText2),
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2)),
                          Icon(
                            DiscyoIcons.medium(mediaType, false),
                            color: label.isEmpty
                                ? Theme.of(context).primaryColorLight
                                : Theme.of(context).accentColor,
                          ),
                        ],
                      ),
                    );
                  }).toList(growable: false),
                );
              } else
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: LinearProgressIndicator(minHeight: 1),
                );
            }));
  }
}

class _YourselfListGrid extends StatelessWidget {
  final List<IconData> icons = [
    DiscyoIcons.diary,
    DiscyoIcons.discover_later,
    DiscyoIcons.friends,
    DiscyoIcons.change_my_mind,
  ];
  final List<List<MediaState>> states = [
    [MediaState.awful, MediaState.meh, MediaState.good, MediaState.awesome],
    [MediaState.saved],
    [],
    [MediaState.dismissed],
  ];

  @override
  Widget build(BuildContext context) {
    final localized = DiscyoLocalizations.of(context);
    final List<String> names = [
      localized.label("diary"),
      localized.label("discover_later"),
      localized.label("friends"),
      localized.label("change_my_mind"),
    ];

    void openList(UserModel user, int i) async {
      if (i == 2) {
        showMessage(
          context,
          DiscyoLocalizations.of(context).error("friends_unsupported"),
        );
        return;
      }

      FilteredListLoader loader;
      if (i == 0)
        loader = FilteredListLoader(
          (int j) => user.getList(states[i], page: j),
          [TypeFilter(), StateFilter()],
        );
      else
        loader = FilteredListLoader(
          (int j) => user.getList(states[i], page: j),
          [
            TypeFilter(),
            StreamingPlatformFilter(
              user.country,
              user.availablePlatforms.toList(),
            ),
          ],
        );

      Navigator.pushNamed(
        context,
        "/list",
        arguments: {
          "title": names[i],
          "icon": icons[i],
          "loader": loader,
          "show_states": i == 0,
        },
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: List.generate(names.length, (i) {
        return Consumer<UserModel>(builder: (context, user, child) {
          return OutlinedButton(
            child: Row(
              children: [
                Icon(icons[i], size: 28),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 6)),
                Expanded(
                  child: Text(
                    names[i],
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 25,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () => openList(user, i),
          );
        });
      }),
    );
  }
}

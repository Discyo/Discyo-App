import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:discyo/api.dart';
import 'package:discyo/components/dialogs.dart';
import 'package:discyo/components/icons.dart';
import 'package:discyo/components/list_item.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/models/media.dart';
import 'package:discyo/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _controller = TextEditingController();
  bool _loadingDetail = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _lockLoading(bool lock) {
    // Try to lock
    if (lock) {
      if (_loadingDetail) return false;
      _loadingDetail = true;
    }
    // Unlock
    else {
      _loadingDetail = false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: (context, user, child) {
      return GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: PaletteBackground(
          colors: PaletteBackground.defaultColors,
          layout: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ChangeNotifierProvider.value(
              value: _controller,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SearchBar(),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: SearchResults(user: user, lockLoading: _lockLoading),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Consumer<TextEditingController>(
        builder: (context, controller, child) {
          return TextField(
            controller: controller,
            decoration: InputDecoration(
                icon: Icon(DiscyoIcons.search),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () => controller.clear(),
                        icon: Icon(Icons.clear),
                      ),
                hintText: DiscyoLocalizations.of(context).label("search_bar"),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).accentColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0)),
            style: Theme.of(context).textTheme.subtitle1,
          );
        },
      ),
    );
  }
}

class SearchItem {
  final int tmdb;
  final Type type;
  final String title;
  final ImageProvider thumbnail;

  static ImageProvider _getThumbnail(String? path) {
    if (path == null)
      return AssetImage("assets/other/missing_thumbnail.png");
    else
      return CachedNetworkImageProvider(
          TmdbApiWrapper.thumbnailUrl(path.substring(min(path.length, 1))));
  }

  SearchItem(
    this.tmdb,
    this.type,
    this.title, {
    String? thumbnailPath,
  }) : thumbnail = _getThumbnail(thumbnailPath);
}

class SearchResults extends StatelessWidget {
  SearchResults({
    required this.user,
    required this.lockLoading,
    Key? key,
  }) : super(key: key);

  final UserModel user;
  final bool Function(bool) lockLoading;

  Widget _buildItem(BuildContext context, SearchItem item) {
    return ListItem(
      title: item.title,
      thumbnail: item.thumbnail,
      callback: () async {
        if (!lockLoading(true)) return;
        ApiResponse? response;
        if (item.type == Film)
          response = await WapitchApi.getMovieId(item.tmdb);
        if (item.type == Show) response = await WapitchApi.getShowId(item.tmdb);
        if ((response?.code ?? 0) != 200 || response?.body["id"] == null) {
          showMessage(
              context, DiscyoLocalizations.of(context).label("not_in_db"));
          return;
        }
        if (item.type == Film)
          Navigator.pushNamed(
            context,
            "/details",
            arguments: await Film.fetch(
              response!.body["id"],
              item.tmdb,
              language: user.language,
              state: await user.getMediaState(response.body["id"]),
            ),
          );
        if (item.type == Show)
          Navigator.pushNamed(
            context,
            "/details",
            arguments: await Show.fetch(
              response!.body["id"],
              item.tmdb,
              language: user.language,
              state: await user.getMediaState(response.body["id"]),
            ),
          );
        lockLoading(false);
      },
    );
  }

  Future<List<SearchItem>> _search(String query) async {
    final response = await TmdbApiWrapper.multiSearch(query, user.language);
    if (response.code != 200) return [];
    response.body["results"].removeWhere(
        (e) => e["media_type"] != "tv" && e["media_type"] != "movie");
    return response.body["results"].map<SearchItem>((e) {
      if (e["media_type"] == "tv")
        return SearchItem(e["id"], Show, e["name"],
            thumbnailPath: e["poster_path"]);
      if (e["media_type"] == "movie")
        return SearchItem(e["id"], Film, e["title"],
            thumbnailPath: e["poster_path"]);
      DiscyoApi.error("SearchResults", "Unexpected media type in results!");
      throw "Unexpected media type in results!";
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TextEditingController>(
      builder: (context, controller, child) {
        return FutureBuilder(
          future: _search(controller.text),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: (snapshot.data as List<SearchItem>).length,
                itemBuilder: (_, i) =>
                    _buildItem(context, (snapshot.data as List<SearchItem>)[i]),
              );
            } else
              return Container();
          },
        );
      },
    );
  }
}

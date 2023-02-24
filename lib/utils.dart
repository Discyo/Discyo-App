import 'dart:convert';
import 'dart:core';
import 'package:discyo/api.dart';
import 'package:discyo/components/dialogs.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/models/media.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:tmdb_dart/tmdb_dart.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> checkInternet() {
  return checkConnection("https://www.google.com");
}

Future<bool> checkServers() {
  return checkConnection("${DiscyoApi.baseUrl}/");
}

Future<bool> checkConnection(String url) async {
  try {
    return (await get(Uri.parse(url))).statusCode == 200;
  } catch (_) {}
  return false;
}

void openLink(String url, BuildContext context) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri))
    await launchUrl(uri);
  else
    showMessage(context, DiscyoLocalizations.of(context).error("unexpected"));
}

String encodeCreators(List<Creator> creators) {
  return jsonEncode(creators
      .map((e) => {
            "id": e.id,
            "name": e.name,
            "profile_url": e.profilePath,
          })
      .toList(growable: false));
}

List<Creator> decodeCreators(String creators) {
  return jsonDecode(creators)
      .map<Creator>((e) => Creator(
            id: e["id"],
            name: e["name"],
            profilePath: e["profile_url"],
          ))
      .toList(growable: false);
}

String encodeCast(List<Cast> cast) {
  return jsonEncode(cast
      .map((e) => {
            "id": e.id,
            "name": e.name,
            "character": e.character ?? "",
            "profile_url": e.profilePath,
          })
      .toList(growable: false));
}

List<Cast> decodeCast(String cast) {
  return jsonDecode(cast)
      .map<Cast>((e) => Cast(
            id: e["id"],
            name: e["name"],
            character: e["character"] ?? "",
            profilePath: e["profile_url"],
          ))
      .toList(growable: false);
}

String encodeCrew(List<Crew> crew) {
  return jsonEncode(crew
      .map((e) => {
            "id": e.id,
            "name": e.name,
            "job": e.job ?? "",
            "profile_url": e.profilePath,
          })
      .toList(growable: false));
}

List<Crew> decodeCrew(String crew) {
  return jsonDecode(crew)
      .map<Crew>((e) => Crew(
            id: e["id"],
            name: e["name"],
            job: e["job"] ?? "",
            profilePath: e["profile_url"],
          ))
      .toList(growable: false);
}

String encodeMovieBases(List<MovieBase> movieBases) {
  return jsonEncode(movieBases
      .map((e) => {
            "id": e.id,
            "original_language": e.originalLanguage,
            "title": e.title,
            "poster_url": e.posterPath,
          })
      .toList(growable: false));
}

List<MovieBase> decodeMovieBases(String movieBases) {
  return jsonDecode(movieBases)
      .map<MovieBase>((e) => MovieBase(
            id: e["id"],
            originalLanguage: e["original_language"],
            title: e["title"],
            posterPath: e["poster_url"],
          ))
      .toList(growable: false);
}

String encodeTvBases(List<TvBase> tvBases) {
  return jsonEncode(tvBases
      .map((e) => {
            "id": e.id,
            "original_language": e.originalLanguage,
            "name": e.name,
            "poster_url": e.posterPath,
          })
      .toList(growable: false));
}

List<TvBase> decodeTvBases(String tvBases) {
  return jsonDecode(tvBases)
      .map<TvBase>((e) => TvBase(
            id: e["id"],
            originalLanguage: e["original_language"],
            name: e["name"],
            posterPath: e["poster_url"],
          ))
      .toList(growable: false);
}

String encodeSources(List<MediaSource> sources) {
  return jsonEncode(sources
      .map((e) => {
            "provider_id": e.platform.id,
            "country_code": e.country,
            "url": e.url,
          })
      .toList(growable: false));
}

List<MediaSource> decodeSources(String sources) {
  List<MediaSource> result = [];
  for (final e in jsonDecode(sources)) {
    final p = StreamingPlatformExtension.fromId(e["provider_id"]);
    if (p != null) result.add(MediaSource(p, e["country_code"], e["url"]));
  }
  return result;
}

List<T>? castToListSafely<T>(dynamic object) {
  List<T>? list;
  try {
    list = object.map<T>((e) => e as T).toList();
  } catch (e) {}
  return list;
}

Future<List<String>> getLocalizedTrailerUrls(
  List<Video> localizedVideos,
  Future<List<Video>> Function() getFallbackVideos,
) async {
  List<String> urls = [];
  try {
    // If we have any localized videos, convert them to urls
    urls = localizedVideos.expand<String>((v) {
      if (v.type != "Trailer") return <String>[];
      final u = TmdbApiWrapper.videoUrl(v);
      return u == null ? <String>[] : <String>[u];
    }).toList();
    // Otherwise, fetch fallback videos
    if (urls.isEmpty) {
      urls = (await getFallbackVideos()).expand<String>((v) {
        if (v.type != "Trailer") return <String>[];
        final u = TmdbApiWrapper.videoUrl(v);
        return u == null ? <String>[] : <String>[u];
      }).toList();
    }
  } catch (e) {}
  return urls;
}

Future<Map<String, String>> getConfigurationMap(String listName) async {
  final response = await DiscyoApi.configuration(listName);
  final configuration = Map<String, String>.fromIterable(
    response.body,
    key: (item) => item["english_name"],
    value: (item) => item["code"],
  );
  return configuration;
}

enum _ConnectionState { unknown, disconnected, serversDown, connected }

class ConnectionChecker extends StatefulWidget {
  ConnectionChecker({
    required this.builder,
    required this.placeholder,
    Key? key,
  }) : super(key: key);

  final Widget Function(BuildContext) builder;
  final Widget placeholder;

  Widget buildWarning(BuildContext context, _ConnectionState connectionState) {
    final localized = DiscyoLocalizations.of(context);
    String message = localized.error("unexpected");
    if (connectionState == _ConnectionState.disconnected)
      message = DiscyoLocalizations.of(context).error("no_internet");
    if (connectionState == _ConnectionState.serversDown)
      message = DiscyoLocalizations.of(context).error("server_down");
    return Scaffold(
      body: Container(
        color: Colors.grey[900],
        child: Align(
          alignment: Alignment.center,
          child: Text(
            message,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  _ConnectionCheckerState createState() => _ConnectionCheckerState();
}

class _ConnectionCheckerState extends State<ConnectionChecker> {
  _ConnectionState connectionState = _ConnectionState.unknown;

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  void checkConnection() async {
    if (!(await checkInternet())) {
      setState(() => connectionState = _ConnectionState.disconnected);
      Future.delayed(Duration(seconds: 3), checkConnection);
      return;
    }
    if (!(await checkServers())) {
      setState(() => connectionState = _ConnectionState.serversDown);
      Future.delayed(Duration(seconds: 3), checkConnection);
      return;
    }
    setState(() => connectionState = _ConnectionState.connected);
  }

  @override
  Widget build(BuildContext context) {
    switch (connectionState) {
      case _ConnectionState.unknown:
        return widget.placeholder;
      case _ConnectionState.disconnected:
      case _ConnectionState.serversDown:
        return widget.buildWarning(context, connectionState);
      case _ConnectionState.connected:
        return widget.builder(context);
    }
  }
}

class UniLinker extends ChangeNotifier {
  String? _refresh;
  bool get hasRefreshToken => _refresh != null;
  String? get refreshToken {
    String? tmp = _refresh;
    _refresh = null;
    return tmp;
  }

  UniLinker() {
    initUniLinks();
  }

  Future<void> initUniLinks() async {
    try {
      _takeRefreshToken(await getInitialUri());
    } on FormatException {}
    uriLinkStream.listen(_takeRefreshToken, onError: (err) {});
  }

  _takeRefreshToken(Uri? uri) {
    if (uri != null &&
        uri.scheme == "app" &&
        uri.host == "discyo.currant.ai" &&
        uri.queryParameters.containsKey("refresh_token")) {
      _refresh = uri.queryParameters["refresh_token"];
      notifyListeners();
      if (DiscyoApi.browser.isOpened()) DiscyoApi.browser.close();
    }
  }
}

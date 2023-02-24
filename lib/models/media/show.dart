import 'dart:convert';
import 'package:discyo/api.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/models/media/medium.dart';
import 'package:discyo/utils.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:tmdb_dart/tmdb_dart.dart';

class Show extends Medium {
  final int tmdb;
  final String originalTitle;
  final List<int> years;
  final List<Creator> creators;
  final List<Cast> cast;
  final List<Crew> crew;
  final int averageLength;
  final int episodes;
  final int seasons;
  final List<String> trailerUrls;
  final List<TvBase> similar;

  Show(
    String id,
    String title,
    this.tmdb, {
    String? originalTitle,
    List<int>? years,
    List<Creator>? creators,
    List<Cast>? cast,
    List<Crew>? crew,
    int? averageLength,
    int? episodes,
    int? seasons,
    List<String>? trailerUrls,
    List<TvBase>? similar,
    MediaState? state,
    String? imageName,
    List<String>? genres,
    String? description,
    List<int>? friends,
    List<MediaSource>? sources,
  })  : originalTitle = originalTitle ?? "",
        years = years ?? const [],
        creators = creators ?? const [],
        cast = cast ?? const [],
        crew = crew ?? const [],
        averageLength = averageLength ?? 0,
        episodes = episodes ?? 0,
        seasons = seasons ?? 0,
        trailerUrls = trailerUrls ?? const [],
        similar = similar ?? const [],
        super(
          id,
          title,
          state: state,
          imageName: imageName,
          genres: genres,
          description: description,
          friends: friends,
          sources: sources,
        );

  String get headline =>
      years.length > 0 && averageLength > 0 ? "${years[0]} • $length" : "";
  String get length => averageLength > 0 ? "~ $averageLength min" : "";
  String get release {
    if (years.length < 2)
      return "${years[0]} - ";
    else
      return "${years[0]} - ${years[1]}";
  }

  @override
  String creator(DiscyoLocalizations localized) {
    try {
      return "${localized.label('created_by')}\n${creators[0].name}";
    } catch (e) {
      return localized.label("unknown_creator");
    }
  }

  @override
  void setState(MediaState? newState) {
    super.setState(newState);
    ShowCache.setState(id, newState);
  }

  static Future<Show> fetch(String id, int tmdb,
      {String language = "en", MediaState? state}) async {
    // First check cache, if it's not there, fetch it
    Show? cached = await ShowCache.retrieve(id);
    if (cached != null) return cached;
    return fetchTMDB(id, tmdb, language: language, state: state);
  }

  static Future<Show> fetchTMDB(String id, int tmdb,
      {String language = "en", MediaState? state}) async {
    // Fetch show from TMDB
    TmdbApiWrapper.service.configuration = TmdbApiWrapper.configuration;
    Show show = await fromTMDB(
      id,
      state,
      await TmdbApiWrapper.service.tv.getDetails(
        tmdb,
        language: language,
        appendSettings: AppendSettings(
          includeImages: true,
          includeCredits: true,
          includeVideos: true,
          includeRecommendations: true,
        ),
        qualitySettings: QualitySettings(),
      ),
    );

    // Cache it
    ShowCache.cache(show);
    return show;
  }

  static Future<Show> fromTMDB(
      String id, MediaState? state, TvShow tvshow) async {
    List<int> years = [];
    try {
      years.add(tvshow.firstAirDate!.year);
      years.add(tvshow.lastAirDate!.year);
    } catch (e) {}

    int? averageLength;
    try {
      averageLength = tvshow.episodeRunTime[0];
    } catch (e) {}

    List<String>? genres;
    try {
      genres = tvshow.genres.map((e) => e.name).toList(growable: false);
    } catch (e) {}

    String? description = tvshow.overview;
    if (description == null || description == "") {
      final en = await TmdbApiWrapper.service.tv.getDetails(tvshow.id);
      description = en.overview;
    }

    List<String> trailerUrls = await getLocalizedTrailerUrls(
      tvshow.videos,
      () => TmdbApiWrapper.service.tv.getVideos(tvshow.id),
    );

    List<MediaSource> sources = [];
    final response = await WapitchApi.getShowProviders(id);
    if (response.code == 200) {
      sources = decodeSources(jsonEncode(response.body["providers"]));
    }

    return Show(
      id,
      tvshow.name,
      tvshow.id,
      originalTitle: tvshow.originalName,
      years: years,
      creators: tvshow.createdBy,
      cast: tvshow.credits?.cast,
      crew: tvshow.credits?.crew,
      averageLength: averageLength,
      episodes: tvshow.seasons.fold<int>(0, (v, e) => v + e.episodeCount),
      seasons: tvshow.seasons.length,
      trailerUrls: trailerUrls,
      state: state,
      imageName: TmdbApiWrapper.imageName(tvshow.posterPath),
      genres: genres,
      description: description,
      similar: tvshow.recommendations,
      sources: sources,
    );
  }
}

class ShowCache {
  static final String _table = "show";

  static Future<Show?> retrieve(String id) async {
    Map<String, dynamic>? record;
    try {
      record = (await (await MediaCache.db)
          .query(_table, where: "id = ?", whereArgs: [id]))[0];
    } catch (e) {}
    if (record == null) return null;

    Map<String, dynamic> info = jsonDecode(record["info"]);
    return Show(
      id,
      record["title"],
      record["tmdb"],
      state: MediaStateExtension.fromIndex(record["state"]),
      imageName: record["image"],
      originalTitle: info["originalTitle"] ?? null,
      years: castToListSafely<int>(info["years"]),
      averageLength: info["averageLength"] ?? null,
      episodes: info["episodes"] ?? null,
      seasons: info["seasons"] ?? null,
      genres: castToListSafely<String>(info["genres"]),
      description: info["description"] ?? null,
      creators: decodeCreators(info["creators"]),
      cast: decodeCast(info["cast"]),
      crew: decodeCrew(info["crew"]),
      trailerUrls: castToListSafely<String>(info["trailerUrls"]),
      similar: decodeTvBases(info["similar"]),
      sources: decodeSources(info["sources"]),
    );
  }

  static Future<void> cache(Show show) async {
    (await MediaCache.db).insert(
      _table,
      {
        "id": show.id,
        "title": show.title,
        "tmdb": show.tmdb,
        "state": show.state?.index,
        "image": show.imageName,
        "info": jsonEncode({
          "originalTitle": show.originalTitle,
          "years": show.years,
          "averageLength": show.averageLength,
          "episodes": show.episodes,
          "seasons": show.seasons,
          "genres": show.genres,
          "description": show.description,
          "creators": encodeCreators(show.creators),
          "cast": encodeCast(show.cast),
          "crew": encodeCrew(show.crew),
          "trailerUrls": show.trailerUrls,
          "similar": encodeTvBases(show.similar),
          "sources": encodeSources(show.sources),
        }),
        "timestamp": DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> setState(String id, MediaState? state) async {
    (await MediaCache.db).update(_table, {"state": state?.index},
        where: "id = ?", whereArgs: [id]);
  }
}

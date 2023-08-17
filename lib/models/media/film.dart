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

import 'dart:convert';
import 'package:discyo/api.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/models/media/medium.dart';
import 'package:discyo/utils.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:tmdb_dart/tmdb_dart.dart';

class Film extends Medium {
  final int tmdb;
  final String originalTitle;
  final int year;
  final List<Cast> cast;
  final List<Crew> crew;
  final int duration;
  final List<String> trailerUrls;
  final List<MovieBase> similar;

  Film(
    String id,
    String title,
    this.tmdb, {
    String? originalTitle,
    int? year,
    List<Cast>? cast,
    List<Crew>? crew,
    int? duration,
    List<String>? trailerUrls,
    List<MovieBase>? similar,
    MediaState? state,
    String? imageName,
    List<String>? genres,
    String? description,
    List<int>? friends,
    List<MediaSource>? sources,
  })  : originalTitle = originalTitle ?? "",
        year = year ?? 0,
        cast = cast ?? const [],
        crew = crew ?? const [],
        duration = duration ?? 0,
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

  String get headline => year > 0 && duration > 0 ? "$year • $length" : "";
  String get length => duration > 0 ? "$duration min" : "";
  String get release => year > 0 ? "$year" : "";

  @override
  String creator(DiscyoLocalizations localized) {
    try {
      return "${localized.label('directed_by')}\n${crew.firstWhere((c) => c.job == "Director").name}";
    } catch (e) {
      return localized.label("unknown_director");
    }
  }

  @override
  void setState(MediaState? newState) {
    super.setState(newState);
    FilmCache.setState(id, newState);
  }

  static Future<Film> fetch(String id, int tmdb,
      {String language = "en", MediaState? state}) async {
    // First check cache, if it's not there, fetch it
    Film? cached = await FilmCache.retrieve(id);
    if (cached != null) return cached;
    return fetchTMDB(id, tmdb, language: language, state: state);
  }

  static Future<Film> fetchTMDB(String id, int tmdb,
      {String language = "en", MediaState? state}) async {
    // Fetch film from TMDB
    TmdbApiWrapper.service.configuration = TmdbApiWrapper.configuration;
    Film film = await fromTMDB(
      id,
      state,
      await TmdbApiWrapper.service.movie.getDetails(
        tmdb,
        language: language,
        appendSettings: AppendSettings(
          includeImages: true,
          includeCredits: true,
          includeVideos: true,
          includeRecommendations: true,
        ),
      ),
    );

    // Cache it
    FilmCache.cache(film);
    return film;
  }

  static Future<Film> fromTMDB(
      String id, MediaState? state, Movie movie) async {
    List<String>? genres;
    try {
      genres = movie.genres.map((e) => e.name).toList(growable: false);
    } catch (e) {}

    String? description = movie.overview;
    if (description == null || description == "") {
      final en = await TmdbApiWrapper.service.movie.getDetails(movie.id);
      description = en.overview;
    }

    List<String> trailerUrls = await getLocalizedTrailerUrls(
      movie.videos,
      () => TmdbApiWrapper.service.movie.getVideos(movie.id),
    );

    List<MediaSource> sources = [];
    final response = await WapitchApi.getMovieProviders(id);
    if (response.code == 200) {
      sources = decodeSources(jsonEncode(response.body["providers"]));
    }

    return Film(
      id,
      movie.title,
      movie.id,
      state: state,
      imageName: TmdbApiWrapper.imageName(movie.posterPath),
      originalTitle: movie.originalTitle,
      year: movie.releaseDate?.year,
      duration: movie.runtime,
      genres: genres,
      description: description,
      cast: movie.credits?.cast,
      crew: movie.credits?.crew,
      trailerUrls: trailerUrls,
      similar: movie.recommendations,
      sources: sources,
    );
  }
}

class FilmCache {
  static final String _table = "film";

  static Future<Film?> retrieve(String id) async {
    Map<String, dynamic>? record;
    try {
      record = (await (await MediaCache.db)
          .query(_table, where: "id = ?", whereArgs: [id]))[0];
    } catch (e) {}
    if (record == null) return null;

    Map<String, dynamic> info = jsonDecode(record["info"]);
    return Film(
      id,
      record["title"],
      record["tmdb"],
      state: MediaStateExtension.fromIndex(record["state"]),
      imageName: record["image"],
      originalTitle: info["originalTitle"] ?? null,
      year: info["year"] ?? null,
      duration: info["duration"] ?? null,
      genres: castToListSafely<String>(info["genres"]),
      description: info["description"] ?? null,
      cast: decodeCast(info["cast"]),
      crew: decodeCrew(info["crew"]),
      trailerUrls: castToListSafely<String>(info["trailerUrls"]),
      similar: decodeMovieBases(info["similar"]),
      sources: decodeSources(info["sources"]),
    );
  }

  static Future<void> cache(Film film) async {
    (await MediaCache.db).insert(
      _table,
      {
        "id": film.id,
        "title": film.title,
        "tmdb": film.tmdb,
        "state": film.state?.index,
        "image": film.imageName,
        "info": jsonEncode({
          "originalTitle": film.originalTitle,
          "year": film.year,
          "duration": film.duration,
          "genres": film.genres,
          "description": film.description,
          "cast": encodeCast(film.cast),
          "crew": encodeCrew(film.crew),
          "trailerUrls": film.trailerUrls,
          "similar": encodeMovieBases(film.similar),
          "sources": encodeSources(film.sources),
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

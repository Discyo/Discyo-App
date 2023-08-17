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

import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:discyo/api.dart';
import 'package:discyo/models/media.dart';
import 'package:discyo/models/user.dart';

class RecommenderModel extends ChangeNotifier {
  UserModel _user;
  Map<Type, _Recommendations> _recommendations =
      new Map<Type, _Recommendations>();
  Type _mediaType = Film;
  bool _disposed = false;

  RecommenderModel(this._user) {
    reinit();
    _user.reloadRecommendations = reinit;
  }

  Type get mediaType => _mediaType;
  int get length => _recommendations[_mediaType]?.length ?? 0;
  Medium get current => _recommendations[_mediaType]!.current;
  Medium get next => _recommendations[_mediaType]!.next;
  bool get canRewind => _recommendations[_mediaType]?.canRewind ?? false;
  bool get needsInit => _recommendations[_mediaType]?.needsInit ?? false;

  void reinit() async {
    _recommendations[Film] = new _Recommendations<Film>(_user, notifyListeners);
    _recommendations[Show] = new _Recommendations<Show>(_user, notifyListeners);
  }

  void advance() async {
    _recommendations[_mediaType]?.advance();
  }

  MediaState? rewind() {
    return _recommendations[_mediaType]?.rewind();
  }

  void reload() {
    _recommendations[_mediaType]?.reload();
  }

  void toggle(Type type) {
    if (_mediaType == type) return;
    _mediaType = type;
    notifyListeners();
  }

  void setMediaState(MediaState state) {
    _user.setMediaState(current, state);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
}

class _Recommendations<T extends Medium> {
  UserModel _user;
  Function _notifyListeners;
  Set<String> _knownIds = new Set<String>();
  Queue<Map> _recommended = new Queue<Map>();
  Queue<T> _ready = new Queue<T>();
  T? _previous;
  bool _needsInit = false, _fetching = false, _loading = false;

  int get length => _ready.length;
  T get current => _ready.elementAt(0);
  T get next => _ready.elementAt(1);
  bool get canRewind => _previous != null;
  bool get needsInit => _needsInit;

  _Recommendations(this._user, this._notifyListeners) {
    reload();
  }

  void _fetch() async {
    if (_fetching) return;
    _fetching = true;

    var response = await DiscyoApi.recommendations(T, _user.token);
    if (response.code != 200) {
      await _user.refreshTokens();
      response = await DiscyoApi.recommendations(T, _user.token);
      if (response.code != 200) {
        DiscyoApi.error(
          this.runtimeType.toString(),
          "Could not fetch ${T.toString()} recommendations! (Code ${response.code})",
        );
        _fetching = false;
        return;
      }
    }

    // Empty list means initialization hasn't been done yet
    if (response.body.isEmpty) {
      _needsInit = true;
      _notifyListeners();
      _fetching = false;
      return;
    }

    response.body.forEach((e) {
      if (_knownIds.add(e["id"])) _recommended.add(e);
    });
    _load();
    _notifyListeners();
    _fetching = false;
  }

  void _load() async {
    if (_loading) return;
    _loading = true;

    while (_recommended.isNotEmpty) {
      Map toLoad = _recommended.removeFirst();
      if (T == Film)
        _ready.add((await Film.fetch(
          toLoad["id"],
          toLoad["tmdb_id"],
          language: _user.language,
        )) as T);
      if (T == Show)
        _ready.add((await Show.fetch(
          toLoad["id"],
          toLoad["tmdb_id"],
          language: _user.language,
        )) as T);
      _notifyListeners();
    }

    _loading = false;
  }

  void advance() {
    _knownIds.remove(_previous?.id);
    _previous = _ready.removeFirst();
    _notifyListeners();
    if (_recommended.length + _ready.length < 5) {
      _fetch();
    }
  }

  MediaState? rewind() {
    if (_previous == null) return null;
    _ready.addFirst(_previous!);
    _previous = null;
    _notifyListeners();
    return current.state;
  }

  void reload() {
    _needsInit = false;
    _notifyListeners();
    _fetch();
  }
}

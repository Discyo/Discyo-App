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
import 'package:discyo/components/icons.dart';
import 'package:discyo/models/media.dart';
import 'package:flutter/material.dart';

class FilteredListLoader extends ChangeNotifier {
  final Future<List> Function(int) _getList;
  List<MediaFilter> filters;
  List<Medium> _allItems = [];
  List<Medium> items = [];
  int? total;
  bool loading = false;

  FilteredListLoader(this._getList, this.filters) {
    load();
  }

  Future<void> load() async {
    if (total != null && _allItems.length >= total! || loading) return;
    loading = true;
    final List l = await _getList(_allItems.length ~/ DiscyoApi.pageLength);
    total = l[0];
    List<Medium> newItems = [];
    for (final item in l[1]) {
      newItems.add(await item);
    }
    _allItems.addAll(newItems);
    items.addAll(filter(newItems));
    notifyListeners();
    loading = false;
  }

  void reload() {
    _allItems.clear();
    items.clear();
    total = null;
    load();
  }

  bool get canLoadMore => total == null || _allItems.length < total!;

  void toggle(int filterIndex, dynamic option) {
    filters[filterIndex].toggle(option);
    items = filter(_allItems);
    notifyListeners();
  }

  List<Medium> filter(List<Medium> list) {
    return list.where((e) => filters.every((f) => f.check(e))).toList();
  }
}

abstract class MediaFilter {
  bool check(Medium medium);
  Widget? label(dynamic option);
  bool state(dynamic option);
  void toggle(dynamic option);
  List get options;
}

class TypeFilter extends MediaFilter {
  // only currently supported types
  static List<Type> get _options => [Film, Show];
  Set<Type> _types = _options.toSet();

  @override
  bool check(Medium medium) {
    return _types.contains(medium.runtimeType);
  }

  bool _validOption(dynamic option) {
    if (_options.contains(option)) return true;
    DiscyoApi.error(
      "TypeFilter",
      "Received unexpected option $option.",
    );
    return false;
  }

  @override
  Widget? label(option) {
    if (_validOption(option)) return Icon(DiscyoIcons.medium(option, false));
  }

  @override
  bool state(option) {
    if (!_validOption(option)) return false;
    return _types.contains(option);
  }

  @override
  void toggle(dynamic option) {
    if (!_validOption(option)) return;

    if (_types.contains(option))
      _types.remove(option);
    else
      _types.add(option);
  }

  @override
  List get options => _options;
}

class StateFilter extends MediaFilter {
  static List<MediaState> get _options => [
        MediaState.awesome,
        MediaState.good,
        MediaState.meh,
        MediaState.awful,
      ];
  Set<MediaState> _states = _options.toSet();

  @override
  bool check(Medium medium) {
    return _states.contains(medium.state);
  }

  bool _validOption(dynamic option) {
    if (_options.contains(option)) return true;
    DiscyoApi.error(
      "StateFilter",
      "Received unexpected option $option.",
    );
    return false;
  }

  @override
  Widget? label(option) {
    if (_validOption(option)) return Icon((option as MediaState).icon);
  }

  @override
  bool state(option) {
    if (!_validOption(option)) return false;
    return _states.contains(option);
  }

  @override
  void toggle(dynamic option) {
    if (!_validOption(option)) return;

    if (_states.contains(option))
      _states.remove(option);
    else
      _states.add(option);
  }

  @override
  List get options => _options;
}

class StreamingPlatformFilter extends MediaFilter {
  List<StreamingPlatform> _options; // need to be provided for this one
  Set<StreamingPlatform> _platforms = {};

  StreamingPlatformFilter(this._country, this._options);

  String? _country;

  @override
  bool check(Medium medium) {
    if (_platforms.isEmpty) return true;
    return medium.sources
        .where((s) => _country == null ? true : s.country == _country)
        .map<StreamingPlatform>((s) => s.platform)
        .any(_platforms.contains);
  }

  bool _validOption(dynamic option) {
    if (_options.contains(option)) return true;
    DiscyoApi.error(
      "StreamingPlatformFilter",
      "Received unexpected option $option.",
    );
    return false;
  }

  @override
  Widget? label(option) {
    if (_validOption(option))
      return Image(
        image: (option as StreamingPlatform).logo,
        height: 32,
        width: 32,
      );
  }

  @override
  bool state(option) {
    if (!_validOption(option)) return false;
    return _platforms.contains(option);
  }

  @override
  void toggle(dynamic option) {
    if (!_validOption(option)) return;

    if (_platforms.contains(option))
      _platforms.remove(option);
    else
      _platforms.add(option);
  }

  @override
  List get options => _options;
}

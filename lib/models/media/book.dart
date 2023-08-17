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

import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/models/media/medium.dart';

class Book extends Medium {
  final int year;
  final String author;
  final int pages;

  Book(
    String id,
    String title, {
    int? year,
    String? author,
    int? pages,
    MediaState? state,
    String? imageName,
    List<String>? genres,
    String? description,
    List<int>? friends,
    List<MediaSource>? sources,
  })  : year = year ?? 0,
        author = author ?? "Unknown Author",
        pages = pages ?? 0,
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

  String get headline => year > 0 && pages > 0 ? "$year • $length" : "";
  String get length => pages > 0 ? "$pages pages" : "";
  String get release => year > 0 ? "$year" : "";

  @override
  String creator(DiscyoLocalizations localized) => author;
}

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

import 'package:discyo/models/media/film.dart';
import 'package:discyo/models/media/show.dart';
import 'package:discyo/models/media/album.dart';
import 'package:discyo/models/media/podcast.dart';
import 'package:discyo/models/media/book.dart';
import 'package:discyo/models/media/game.dart';
export 'package:discyo/models/media/medium.dart';
export 'package:discyo/models/media/film.dart';
export 'package:discyo/models/media/show.dart';
export 'package:discyo/models/media/album.dart';
export 'package:discyo/models/media/podcast.dart';
export 'package:discyo/models/media/book.dart';
export 'package:discyo/models/media/game.dart';

const List<Type> mediaTypes = [Film, Show, Album, Podcast, Book, Game];

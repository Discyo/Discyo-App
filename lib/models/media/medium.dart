import 'package:cached_network_image/cached_network_image.dart';
import 'package:discyo/api.dart';
import 'package:discyo/components/icons.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

enum MediaState { awful, meh, good, awesome, saved, dismissed }

extension MediaStateExtension on MediaState {
  // non-existent index 6 in case of null returns null
  static MediaState? fromIndex(int? index) =>
      index != null ? MediaState.values[index] : null;

  static MediaState? fromName(String? name) {
    switch (name) {
      case "awful":
        return MediaState.awful;
      case "meh":
        return MediaState.meh;
      case "good":
        return MediaState.good;
      case "amazing":
        return MediaState.awesome;
      case "into":
        return MediaState.saved;
      case "non_into":
        return MediaState.dismissed;
      default:
        return null;
    }
  }

  String get name {
    switch (this) {
      case MediaState.awful:
        return "awful";
      case MediaState.meh:
        return "meh";
      case MediaState.good:
        return "good";
      case MediaState.awesome:
        return "amazing";
      case MediaState.saved:
        return "into";
      case MediaState.dismissed:
        return "non_into";
    }
  }

  IconData get icon {
    switch (this) {
      case MediaState.awful:
        return DiscyoIcons.awful;
      case MediaState.meh:
        return DiscyoIcons.meh;
      case MediaState.good:
        return DiscyoIcons.good;
      case MediaState.awesome:
        return DiscyoIcons.awesome;
      case MediaState.saved:
        return DiscyoIcons.save;
      case MediaState.dismissed:
        return DiscyoIcons.dismiss;
    }
  }

  bool isResultOfAction(MediaAction? action) {
    switch (this) {
      case MediaState.awful:
        return action == MediaAction.rateAwful;
      case MediaState.meh:
        return action == MediaAction.rateMeh;
      case MediaState.good:
        return action == MediaAction.rateGood;
      case MediaState.awesome:
        return action == MediaAction.rateAwesome;
      case MediaState.saved:
        return action == MediaAction.save;
      case MediaState.dismissed:
        return action == MediaAction.dismiss;
    }
  }
}

enum MediaAction {
  rate,
  rateAwful,
  rateMeh,
  rateGood,
  rateAwesome,
  dismiss,
  save,
  rewind,
  share
}

extension MediaActionExtension on MediaAction {
  IconData get icon {
    switch (this) {
      case MediaAction.rate:
        return DiscyoIcons.rate;
      case MediaAction.rateAwful:
        return DiscyoIcons.awful;
      case MediaAction.rateMeh:
        return DiscyoIcons.meh;
      case MediaAction.rateGood:
        return DiscyoIcons.good;
      case MediaAction.rateAwesome:
        return DiscyoIcons.awesome;
      case MediaAction.dismiss:
        return DiscyoIcons.dismiss;
      case MediaAction.save:
        return DiscyoIcons.save;
      case MediaAction.rewind:
        return DiscyoIcons.rewind;
      case MediaAction.share:
        return DiscyoIcons.share;
    }
  }
}

enum StreamingPlatform {
  netflix,
  amazonPrime,
  hulu,
  hboGo,
  hboMax,
  appleTvPlus,
  disneyPlus,
  applePodcasts,
  spotify
}

extension StreamingPlatformExtension on StreamingPlatform {
  static StreamingPlatform? fromId(String? id) {
    switch (id) {
      case "903ca85c-2870-49eb-a85f-1120e2a90936":
        return StreamingPlatform.netflix;
      case "24a0eecd-82a0-4a94-8f1d-1397fb483b5c":
        return StreamingPlatform.amazonPrime;
      case "a8e376ea-8411-4c1d-af8a-56ff4a2e53ee":
        return StreamingPlatform.hulu;
      case "5257a35e-6e53-4ee3-9147-de093c4164e8":
        return StreamingPlatform.hboGo;
      case "eac11c84-03d7-42f4-8e15-f65aad2c8251":
        return StreamingPlatform.hboMax;
      case "f81a9637-c979-45da-b824-0c4181246556":
        return StreamingPlatform.appleTvPlus;
      case "59d0904b-b375-4ee9-bcfb-52713a4b8d4a":
        return StreamingPlatform.disneyPlus;
      case "a3954ab3-9568-4f76-a187-28e74095811e":
        return StreamingPlatform.applePodcasts;
      case "482f3feb-67c0-490e-84ad-0faa573af6bd":
        return StreamingPlatform.spotify;
      default:
        return null;
    }
  }

  String get id {
    switch (this) {
      case StreamingPlatform.netflix:
        return "903ca85c-2870-49eb-a85f-1120e2a90936";
      case StreamingPlatform.amazonPrime:
        return "24a0eecd-82a0-4a94-8f1d-1397fb483b5c";
      case StreamingPlatform.hulu:
        return "a8e376ea-8411-4c1d-af8a-56ff4a2e53ee";
      case StreamingPlatform.hboGo:
        return "5257a35e-6e53-4ee3-9147-de093c4164e8";
      case StreamingPlatform.hboMax:
        return "eac11c84-03d7-42f4-8e15-f65aad2c8251";
      case StreamingPlatform.appleTvPlus:
        return "f81a9637-c979-45da-b824-0c4181246556";
      case StreamingPlatform.disneyPlus:
        return "59d0904b-b375-4ee9-bcfb-52713a4b8d4a";
      case StreamingPlatform.applePodcasts:
        return "a3954ab3-9568-4f76-a187-28e74095811e";
      case StreamingPlatform.spotify:
        return "482f3feb-67c0-490e-84ad-0faa573af6bd";
    }
  }

  String get name {
    switch (this) {
      case StreamingPlatform.netflix:
        return "Netflix";
      case StreamingPlatform.amazonPrime:
        return "Amazon Prime";
      case StreamingPlatform.hulu:
        return "Hulu";
      case StreamingPlatform.hboGo:
        return "HBO Go";
      case StreamingPlatform.hboMax:
        return "HBO Max";
      case StreamingPlatform.appleTvPlus:
        return "Apple TV Plus";
      case StreamingPlatform.disneyPlus:
        return "Disney Plus";
      case StreamingPlatform.applePodcasts:
        return "Apple Podcasts";
      case StreamingPlatform.spotify:
        return "Spotify";
    }
  }

  ImageProvider get logo {
    switch (this) {
      case StreamingPlatform.netflix:
        return AssetImage("assets/other/netflix.png");
      case StreamingPlatform.amazonPrime:
        return AssetImage("assets/other/prime.png");
      case StreamingPlatform.hulu:
        return AssetImage("assets/other/hulu.png");
      case StreamingPlatform.hboGo:
        return AssetImage("assets/other/hbogo.png");
      case StreamingPlatform.hboMax:
        return AssetImage("assets/other/hbomax.png");
      case StreamingPlatform.appleTvPlus:
        return AssetImage("assets/other/appletv.png");
      case StreamingPlatform.disneyPlus:
        return AssetImage("assets/other/disney.png");
      case StreamingPlatform.applePodcasts:
        return AssetImage("assets/other/applepodcasts.png");
      case StreamingPlatform.spotify:
        return AssetImage("assets/other/spotify.png");
    }
  }
}

class MediaSource {
  final StreamingPlatform platform;
  final String country;
  final String url;

  MediaSource(this.platform, this.country, this.url);
}

abstract class Medium {
  final String id;
  final String title;
  MediaState? state;
  bool dirty = false;
  final String? imageName;
  final Future<List<Color>> colors;
  final List<String> genres;
  final String description;
  final List<int> friends;
  final List<MediaSource> sources;

  static ImageProvider _getThumbnailProvider(String? name) {
    if (name == null)
      return AssetImage("assets/other/missing_thumbnail.png");
    else
      return CachedNetworkImageProvider(TmdbApiWrapper.thumbnailUrl(name));
  }

  Medium(
    this.id,
    this.title, {
    MediaState? state,
    String? imageName,
    List<String>? genres,
    String? description,
    List<int>? friends,
    List<MediaSource>? sources,
  })  : state = state,
        imageName = imageName,
        genres = genres ?? const [],
        description = description ?? "",
        friends = friends ?? [],
        sources = sources ?? [],
        colors =
            PaletteBackground.extractGradient(_getThumbnailProvider(imageName));

  String get headline;
  String get length;
  String get release;
  String get genre => genres.isNotEmpty ? genres[0] : "";
  ImageProvider get thumbnailProvider => _getThumbnailProvider(imageName);

  String creator(DiscyoLocalizations localized);
  void setState(MediaState? newState) {
    state = newState;
    dirty = true;
  }

  Widget getImage({BoxFit? fit, BlendMode? colorBlendMode, Color? color}) {
    if (imageName == null)
      return Image.asset(
        "assets/other/missing_image.png",
        fit: fit,
        colorBlendMode: colorBlendMode,
        color: color,
      );
    return CachedNetworkImage(
      imageUrl: TmdbApiWrapper.imageUrl(imageName!),
      placeholder: (c, u) =>
          getThumbnail(fit: fit, colorBlendMode: colorBlendMode, color: color),
      fadeOutDuration: const Duration(),
      fadeInDuration: const Duration(),
      fit: fit,
      colorBlendMode: colorBlendMode,
      color: color,
    );
  }

  Widget getThumbnail({BoxFit? fit, BlendMode? colorBlendMode, Color? color}) {
    if (imageName == null)
      return Image.asset(
        "assets/other/missing_thumbnail.png",
        fit: fit,
        colorBlendMode: colorBlendMode,
        color: color,
      );
    return CachedNetworkImage(
      imageUrl: TmdbApiWrapper.thumbnailUrl(imageName!),
      fit: fit,
      colorBlendMode: colorBlendMode,
      color: color,
    );
  }

  Future<List<int>?> getRatings() async {
    final response = await DiscyoApi.getRatings(id);
    if (response.code != 200) return null;
    return [
      response.body["awful"],
      response.body["meh"],
      response.body["good"],
      response.body["amazing"],
    ];
  }
}

class MediaCache {
  static Future<Database> _db = _openDb();
  static DateTime? _purgeTime;
  static final Map<String, String> _tables = {
    "film": "id TEXT PRIMARY KEY, "
        "title TEXT, "
        "tmdb INTEGER, "
        "state INTEGER, "
        "image TEXT, "
        "info TEXT, "
        "timestamp TEXT",
    "show": "id TEXT PRIMARY KEY, "
        "title TEXT, "
        "tmdb INTEGER, "
        "state INTEGER, "
        "image TEXT, "
        "info TEXT, "
        "timestamp TEXT",
  };

  static Future<Database> _openDb() async {
    return await openDatabase(
      join(await getDatabasesPath(), "cache.db"),
      version: 10,
      onUpgrade: (db, ov, nv) async {
        // On upgrade we need to drop all tables and create new ones
        final batch = db.batch();
        _tables.forEach((table, columns) {
          batch.execute("DROP TABLE IF EXISTS $table");
          batch.execute("CREATE TABLE IF NOT EXISTS $table($columns)");
        });
        await batch.commit();
      },
    );
  }

  static Future<Database> get db async {
    Database db = await _db;

    // Purge old cache if needed
    if (_purgeTime?.isBefore(DateTime.now().subtract(Duration(hours: 4))) ??
        true) {
      final batch = db.batch();
      for (final t in _tables.keys) {
        List<Map<String, dynamic>> records =
            await db.query(t, columns: ["id", "timestamp"]);
        for (final r in records) {
          if (DateTime.parse(r["timestamp"])
              .isBefore(DateTime.now().subtract(Duration(days: 7))))
            batch.delete(t, where: "id = ?", whereArgs: [r["id"]]);
        }
      }
      await batch.commit(noResult: true);
      _purgeTime = DateTime.now();
    }

    return db;
  }

  static Future<void> clear() async {
    // Go through all the records and delete them
    final batch = (await _db).batch();
    for (final t in _tables.keys) batch.delete(t);
    await batch.commit(noResult: true);
  }
}

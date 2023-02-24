import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/models/media/medium.dart';

class Album extends Medium {
  final int year;
  final List<String> artists;
  final int duration;
  final int songs;
  final List<String> videoUrls;

  Album(
    String id,
    String title, {
    int? year,
    List<String>? artists,
    int? duration,
    int? songs,
    List<String>? videoUrls,
    MediaState? state,
    String? imageName,
    List<String>? genres,
    String? description,
    List<int>? friends,
    List<MediaSource>? sources,
  })  : year = year ?? 0,
        artists = artists ?? const ["Unknown Artist"],
        duration = duration ?? 0,
        songs = songs ?? 0,
        videoUrls = videoUrls ?? [],
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
  String creator(DiscyoLocalizations localized) => artists[0];
}

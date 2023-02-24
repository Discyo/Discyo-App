import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/models/media/medium.dart';

class Game extends Medium {
  final int year;
  final List<String> developers;
  final List<String> platforms;
  final List<String> trailerUrls;

  Game(
    String id,
    String title, {
    int? year,
    List<String>? developers,
    List<String>? platforms,
    List<String>? trailerUrls,
    MediaState? state,
    String? imageName,
    List<String>? genres,
    String? description,
    List<int>? friends,
    List<MediaSource>? sources,
  })  : year = year ?? 0,
        developers = developers ?? const ["Unknown Developer"],
        platforms = platforms ?? const [],
        trailerUrls = trailerUrls ?? const [],
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
      year > 0 && genres.length > 0 ? "$year • ${genres[0]}" : "";
  String get length => "";
  String get release => year > 0 ? "$year" : "";

  @override
  String creator(DiscyoLocalizations localized) => "${localized.label('developed_by')}\n${developers[0]}";
}

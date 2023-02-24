import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/models/media/medium.dart';

class Podcast extends Medium {
  final List<int> years;
  final List<String> moderators;
  final int averageLength;
  final int episodes;
  final String frequency;

  Podcast(
    String id,
    String title, {
    List<int>? years,
    List<String>? moderators,
    int? averageLength,
    int? episodes,
    String? frequency,
    MediaState? state,
    String? imageName,
    List<String>? genres,
    String? description,
    List<int>? friends,
    List<MediaSource>? sources,
  })  : years = years ?? const [],
        moderators = moderators ?? const [],
        averageLength = averageLength ?? 0,
        episodes = episodes ?? 0,
        frequency = frequency ?? "",
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
    if (years.length < 1)
      return "";
    else if (years.length < 2)
      return "${years[0]} - ";
    else
      return "${years[0]} - ${years[1]}";
  }

  @override
  String creator(DiscyoLocalizations localized) => genres.length > 0 ? "${genres[0]}" : "";
}

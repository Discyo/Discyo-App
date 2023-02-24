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

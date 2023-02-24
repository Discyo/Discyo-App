import 'package:flutter/widgets.dart';
import 'package:discyo/models/media.dart';

class DiscyoIcons {
  DiscyoIcons._();

  static const _kFontFam = 'DiscyoIcons';
  static const _kFontPkg = null;

  static const IconData book_fill = IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData book_stroke = IconData(0xe801, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData change_my_mind = IconData(0xe802, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData diary = IconData(0xe803, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData discover_later = IconData(0xe804, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData discover = IconData(0xe805, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData dislike = IconData(0xe806, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData dismiss = IconData(0xe807, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData film_fill = IconData(0xe808, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData film_stroke = IconData(0xe809, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData friends = IconData(0xe80a, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData game_fill = IconData(0xe80b, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData game_stroke = IconData(0xe80c, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData like = IconData(0xe80d, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData menu = IconData(0xe80e, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData music_fill = IconData(0xe80f, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData music_stroke = IconData(0xe810, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData play = IconData(0xe811, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData podcast_fill = IconData(0xe812, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData podcast_stroke = IconData(0xe813, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData save = IconData(0xe814, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData search = IconData(0xe815, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData share = IconData(0xe816, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData show_fill = IconData(0xe817, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData awesome = IconData(0xe818, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData awful = IconData(0xe819, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData good = IconData(0xe81a, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData meh = IconData(0xe81b, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData show_stroke = IconData(0xe81c, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData rate = IconData(0xe81d, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData rewind = IconData(0xe81e, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData apple = IconData(0xe81f, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData facebook = IconData(0xe820, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData google = IconData(0xe821, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  static IconData? medium(Type m, bool fill) {
    if (m == Film)
      return fill ? film_fill : film_stroke;
    if (m == Show)
      return fill ? show_fill : show_stroke;
    if (m == Album)
      return fill ? music_fill : music_stroke;
    if (m == Podcast)
      return fill ? podcast_fill : podcast_stroke;
    if (m == Book)
      return fill ? book_fill : book_stroke;
    if (m == Game)
      return fill ? game_fill : game_stroke;
    return null;
  }
}

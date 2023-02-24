import 'package:flutter/material.dart';
import 'package:discyo/localizations/localization.dart';
import 'package:discyo/localizations/cs.dart';
import 'package:discyo/localizations/en.dart';

class DiscyoLocalizations {
  DiscyoLocalizations(this.locale);

  static const LocalizationsDelegate<DiscyoLocalizations> delegate =
      _DiscyoLocalizationsDelegate();

  final Locale locale;

  static DiscyoLocalizations of(BuildContext context) {
    return Localizations.of<DiscyoLocalizations>(
            context, DiscyoLocalizations) ??
        DiscyoLocalizations(Locale("en"));
  }

  static Map<String, DiscyoLocalization> _localizations = {
    "cs": DiscyoLocalizationCs(),
    "en": DiscyoLocalizationEn(),
  };

  String error(String key) {
    return _localizations[locale.languageCode]?.errors[key] ?? key;
  }

  String label(String key) {
    return _localizations[locale.languageCode]?.labels[key] ?? key;
  }

  RichText? document(String key) {
    return _localizations[locale.languageCode]?.documents[key];
  }
}

class _DiscyoLocalizationsDelegate
    extends LocalizationsDelegate<DiscyoLocalizations> {
  const _DiscyoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ["cs", "en"].contains(locale.languageCode);

  @override
  Future<DiscyoLocalizations> load(Locale locale) async {
    return DiscyoLocalizations(locale);
  }

  @override
  bool shouldReload(_DiscyoLocalizationsDelegate old) => false;
}

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

import 'package:flutter/material.dart';
import 'package:discyo/localizations/localization.dart';

class DiscyoLocalizationCs extends DiscyoLocalization {
  static Map<String, String> _errors = {
    "albums_unsupported": "Alba prozatím nejsou k dispozici.",
    "books_unsupported": "Knihy prozatím nejsou k dispozici.",
    "cant_update_profile": "Nelze uložit změny vašeho profilu. "
        "Zkuste to prosím později.",
    "code_incorrect": "Nesprávný kód pro obnovu. Prosím zkuste to znovu.",
    "unexpected": "Došlo k chybě, zkuste to prosím později.",
    "email_in_use": "Tento email je již používán",
    "empty_code": "Zadejte prosím kód, který jste dostali",
    "empty_dropdown": "Vyberte z možností",
    "empty_email": "Zadejte prosím svůj email",
    "empty_field": "Zadejte prosím",
    "empty_password": "Zadejte prosím své heslo",
    "empty_username": "Zadejte prosím své uživatelské jméno",
    "empty_username_or_email": "Zadejte své uživatelské jméno nebo email",
    "games_unsupported": "Hry prozatím nejsou k dispozici.",
    "friends_unsupported": "Přátelé prozatím nejsou k dispozici.",
    "invalid_email": "Neplatná emailová adresa",
    "invalid_password": "Heslo musí mít alespoň 6 znaků",
    "invalid_username_characters":
        "Uživatelské jméno může obsahovat pouze alfanumerické znaky, pomlčku nebo podtržítko",
    "invalid_username_length": "Uživatelské jméno musí mít 3-32 znaků",
    "login_incorrect": "Uživatelské jméno nebo heslo není správné!",
    "no_internet": "Bez připojení k internetu.\n"
        "Připojte se prosím a zkuste to znovu.",
    "not_in_db": "Toto ještě není v naší databázi, omlouváme se!",
    "password_mismatch": "Zadaná hesla se neshodují.",
    "password_incorrect": "Nesprávné heslo",
    "podcasts_unsupported": "Podcasty prozatím nejsou k dispozici.",
    "server_down": "Ale ne, na naší straně došlo k chybě.",
    "shows_unsupported": "Seriály prozatím nejsou k dispozici.",
    "username_in_use": "Toto uživatelské jméno již existuje.",
  };

  static Map<String, String> _labels = {
    "cancel": "ZRUŠIT",
    "cast": "Obsazení",
    "change_confidential": "Změnit uživatelské jméno nebo heslo",
    "change_my_mind": "Druhá šance",
    "change_password": "Změnit heslo",
    "change_profile_picture": "Změnit profilovou fotku",
    "choose": "Vyberte",
    "code": "Kód pro obnovu",
    "community_discord": "Komunitní Discord server",
    "confirm_delete_account_description":
        "Tato akce se nedá vrátit zpět. Napište \"Odstranit\" a stiskněte OK pro potvrzení.",
    "confirm_delete_account_string": "Odstranit",
    "confirm_delete_account_title": "Opravdu chcete odstranit účet?",
    "confirmation_resent_description":
        "Zkontroluj si emailovou schránku a potvrď svoji registraci. Pak se můžeš přihlásit.",
    "confirmation_resent_title": "Email pro potvrzení byl odeslán znovu.",
    "country": "země",
    "crew": "Štáb",
    "created_by": "Tvorba",
    "current_password": "Aktuální heslo",
    "delete_account": "Odstranit účet",
    "developed_by": "Vývojář",
    "diary": "Diář",
    "director": "Režisér",
    "directed_by": "Režie",
    "discover": "Objevovat",
    "discover_later": "Odloženo na později",
    "do_init": "Poznej mě",
    "edit_profile": "Upravit profil",
    "edit_account": "Upravit účet",
    "email": "Email",
    "email_not_confirmed":
        "Tvůj účet ještě nebyl ověřen. Zkontroluj svoji emailovou schránku a potvrď svoji registraci. Pak se můžeš přihlásit.",
    "executive_producer": "Výkonný Producent",
    "fans_also_like": "Lidem se také líbí",
    "favorites_title": "Oblíbené",
    "favorites_description":
        "Vyber si několik filmů nebo seriálů, které se ti líbí, abychom tě lépe poznali.",
    "feedback_placeholder": "Napište nám zpětnou vazbu",
    "feedback_title": "Jak jste spokojení s doporučeními?",
    "feedback_toast": "Jak jste spokojení s doporučeními? "
        "Napište nám co můžeme zlepšit.",
    "forgot_password": "Zapomenuté heslo",
    "friends": "Přátelé",
    "info_credit": "Informace získané z ",
    "language": "jazyk",
    "loading": "Načítání...",
    "log_movie_toast": "Viděli jste v poslední době nějaký film? "
        "Najděte a ohodnoťte ho v záložce Hledat.",
    "log_out": "Odhlásit se",
    "logging_in": "Přihlašování...",
    "login": "Přihlásit se",
    "login_apple": "Přihlásit se přes Apple",
    "login_email": "Nebo se přihlašte přes email",
    "login_google": "Přihlásit se přes Google",
    "missing_info_title": "Prosím vyplňte chybějící informace o vás",
    "name": "Jméno",
    "needs_init":
        "Před tím než ti něco můžeme doporučit,\ntě musíme poznat blíže.",
    "new_password": "Nové heslo",
    "new_password_again": "Zopakuj nové heslo",
    "not_enough_ratings": "Nedostatek hodnocení",
    "ok": "OK",
    "onboarding_finish": "To je vše!\nPojďme se do toho pustit...",
    "onboarding_gestures": "Pojďte si vyzkoušet gesta",
    "onboarding_rate": "Tlačítkem s hvězdičkou ohodnoťte.",
    "onboarding_ratings": "(Hodnocení v tutoriálu se neukládají)",
    "onboarding_rewind": "Tlačítkem zpět vrátíte poslední akci.",
    "onboarding_selectors":
        "V horní nabídce přepínáte\nmezi médii. Zkuste si to!",
    "onboarding_swipe_left": "Tažením doleva zahoďte.",
    "onboarding_swipe_right": "Tažením doprava uložte.",
    "onboarding_welcome": "Vítejte v Discyo",
    "password": "Heslo",
    "password_changed": "Heslo úspěšně změneno!",
    "platforms": "Filtr streamovacích služeb",
    "platforms_title": "Streamovací služby",
    "platforms_description":
        "Pokud chcete dostávat primárně doporučení obsahu dostupného na specifických streamovacích službách, vyberte si je níže. Jinak vám budeme doporučovat obsah nezávisle na streamovacích službách. Výběr můžete kdykoli změnit v nastavení.",
    "privacy_policy": "Zásady ochrany osobních údajů",
    "rate": "OHODNOTIT",
    "register": "Registrace",
    "register_acknowledge_1": "Registrací souhlasíte s našimi ",
    "register_acknowledge_2": "smluvními podmínkami",
    "register_acknowledge_3": " a ",
    "register_acknowledge_4": "zásadami ochrany osobních údajů",
    "register_acknowledge_5": ".",
    "register_apple": "Registrace přes Apple",
    "register_email": "Registrace přes email",
    "register_google": "Registrace přes Google",
    "report_problem_placeholder": "Popište problém",
    "report_problem_title": "Nahlásit problém",
    "resend_email": "Poslat email znovu",
    "resend_email_question": "Nepřišel ti email?",
    "successful_registration_title": "Úspěšná registrace!",
    "successful_registration_description":
        "Zkontroluj si emailovou schránku a potvrď svoji registraci. Pak se můžeš přihlásit.",
    "repeated": "Zopakovat",
    "reset_successful": "Heslo úspěšně změneno. Teď se můžete přihlásit.",
    "saving": "Ukládání...",
    "search": "Hledat",
    "search_bar": "Na co se dnes cítíte?",
    "send": "ODESLAT",
    "sending_init": "Poznáváme vás...",
    "show_more": "Zobrazit\nvíce",
    "skip": "PŘESKOČIT",
    "submit": "Odeslat",
    "terms_and_conditions": "Všeobecné obchodní podmínky",
    "thanks_for_feedback": "Děkujeme za zpětnou vazbu!",
    "trailer": "Trailer",
    "unknown_creator": "Neznámý tvůrce",
    "unknown_director": "Neznámý režisér",
    "username": "Uživatelské jméno",
    "username_or_email": "Uživatelské jméno nebo email",
    "video": "Video",
    "watch_on": "Shlédněte na",
    "yourself": "Profil",
  };

  static Map<String, RichText> _documents = {
    "privacy_policy": RichText(
      text: TextSpan(
        text: "TODO",
        style: const TextStyle(fontSize: 12),
      ),
    ),
    "terms_and_conditions": RichText(
      text: TextSpan(
        text: "TODO",
        style: const TextStyle(fontSize: 12),
      ),
    ),
  };

  Map<String, String> get errors => _errors;
  Map<String, String> get labels => _labels;
  Map<String, RichText> get documents => _documents;
}

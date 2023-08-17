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

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:discyo/api.dart';
import 'package:discyo/components/icons.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/components/panel.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/models/user.dart';
import 'package:discyo/pages.dart';
import 'package:discyo/utils.dart';

void main() => runApp(DiscyoApp());

class DiscyoApp extends StatelessWidget {
  Widget buildLogin(UserModel user) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Panel(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: {
            "/": (BuildContext _) => WelcomePage(
                  registerGoogle: DiscyoApi.loginGoogle,
                  registerApple: user.loginWithApple,
                ),
            "/email_unconfirmed": (BuildContext _) => EmailUnconfirmedPage(),
            "/login": (BuildContext _) => LoginPage(
                  loginEmail: user.loginUsingCredentails,
                  loginGoogle: DiscyoApi.loginGoogle,
                  loginApple: user.loginWithApple,
                ),
            "/forgot_password": (BuildContext _) => ForgotPasswordPage(),
            "/register_form": (BuildContext _) => RegisterFormPage(
                  dryRun: user.dryRegister,
                  register: user.register,
                ),
            "/register_confirm": (BuildContext _) => RegisterConfirmPage(),
          },
        ),
      ),
    );
  }

  Widget buildLoggingIn(BuildContext context) {
    return Scaffold(
      body: PaletteBackground(
        colors: PaletteBackground.loginColors,
        layout: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              Padding(padding: const EdgeInsets.symmetric(vertical: 8)),
              Text(
                DiscyoLocalizations.of(context).label("logging_in"),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOnboarding(void Function() onboardUser) {
    return Scaffold(body: OnboardingPage(onboardUser: onboardUser));
  }

  Widget buildMissingInfo(List<String> missingInfo, Function setInfo) {
    return Scaffold(
        body: MissingInfoPage(missingInfo: missingInfo, setInfo: setInfo));
  }

  Widget buildHome(BuildContext context, UserModel user) {
    final localized = DiscyoLocalizations.of(context);
    return PanelManager(
      panels: [
        Panel(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: {
            "/": (BuildContext _) => DiscoverPage(),
            "/init_favorites": (BuildContext _) => InitFavoritesPage(),
            "/init_providers": (BuildContext _) => InitProvidersPage(),
            "/details": (BuildContext _) => DetailsPage(),
            "/creators": (BuildContext _) => CreatorsPage(),
          },
        ),
        Panel(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: {
            "/": (BuildContext _) => SearchPage(),
            "/details": (BuildContext _) => DetailsPage(),
            "/creators": (BuildContext _) => CreatorsPage(),
          },
        ),
        Panel(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: {
            "/": (BuildContext _) => YourselfPage(),
            "/edit_account": (BuildContext _) => EditAccountPage(),
            "/list": (BuildContext _) => ListPage(),
            "/details": (BuildContext _) => DetailsPage(),
            "/creators": (BuildContext _) => CreatorsPage(),
          },
        ),
      ],
      titles: [
        localized.label("discover"),
        localized.label("search"),
        localized.label("yourself"),
      ],
      icons: [
        DiscyoIcons.discover,
        DiscyoIcons.search,
        user.image,
      ],
    );
  }

  Widget buildSplashScreen() {
    return Container(
      color: Color(0xff15161a),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 128, height: 112),
          SizedBox(
            child: Image.asset("assets/other/splash_discyo.png"),
            width: 146,
            height: 146,
          ),
          SizedBox(
            child: Image.asset("assets/other/splash_currant.png"),
            width: 128,
            height: 112,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Discyo",
      home: ConnectionChecker(
        builder: (context) {
          return FutureBuilder(
            future: UserModel.fromSharedPreferences(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ChangeNotifierProvider<UserModel>(
                  create: (_) => (snapshot.data as UserModel),
                  child: Consumer<UserModel>(
                    builder: (context, user, child) {
                      return ChangeNotifierProvider<UniLinker>(
                        create: (_) => UniLinker(),
                        child: Consumer<UniLinker>(
                          builder: (context, uni, child) {
                            if (uni.hasRefreshToken) {
                              user.loginUsingRefreshToken(uni.refreshToken);
                              return buildLoggingIn(
                                context,
                              );
                            }

                            if (!user.authenticated) return buildLogin(user);
                            if (!user.onboarded)
                              return buildOnboarding(user.onboard);
                            final missingInfo = user.getMissingInfo();
                            if (missingInfo.isNotEmpty)
                              return buildMissingInfo(
                                  missingInfo, user.setInfo);
                            return buildHome(context, user);
                          },
                        ),
                      );
                    },
                  ),
                );
              }
              return buildSplashScreen();
            },
          );
        },
        placeholder: buildSplashScreen(),
      ),
      localizationsDelegates: [
        DiscyoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("en", ""),
        const Locale("cs", ""),
      ],
      theme: ThemeData.from(
        colorScheme: ColorScheme.highContrastDark(
          primary: Colors.white,
          secondary: Colors.white,
        ),
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 32, fontWeight: FontWeight.w300),
          headline2: TextStyle(fontSize: 28, fontWeight: FontWeight.w300),
          headline3: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
          headline4: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          headline5: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
          headline6: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          subtitle1: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
          subtitle2: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          bodyText1: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          bodyText2: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          caption: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
        ),
      ).copyWith(
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

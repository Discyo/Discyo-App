import 'dart:io';
import 'package:discyo/api.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/models/media.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel extends ChangeNotifier {
  String? _access;
  String? _refresh;
  String? _email;
  String? _username;
  String? _name;
  String? _country;
  List<String> _languages = [];
  Set<StreamingPlatform> _subscribedPlatforms = {};
  Set<StreamingPlatform> _availablePlatforms = {};
  ImageProvider? _image;
  Future<List<Color>>? _colors;
  bool _onboarded = true;
  bool? _hasPassword;
  Function reloadRecommendations = () {};

  UserModel();

  bool get authenticated => _access != null;
  String? get email => _email;
  String get username => _username ?? "";
  String? get name => _name;
  String? get country => _country;
  ImageProvider get image =>
      _image ?? AssetImage("assets/other/missing_profile.png");
  Future<List<Color>> get colors =>
      _colors ?? PaletteBackground.extractGradient(image);
  String get language => _languages.isNotEmpty ? _languages[0] : "en";
  Set<StreamingPlatform> get subscribedPlatforms => _subscribedPlatforms;
  Set<StreamingPlatform> get availablePlatforms => _availablePlatforms;
  bool get onboarded => _onboarded;
  bool get hasPassword => _hasPassword ?? false;
  String? get token => _access;

  static Future<UserModel> fromSharedPreferences() async {
    UserModel user = UserModel();

    final prefs = await SharedPreferences.getInstance();
    user._refresh = prefs.getString("refresh_token") ?? null;
    if (user._refresh == null) return user;
    if (!await user.refreshTokens()) return user;

    await user.fetchInfo();
    return user;
  }

  Future<int> loginUsingCredentails(String username, String password) async {
    final response = await DiscyoApi.loginDiscyo(username, password);
    if (response.code != 200) return response.code; // Some error happened

    _access = response.body["access_token"];
    _refresh = response.body["refresh_token"];
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("refresh_token", _refresh!);

    await fetchInfo();
    notifyListeners();
    return response.code; // Everything went fine
  }

  Future<bool> loginUsingRefreshToken(String? token) async {
    _refresh = token;
    await refreshTokens();
    await fetchInfo();
    notifyListeners();
    return true;
  }

  Future<bool> loginWithApple() async {
    final response = await DiscyoApi.loginApple();
    if (response == null) return true; // Login through browser
    if (response.code != 200) return false; // Some error happened

    _access = response.body["access_token"];
    _refresh = response.body["refresh_token"];
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("refresh_token", _refresh!);

    await fetchInfo();
    notifyListeners();
    return true; // Everything went fine
  }

  Future<bool> logout() async {
    MediaCache.clear();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("refresh_token");
    _access = null;
    _refresh = null;
    _email = null;
    _username = null;
    _name = null;
    _country = null;
    _languages = [];
    _subscribedPlatforms = {};
    _availablePlatforms = {};
    _image = null;
    _colors = null;
    _onboarded = true;
    notifyListeners();
    return true;
  }

  Future<List<String>?> dryRegister(Map<String, dynamic> info) async {
    // Check if user can be created
    final response = await DiscyoApi.register(info, dry: true);
    if (response.code == 202) return []; // User can be created
    if (response.code == 406) // Some fields are already in use
      return response.body["items"].cast<String>().toList();
    return null; // Something went wrong
  }

  Future<bool> register(Map<String, dynamic> info) async {
    // Create user
    final response = await DiscyoApi.register(info);
    return response.code == 201;
  }

  void onboard() async {
    DiscyoApi.setUserInfo(_access, {"new_user": false});
    _onboarded = true;
    notifyListeners();
  }

  Future<bool> refreshTokens() async {
    _access = null;
    final response = await DiscyoApi.refreshTokens(_refresh);
    if (response.code != 200) return false; // Invalid token

    _access = response.body["access_token"];
    _refresh = response.body["refresh_token"];
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("refresh_token", _refresh!);
    return true; // Everything went fine
  }

  Future<bool> fetchInfo() async {
    var response = await DiscyoApi.getUserInfo(_access);
    if (response.code == 462 && await refreshTokens())
      response = await DiscyoApi.getUserInfo(_access);
    if (response.code != 200) return false; // Something went wrong

    _email = response.body["email"];
    _username = response.body["username"];
    _name = response.body["name"];
    _country = response.body["country_code"];
    _languages = [WidgetsBinding.instance.window.locale.languageCode];
    if (response.body["subscribed_platforms"] != null) {
      _subscribedPlatforms.clear();
      for (final e in response.body["subscribed_platforms"]) {
        final p = StreamingPlatformExtension.fromId(e);
        if (p != null) _subscribedPlatforms.add(p);
      }
    }
    if (response.body["profile_picture"] != null &&
        !response.body["profile_picture"].isEmpty)
      _image = NetworkImage(response.body["profile_picture"]);
    _colors = PaletteBackground.extractGradient(image);
    _onboarded = !(response.body["new_user"] ?? true);
    _hasPassword = response.body["has_password"] ?? false;

    // If system language changed, update it on server and clear cache
    if (response.body["language_codes"] == null ||
        response.body["language_codes"][0] != _languages[0]) {
      MediaCache.clear();
      setInfo({"language_codes": _languages});
    }

    // Asynchronously get available platforms
    WapitchApi.getProviders(country: _country).then((response) {
      if (response.code != 200) {
        DiscyoApi.error(
          this.runtimeType.toString(),
          "Could not fetch streaming service for user! (Code ${response.code})",
        );
      }
      _availablePlatforms =
          (response.body as List).expand<StreamingPlatform>((e) {
        if (e["provided_content"].any((c) => c == "movie" || c == "show"))
          return [StreamingPlatformExtension.fromId(e["id"])!];
        return [];
      }).toSet();
    });

    return true;
  }

  List<String> getMissingInfo() {
    List<String> missingInfo = [];
    if (_username == null) missingInfo.add("username");
    if (_name == null) missingInfo.add("name");
    if (_country == null) missingInfo.add("country_code");
    return missingInfo;
  }

  Future<int> setInfo(Map<String, dynamic> info) async {
    if (info["username"] == _username) info.remove("username");
    var response = await DiscyoApi.setUserInfo(_access, info);
    if (response.code == 462 && await refreshTokens())
      response = await DiscyoApi.setUserInfo(_access, info);
    if (response.code == 201) {
      _username = info["username"] ?? _username;
      _name = info["name"] ?? _name;
      _country = info["country_code"] ?? _country;
      if (info["subscribed_platforms"] != null) {
        _subscribedPlatforms.clear();
        for (final e in response.body["subscribed_platforms"]) {
          final p = StreamingPlatformExtension.fromId(e);
          if (p != null) _subscribedPlatforms.add(p);
        }
        reloadRecommendations();
      }
      notifyListeners();
    }
    return response.code;
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    var response =
        await DiscyoApi.changePassword(_access, oldPassword, newPassword);
    if (response.code == 462 && await refreshTokens())
      response =
          await DiscyoApi.changePassword(_access, oldPassword, newPassword);
    if (response.code == 204) notifyListeners();
    return response.code == 204;
  }

  Future<bool> delete() async {
    var response = await DiscyoApi.deleteUser(_access);
    if (response.code == 462 && await refreshTokens())
      response = await DiscyoApi.deleteUser(_access);
    if (response.code != 200) return false;
    return logout();
  }

  Future<bool> shouldShowNotification(
      String type, int daysSinceLastShown) async {
    final prefs = await SharedPreferences.getInstance();
    String? lastTime = prefs.getString("${type}_date") ?? null;
    if (lastTime == null) {
      prefs.setString("${type}_date", DateTime.now().toIso8601String());
      return false;
    }

    if (DateTime.now()
            .difference(DateTime.parse(lastTime))
            .compareTo(Duration(days: daysSinceLastShown)) >
        0) {
      prefs.setString("${type}_date", DateTime.now().toIso8601String());
      return true;
    }

    return false;
  }

  Future<bool> setMediaState(Medium medium, MediaState? state) async {
    var response = await DiscyoApi.setState(medium.id, state?.name, token);
    if (response.code == 462 && await refreshTokens())
      response = await DiscyoApi.setState(medium.id, state?.name, token);
    if (response.code != 201) return false;

    medium.setState(state);
    return true;
  }

  Future<bool> setMediaListState(
      Iterable<Medium> media, MediaState? state) async {
    final mediaIds = media.map((e) => e.id).toList(growable: false);
    var response = await DiscyoApi.setStates(mediaIds, state?.name, token);
    if (response.code == 462 && await refreshTokens())
      response = await DiscyoApi.setStates(mediaIds, state?.name, token);
    if (response.code != 201) return false;

    for (var m in media) m.setState(state);
    return true;
  }

  Future<MediaState?> getMediaState(String id) async {
    var response = await DiscyoApi.getState(id, token);
    if (response.code == 462 && await refreshTokens())
      response = await DiscyoApi.getState(id, token);
    if (response.code != 200) return null;
    return MediaStateExtension.fromName(response.body["state"]);
  }

  Future<Map<Type, int>> getMediaStats() async {
    final stateStrings = [
      MediaState.awful.name,
      MediaState.meh.name,
      MediaState.good.name,
      MediaState.awesome.name,
    ];
    Map<Type, int> stats = {};
    for (final mediaType in mediaTypes) {
      // While only Films and Shows are supported, save some requests
      if (mediaType != Film && mediaType != Show) {
        stats[mediaType] = -1;
        continue;
      }
      var statesResponse =
          await DiscyoApi.getStates(stateStrings, mediaType, 0, token);
      if (statesResponse.code == 462 && await refreshTokens())
        statesResponse =
            await DiscyoApi.getStates(stateStrings, mediaType, 0, token);
      if (statesResponse.code != 200) {
        stats[mediaType] = -1; // Something went wrong
        continue;
      }
      stats[mediaType] = statesResponse.body["total_count"];
    }
    return stats;
  }

  Future<List> getList(List<MediaState> states, {int page = 0}) async {
    // Get list of media under given state
    final stateStrings = states.map((e) => e.name).toList(growable: false);
    var statesResponse =
        await DiscyoApi.getStates(stateStrings, null, page, token);
    if (statesResponse.code == 462 && await refreshTokens())
      statesResponse =
          await DiscyoApi.getStates(stateStrings, null, page, token);
    if (statesResponse.code != 200) return [0, []]; // Something went wrong

    // Get corresponding tmdb ids
    var tmdbIdsResponse = await WapitchApi.getMovieTmdbIdList(statesResponse
        .body["items"]
        .map<String>((e) => e["content_id"] as String)
        .toList(growable: false));
    if (tmdbIdsResponse.code != 200) return [0, []]; // Something went wrong
    for (var i in tmdbIdsResponse.body) i["content_type"] = "film";
    List tmdbIds = tmdbIdsResponse.body;
    tmdbIdsResponse = await WapitchApi.getShowTmdbIdList(statesResponse
        .body["items"]
        .map<String>((e) => e["content_id"] as String)
        .toList(growable: false));
    if (tmdbIdsResponse.code != 200) return [0, []]; // Something went wrong
    for (var i in tmdbIdsResponse.body) i["content_type"] = "show";
    tmdbIds.addAll(tmdbIdsResponse.body);
    if (tmdbIds.length != statesResponse.body["items"].length)
      return [0, []]; // Something went wrong

    // Attach tmdb ids to media items
    for (var i = 0; i < statesResponse.body["items"].length; i++) {
      for (var j = 0; j < tmdbIds.length; j++) {
        if (statesResponse.body["items"][i]["content_id"] == tmdbIds[j]["id"]) {
          statesResponse.body["items"][i]["tmdb_id"] = tmdbIds[j]["tmdb_id"];
          statesResponse.body["items"][i]["content_type"] =
              tmdbIds[j]["content_type"];
          break;
        }
      }
    }

    // Sort according to timestamp
    statesResponse.body["items"].sort((a, b) {
      final c = DateTime.tryParse(a["mtime"]);
      final d = DateTime.tryParse(b["mtime"]);
      if (c == null || d == null) return 0;
      return -c.compareTo(d);
    });

    final media = statesResponse.body["items"].map<Future<Medium>>((e) {
      if (e["content_type"] == "film")
        return Film.fetch(
          e["content_id"],
          e["tmdb_id"],
          language: language,
          state: MediaStateExtension.fromName(e["state"]),
        );
      else
        return Show.fetch(
          e["content_id"],
          e["tmdb_id"],
          language: language,
          state: MediaStateExtension.fromName(e["state"]),
        );
    }).toList(growable: false);
    return [statesResponse.body["total_count"], media];
  }

  void sendFeedback(int rating, String review) {
    DiscyoApi.feedback(
      "- - - - - - - - - - - - - - - - - - - - - -\n"
      "User feedback from: $username\n"
      "Rating: $rating\n"
      "Review: $review\n"
      "- - - - - - - - - - - - - - - - - - - - - -\n\n",
      token,
    );
  }

  void reportProblem(String description) {
    DiscyoApi.feedback(
      "- - - - - - - - - - - - - - - - - - - - - -\n"
      "Problem report from: $username\n"
      "Description: $description\n"
      "- - - - - - - - - - - - - - - - - - - - - -\n\n",
      token,
    );
  }

  Future<bool> setImage(File? image) async {
    // Try to upload the image
    var response = await DiscyoApi.uploadImage(image, token);
    if (response.code == 462 && await refreshTokens())
      response = await DiscyoApi.uploadImage(image, token);

    if (response.code != 201) {
      // Something's wrong, we can't upload the image
      DiscyoApi.error(
        "EditProfilePage",
        "Could not update profile picture! (Code ${response.code})",
      );
      return false;
    }

    // Set image locally as well
    if (image != null)
      _image = FileImage(image);
    else
      _image = null;
    notifyListeners();
    return true;
  }
}

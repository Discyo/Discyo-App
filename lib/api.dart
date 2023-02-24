import 'dart:convert';
import 'dart:io';
import 'package:discyo/models/media.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tmdb_dart/tmdb_dart.dart';

class ApiResponse {
  final int code;
  final dynamic body;

  static dynamic _decodeBody(BaseResponse response) {
    if (response.runtimeType == Response) {
      try {
        return jsonDecode(Utf8Codec().decode((response as Response).bodyBytes));
      } catch (e) {}
    }
    if (response.runtimeType == StreamedResponse) {
      try {
        return (response as StreamedResponse).stream;
      } catch (e) {}
    }
    return null;
  }

  ApiResponse(BaseResponse response)
      : code = response.statusCode,
        body = _decodeBody(response);
}

final Map<Type, String> typeMap = {
  Film: "movie",
  Show: "show",
  Album: "music",
  Podcast: "podcast",
  Book: "book",
  Game: "game",
};
// RELEASE: Change url prefix for other than dev builds
final String _releasePrefix = "dev.";

// Utility function for API classes
Map<String, String> _headers(
    {bool post = false, String? token, String? password}) {
  Map<String, String> headers = {"accept": "application/json"};
  if (post) headers["Content-Type"] = "application/json";
  if (token != null && token.isNotEmpty)
    headers["Authorization"] = "Bearer $token";
  if (password != null && password.isNotEmpty) headers["password"] = password;
  return headers;
}

class DiscyoApi {
  static final int pageLength = 16;
  static final String version = "0.9";
  static String get baseUrl =>
      "https://${_releasePrefix}api.discyo.com/v$version";
  static final browser = ChromeSafariBrowser();

  static Future<ApiResponse> loginDiscyo(
      String? username, String? password) async {
    return ApiResponse(await post(
      Uri.parse("$baseUrl/auth/login/discyo"),
      headers: _headers(),
      body: {"username": username, "password": password},
    ));
  }

  static Future<ApiResponse?> loginApple() async {
    if (!Platform.isIOS) {
      _loginThirdParty("apple");
      return null;
    }

    try {
      final credential = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);

      var fullName = credential.givenName;
      if (credential.familyName != null) {
        if (fullName == null)
          fullName = credential.familyName;
        else
          fullName += " ${credential.familyName}";
      }

      return ApiResponse(await post(
        Uri.parse("$baseUrl/auth/login/with-apple"),
        headers: _headers(post: true),
        body: jsonEncode({
          "id_token": credential.identityToken,
          "email": credential.email,
          "name": fullName,
        }),
      ));
    } catch (e) {}
    return null;
  }

  static void loginGoogle() async {
    _loginThirdParty("google");
  }

  static void _loginThirdParty(String name) async {
    final returnUrl = Uri.encodeQueryComponent("app://discyo.currant.ai");
    browser.open(
        url: Uri.parse("$baseUrl/auth/login/$name?return_url=$returnUrl"));
  }

  static Future<ApiResponse> refreshTokens(String? token) async {
    return ApiResponse(await get(
      Uri.parse("$baseUrl/auth/refresh-tokens"),
      headers: _headers(token: token),
    ));
  }

  static Future<ApiResponse> register(Map<String, dynamic> info,
      {bool dry = false}) async {
    final response = ApiResponse(await post(
      Uri.parse("$baseUrl/auth/register/discyo?dry=$dry"),
      headers: _headers(post: true),
      body: jsonEncode(info),
    ));

    if (dry && response.code != 202 && response.code != 406) {
      error(
        "DiscyoApi",
        "Failed to perform dry register! (Code ${response.code})",
      );
    }
    if (!dry && response.code != 201) {
      error(
        "DiscyoApi",
        "Failed to perform register! (Code ${response.code})",
      );
    }

    return response;
  }

  static Future<ApiResponse> sendRecoveryMail(String email) async {
    return ApiResponse(await post(
      Uri.parse("$baseUrl/auth/password-recovery/sendmail/$email"),
      headers: _headers(),
    ));
  }

  static Future<ApiResponse> resetPassword(
      String email, String code, String password) async {
    return ApiResponse(await post(
      Uri.parse("$baseUrl/auth/password-recovery/reset"),
      headers: _headers(post: true),
      body: jsonEncode({
        "email": email,
        "reset_code": code,
        "new_password": password,
      }),
    ));
  }

  static Future<ApiResponse> resendConfirmationEmail(String email) async {
    return ApiResponse(await post(
      Uri.parse("$baseUrl/auth/register/discyo/resent-email"),
      headers: _headers(post: true),
      body: jsonEncode({
        "email": email,
      }),
    ));
  }

  static Future<ApiResponse> recommendations(Type type, String? token,
      {bool init = false}) async {
    String typeString = "";
    if (type == Film) typeString = "movies";
    if (type == Show) typeString = "shows";
    return ApiResponse(await get(
      Uri.parse("$baseUrl/recommendations/$typeString?init=$init"),
      headers: _headers(token: token),
    ));
  }

  static Future<ApiResponse> getUserInfo(String? token) async {
    return ApiResponse(await get(
      Uri.parse("$baseUrl/users/me"),
      headers: _headers(token: token),
    ));
  }

  static Future<ApiResponse> setUserInfo(
      String? token, Map<String, dynamic> info) async {
    return ApiResponse(await put(
      Uri.parse("$baseUrl/users/me"),
      headers: _headers(post: true, token: token),
      body: jsonEncode(info),
    ));
  }

  static Future<ApiResponse> changePassword(
      String? token, String oldPassword, String newPassword) async {
    return ApiResponse(await put(
      Uri.parse("$baseUrl/users/me/change-password"),
      headers: _headers(post: true, token: token, password: oldPassword),
      body: jsonEncode({"new_password": newPassword}),
    ));
  }

  static Future<ApiResponse> deleteUser(String? token) async {
    return ApiResponse(await delete(
      Uri.parse("$baseUrl/users/me"),
      headers: _headers(post: true, token: token),
    ));
  }

  static Future<ApiResponse> getState(String? id, String? token) async {
    return ApiResponse(await get(
      Uri.parse("$baseUrl/users/me/action/$id"),
      headers: _headers(token: token),
    ));
  }

  static Future<ApiResponse> setState(
      String? id, String? state, String? token) async {
    return ApiResponse(await put(
      Uri.parse("$baseUrl/users/me/action"),
      headers: _headers(post: true, token: token),
      body: jsonEncode({
        "state": state,
        "content_id": id,
      }),
    ));
  }

  static Future<ApiResponse> setStates(
      List<String>? ids, String? state, String? token) async {
    return ApiResponse(await put(
      Uri.parse("$baseUrl/users/me/action/list"),
      headers: _headers(post: true, token: token),
      body: jsonEncode(ids
          ?.map((e) => {
                "state": state,
                "content_id": e,
              })
          .toList(growable: false)),
    ));
  }

  static Future<ApiResponse> getStates(
      List<String> states, Type? mediaType, int page, String? token) async {
    String query = "?page=$page&items_per_page=$pageLength";
    if (mediaType != null) query += "&content_type=${typeMap[mediaType]}";
    for (var state in states) query += "&actions=$state";
    return ApiResponse(await get(
      Uri.parse("$baseUrl/users/me/action$query"),
      headers: _headers(token: token),
    ));
  }

  static Future<ApiResponse> getRatings(String id) async {
    return ApiResponse(await get(
      Uri.parse("$baseUrl/contents/state-counters/$id"),
      headers: _headers(),
    ));
  }

  static Future<ApiResponse> configuration(String listName) async {
    return ApiResponse(await get(
      Uri.parse("$baseUrl/configuration/$listName?registration=true"),
      headers: _headers(),
    ));
  }

  static Future<ApiResponse> feedback(String message, String? token) async {
    final response = ApiResponse(await post(
      Uri.parse("$baseUrl/report/feedback"),
      headers: _headers(post: true, token: token),
      body: jsonEncode({"message": message}),
    ));

    if (response.code != 204) {
      error(
        "DiscyoApi",
        "Could not send feedback! (Code ${response.code})",
      );
    }

    return response;
  }

  static void error(String className, String message) {
    final log = "[${DateTime.now().toString()}]($className) ERROR: $message";
    print(log);
    post(
      Uri.parse("$baseUrl/report/error"),
      headers: _headers(post: true),
      body: jsonEncode({"message": "$log\n"}),
    );
  }

  static Future<ApiResponse> uploadImage(
      File? originalFile, String? token) async {
    if (originalFile == null) {
      return ApiResponse(await put(
        Uri.parse("$baseUrl/users/me"),
        headers: _headers(post: true, token: token),
        body: jsonEncode({
          "profile_picture": null,
        }),
      ));
    }

    // Make sure image meets standards
    final original = decodeImage(await originalFile.readAsBytes());
    if (original == null) throw Exception("Couldn't decode image!");
    final resized = copyResize(
      original,
      width: original.width > original.height ? 400 : null,
      height: original.width > original.height ? null : 400,
      interpolation: Interpolation.linear,
    );
    final td = await getTemporaryDirectory();
    final file = File(join(td.path, "profile.jpg"));
    await file.writeAsBytes(encodeJpg(resized, quality: 60));

    // Create and send request
    final request = MultipartRequest(
      "PUT",
      Uri.parse("$baseUrl/users/me/profile_picture"),
    );
    request.files.add(
      await MultipartFile.fromPath(
        "image",
        file.path,
        contentType: MediaType("image", "jpeg"),
      ),
    );
    request.headers.addAll(_headers(token: token));
    final response = ApiResponse(await request.send());

    // Clean up and return response
    file.delete();
    return response;
  }
}

class DiscyoWeb {
  static String get baseUrl => "https://${_releasePrefix}web.discyo.com";

  static String shareUrl(Type mediaType, String mediaId, String? userCountry) {
    if (userCountry != null)
      return "$baseUrl/${typeMap[mediaType]}/$mediaId/$userCountry";
    return "$baseUrl/$mediaType/$mediaId";
  }
}

class WapitchApi {
  static final String version = "0.1";
  static String get baseUrl =>
      "https://${_releasePrefix}api.wapitch.com/v$version";

  static Future<ApiResponse> getMovieId(int tmdb) async {
    return ApiResponse(await get(
      Uri.parse("$baseUrl/content/movies/tmdb/$tmdb"),
      headers: _headers(),
    ));
  }

  static Future<ApiResponse> getShowId(int tmdb) async {
    return ApiResponse(await get(
      Uri.parse("$baseUrl/content/shows/tmdb/$tmdb"),
      headers: _headers(),
    ));
  }

  static Future<ApiResponse> getMovieProviders(String id) async {
    return ApiResponse(await get(
      Uri.parse("$baseUrl/content/movies/$id?append=providers"),
      headers: _headers(),
    ));
  }

  static Future<ApiResponse> getShowProviders(String id) async {
    return ApiResponse(await get(
      Uri.parse("$baseUrl/content/shows/$id?append=providers"),
      headers: _headers(),
    ));
  }

  static Future<ApiResponse> getMovieTmdbIdList(List<String> ids) async {
    String query = "";
    for (final id in ids) query += "&id_list=$id";
    if (query.isNotEmpty) query = "?" + query.substring(1);
    return ApiResponse(await get(
      Uri.parse("$baseUrl/content/movies/list/$query"),
      headers: _headers(),
    ));
  }

  static Future<ApiResponse> getShowTmdbIdList(List<String> ids) async {
    String query = "";
    for (final id in ids) query += "&id_list=$id";
    if (query.isNotEmpty) query = "?" + query.substring(1);
    return ApiResponse(await get(
      Uri.parse("$baseUrl/content/shows/list/$query"),
      headers: _headers(),
    ));
  }

  static Future<ApiResponse> getProviders(
      {Type? medium, String? country}) async {
    String query = "";
    if (medium != null) query += "&content_type=${typeMap[medium]}";
    if (country != null) query += "&country_code=$country";
    if (query.isNotEmpty) query = "?" + query.substring(1);
    return ApiResponse(await get(
      Uri.parse("$baseUrl/providers/$query"),
      headers: _headers(),
    ));
  }
}

class TmdbApiWrapper {
  static String key = "<YOUR_TMDB_KEY>";
  static TmdbService service = TmdbService(key);
  static Configuration configuration = Configuration(
    baseUrl: "http://image.tmdb.org/t/p/",
    secureBaseUrl: "https://image.tmdb.org/t/p/",
    backdropSizes: ["w300", "w780", "w1280", "original"],
    logoSizes: ["w45", "w92", "w154", "w185", "w300", "w500", "original"],
    posterSizes: ["w92", "w154", "w185", "w342", "w500", "w780", "original"],
    profileSizes: ["w45", "w185", "h632", "original"],
    stillSizes: ["w92", "w185", "w300", "original"],
  );

  static Future<ApiResponse> multiSearch(String query, String language) async {
    return ApiResponse(await get(
      Uri(
        scheme: "https",
        host: "api.themoviedb.org",
        path: "3/search/multi",
        queryParameters: {"api_key": key, "language": language, "query": query},
      ),
      headers: _headers(),
    ));
  }

  static String? videoUrl(Video video) {
    if (video.key == null) return null;
    if (video.site == "YouTube")
      return "https://www.youtube.com/watch?v=${video.key}";
    if (video.site == "Vimeo") return "https://vimeo.com/${video.key}";
    return null;
  }

  static String? imageName(String? url) {
    return url?.substring(url.lastIndexOf("/") + 1);
  }

  static String imageUrl(String name) {
    return configuration.secureBaseUrl +
        configuration.posterSizes[3] +
        "/$name";
  }

  static String thumbnailUrl(String name) {
    return configuration.secureBaseUrl +
        configuration.posterSizes[0] +
        "/$name";
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();

  factory TokenManager() {
    return _instance;
  }

  TokenManager._internal();

  String? _bearerToken;
  late DateTime _lastRefreshTime; // Stocke le temps du dernier rafraîchissement

  String? getBearerToken() {
    return _bearerToken;
  }

  Future<void> setBearerToken(String? token) async {
    _bearerToken = token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('bearerToken', token ?? '');
  }

  Future<void> initTokenFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _bearerToken = prefs.getString('bearerToken');
    String? lastRefreshString = prefs.getString('lastRefreshTime');

    if (lastRefreshString != null) {
      _lastRefreshTime = DateTime.parse(lastRefreshString);
    } else {
      _lastRefreshTime = DateTime.now(); // Première initialisation avec l'heure actuelle
      await saveLastRefreshTime(); // Sauvegarde l'heure actuelle comme temps du dernier rafraîchissement
    }
  }

  Future<void> startTokenRefreshTimer() async {
    // Timer.periodic(const Duration(seconds: 1), (timer) async {
    await refreshTokenIfExpired(); // Appel à la fonction pour rafraîchir le token
    // });
  }

  Future<void> refreshTokenIfExpired() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastRefreshString = prefs.getString('lastRefreshTime');

    if (lastRefreshString == null) {
      await refreshToken(); // Si jamais manquant
    } else {
      DateTime lastRefresh = DateTime.parse(lastRefreshString);
      Duration difference = DateTime.now().difference(lastRefresh);
      if (difference.inMinutes >= 60) {
        await refreshToken();
      }
    }
  }

  Future<void> refreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final http.Response response = await http.post(
      Uri.parse(ApiUrls.postGenerateTokenUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': prefs.getString('phone'),
        'password': prefs.getString('password'),
      }),
    );

    final Map<String, dynamic> responseData = jsonDecode(response.body);
    String? newToken = responseData['token'];

    if (newToken != null) {
      await setBearerToken(newToken);
      _lastRefreshTime = DateTime.now();
      await saveLastRefreshTime();
    } else {}
  }

  Future<void> saveLastRefreshTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastRefreshTime', _lastRefreshTime.toIso8601String());
  }
}

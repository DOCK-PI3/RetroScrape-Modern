import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../models/game_metadata.dart';

class ScreenScraperQuota {
  const ScreenScraperQuota({
    required this.usedToday,
    required this.maxPerDay,
    this.koToday,
    this.maxKoPerDay,
    this.maxPerMinute,
  });

  final int usedToday;
  final int maxPerDay;
  final int? koToday;
  final int? maxKoPerDay;
  final int? maxPerMinute;

  int get remaining => (maxPerDay - usedToday).clamp(0, maxPerDay);
  bool get isExceeded => maxPerDay > 0 && usedToday >= maxPerDay;
  double get ratio => maxPerDay <= 0 ? 0 : usedToday / maxPerDay;
}

class ScreenScraperQuotaExceededException implements Exception {
  const ScreenScraperQuotaExceededException(this.message, {this.quota});

  final String message;
  final ScreenScraperQuota? quota;

  @override
  String toString() => message;
}

class ScreenScraperService {
  ScreenScraperService({Dio? dio}) : _dio = dio ?? Dio();

  static const bundledDevId = String.fromEnvironment('SS_DEV_ID');
  static const bundledDevPassword = String.fromEnvironment('SS_DEV_PASSWORD');

  final Dio _dio;
  DateTime? _lastRequestAt;
  ScreenScraperQuota? latestQuota;

  String _devId = '';
  String _devPass = '';
  String _user = '';
  String _pass = '';

  void configure({
    String? devId,
    String? devPass,
    required String user,
    required String pass,
  }) {
    _devId = _configuredValue(devId, bundledDevId);
    _devPass = _configuredValue(devPass, bundledDevPassword);
    _user = user.trim();
    _pass = pass;
  }

  bool get isConfigured {
    return _devId.isNotEmpty &&
        _devPass.isNotEmpty &&
        _user.isNotEmpty &&
        _pass.isNotEmpty;
  }

  bool get hasDeveloperCredentials {
    return _devId.isNotEmpty && _devPass.isNotEmpty;
  }

  String _configuredValue(String? explicit, String fallback) {
    final explicitValue = explicit?.trim() ?? '';
    return explicitValue.isNotEmpty ? explicitValue : fallback.trim();
  }

  Future<ScreenScraperQuota?> fetchUserQuota({String language = 'es'}) async {
    if (!isConfigured) {
      throw StateError('ScreenScraper credentials are not configured');
    }

    await _rateLimit();
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.screenscraper.fr/api2/ssuserInfos.php',
        queryParameters: _baseParameters(language),
        options: _requestOptions(),
      );
      latestQuota = _extractQuota(response.data) ?? latestQuota;
      return latestQuota;
    } on DioException catch (error) {
      final quotaError = _quotaExceptionFrom(error);
      if (quotaError != null) {
        throw quotaError;
      }
      rethrow;
    }
  }

  Future<GameMetadata?> fetchByHash({
    required String md5,
    required String crc,
    required String sha1,
    required int systemId,
    required String romName,
    required int romSize,
    String language = 'es',
    String? cacheDir,
    bool useCache = true,
  }) async {
    if (!isConfigured) {
      throw StateError('ScreenScraper credentials are not configured');
    }

    if (md5.trim().isEmpty && romName.trim().isEmpty) {
      return null;
    }

    final cacheFile =
        cacheDir == null ? null : File(p.join(cacheDir, '$systemId-$md5.json'));
    if (useCache && cacheFile != null && cacheFile.existsSync()) {
      final cached = jsonDecode(await cacheFile.readAsString());
      if (cached is Map<String, dynamic>) {
        return GameMetadata.fromApi(cached);
      }
    }

    try {
      Map<String, dynamic>? game;
      try {
        game = await _fetchGameInfo(
          systemId: systemId,
          romName: romName,
          romSize: romSize,
          crc: crc,
          md5: md5,
          sha1: sha1,
          language: language,
        );
      } on ScreenScraperQuotaExceededException {
        rethrow;
      } on DioException {
        game = null;
      }

      final fallbackGame = game ??
          await _fetchGameByName(
            systemId: systemId,
            romName: romName,
            language: language,
          );
      if (fallbackGame == null) {
        return null;
      }

      if (cacheFile != null) {
        await cacheFile.parent.create(recursive: true);
        await cacheFile.writeAsString(jsonEncode(fallbackGame));
      }

      return GameMetadata.fromApi(fallbackGame);
    } on ScreenScraperQuotaExceededException {
      rethrow;
    } on DioException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchGameInfo({
    required int systemId,
    required String romName,
    required int romSize,
    required String crc,
    required String md5,
    required String sha1,
    required String language,
    int? gameId,
  }) async {
    await _rateLimit();
    final parameters = _baseParameters(language)
      ..addAll({'systemeid': systemId, 'romtype': 'rom'});

    if (gameId != null) {
      parameters['gameid'] = gameId;
    } else {
      parameters.addAll({
        'crc': crc.toUpperCase(),
        'md5': md5.toLowerCase(),
        'sha1': sha1.toLowerCase(),
        'romnom': romName,
        'romtaille': romSize,
      });
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.screenscraper.fr/api2/jeuInfos.php',
        queryParameters: parameters,
        options: _requestOptions(),
      );
      latestQuota = _extractQuota(response.data) ?? latestQuota;
      return _extractGame(response.data);
    } on DioException catch (error) {
      final quotaError = _quotaExceptionFrom(error);
      if (quotaError != null) {
        throw quotaError;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _fetchGameByName({
    required int systemId,
    required String romName,
    required String language,
  }) async {
    final search = _cleanRomName(romName);
    if (search.isEmpty) {
      return null;
    }

    await _rateLimit();
    late final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.get<Map<String, dynamic>>(
        'https://api.screenscraper.fr/api2/jeuRecherche.php',
        queryParameters: _baseParameters(language)
          ..addAll({'systemeid': systemId, 'recherche': search}),
        options: _requestOptions(),
      );
      latestQuota = _extractQuota(response.data) ?? latestQuota;
    } on DioException catch (error) {
      final quotaError = _quotaExceptionFrom(error);
      if (quotaError != null) {
        throw quotaError;
      }
      rethrow;
    }

    final games = _extractGames(response.data);
    if (games.isEmpty) {
      return null;
    }

    final best = games.first;
    final id = _asInt(
      best['id'] ?? best['idjeu'] ?? best['gameid'] ?? best['jeu_id'],
    );
    if (id == null) {
      return best;
    }

    return await _fetchGameInfo(
          systemId: systemId,
          romName: romName,
          romSize: 0,
          crc: '',
          md5: '',
          sha1: '',
          language: language,
          gameId: id,
        ) ??
        best;
  }

  Map<String, dynamic> _baseParameters(String language) {
    return {
      'devid': _devId,
      'devpassword': _devPass,
      'ssid': _user,
      'sspassword': _pass,
      'softname': 'RetroScrapeModern',
      'output': 'json',
      'langue': language,
    };
  }

  Options _requestOptions() {
    return Options(
      headers: {HttpHeaders.userAgentHeader: 'RetroScrapeModern/1.0'},
      sendTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    );
  }

  Map<String, dynamic>? _extractGame(Map<String, dynamic>? payload) {
    if (payload == null) {
      return null;
    }
    final response = payload['response'];
    final game = payload['game'] ??
        payload['jeu'] ??
        (response is Map ? response['game'] ?? response['jeu'] : null);
    return game is Map<String, dynamic> ? game : null;
  }

  List<Map<String, dynamic>> _extractGames(Map<String, dynamic>? payload) {
    if (payload == null) {
      return [];
    }
    final response = payload['response'];
    final games = payload['jeux'] ??
        payload['games'] ??
        (response is Map ? response['jeux'] ?? response['games'] : null);
    if (games is List) {
      return games.whereType<Map<String, dynamic>>().toList();
    }
    if (games is Map<String, dynamic>) {
      final nested = games['jeu'] ?? games['game'];
      if (nested is List) {
        return nested.whereType<Map<String, dynamic>>().toList();
      }
      if (nested is Map<String, dynamic>) {
        return [nested];
      }
      return [games];
    }
    return [];
  }

  ScreenScraperQuota? _extractQuota(Map<String, dynamic>? payload) {
    if (payload == null) {
      return null;
    }

    final response = payload['response'];
    final user = payload['ssuser'] ??
        payload['user'] ??
        (response is Map ? response['ssuser'] ?? response['user'] : null);
    if (user is! Map) {
      return null;
    }

    final usedToday = _asInt(user['requeststoday']);
    final maxPerDay = _asInt(user['maxrequestsperday']);
    if (usedToday == null || maxPerDay == null) {
      return null;
    }

    return ScreenScraperQuota(
      usedToday: usedToday,
      maxPerDay: maxPerDay,
      koToday: _asInt(user['requestskotoday']),
      maxKoPerDay: _asInt(user['maxrequestskoperday']),
      maxPerMinute: _asInt(
        user['maxrequestspermin'] ?? user['maxrequestsperdmin'],
      ),
    );
  }

  ScreenScraperQuotaExceededException? _quotaExceptionFrom(
    DioException error,
  ) {
    final statusCode = error.response?.statusCode;
    if (error.response?.data is Map<String, dynamic>) {
      latestQuota =
          _extractQuota(error.response!.data as Map<String, dynamic>) ??
              latestQuota;
    }

    if (statusCode == 430) {
      return ScreenScraperQuotaExceededException(
        'Se alcanzó el límite diario de llamadas a ScreenScraper.',
        quota: latestQuota,
      );
    }
    if (statusCode == 431) {
      return ScreenScraperQuotaExceededException(
        'Se alcanzó el límite diario de búsquedas no encontradas en ScreenScraper.',
        quota: latestQuota,
      );
    }
    return null;
  }

  String _cleanRomName(String value) {
    final withoutExtension = p.basenameWithoutExtension(value);
    return withoutExtension
        .replaceAll(RegExp(r'\([^)]*\)|\[[^\]]*\]'), ' ')
        .replaceAll(RegExp(r'[_\-.]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  Future<List<int>?> downloadBytes(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return null;
    }

    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      return response.data;
    } on DioException {
      return null;
    }
  }

  Future<void> _rateLimit() async {
    final now = DateTime.now();
    if (_lastRequestAt == null) {
      _lastRequestAt = now;
      return;
    }

    final elapsedMs = now.difference(_lastRequestAt!).inMilliseconds;
    const minGapMs = 600;

    if (elapsedMs < minGapMs) {
      await Future<void>.delayed(Duration(milliseconds: minGapMs - elapsedMs));
    }

    _lastRequestAt = DateTime.now();
  }
}

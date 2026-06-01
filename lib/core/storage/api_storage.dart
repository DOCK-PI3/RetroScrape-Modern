import 'package:shared_preferences/shared_preferences.dart';

class ApiStorage {
  static const _devIdKey = 'api.dev_id';
  static const _devPassKey = 'api.dev_pass';
  static const _userKey = 'api.user';
  static const _userPassKey = 'api.pass';
  static const _romFolderKey = 'settings.rom_folder';
  static const _frontendKey = 'settings.frontend';
  static const _mediaKey = 'settings.media';
  static const _mixKey = 'settings.mix';
  static const _cacheKey = 'settings.cache';
  static const _overwriteKey = 'settings.overwrite';
  static const _threadsKey = 'settings.threads';
  static const _systemFoldersKey = 'settings.system_folders';
  static const _nameCaseKey = 'settings.metadata.name_case';
  static const _descriptionCaseKey = 'settings.metadata.description_case';
  static const _genreCaseKey = 'settings.metadata.genre_case';
  static const _moveArticlesKey = 'settings.metadata.move_articles';
  static const _useRegionInNameKey = 'settings.metadata.use_region_in_name';
  static const _keepDecorationsKey = 'settings.metadata.keep_decorations';
  static const _keepUndecoratedKey = 'settings.metadata.keep_undecorated';
  static const _includeSynopsisKey = 'settings.metadata.include_synopsis';
  static const _gamelistModeKey = 'settings.gamelist.mode';
  static const _minimizeGamelistKey = 'settings.gamelist.minimize';
  static const _cleanupMediaKey = 'settings.media.cleanup';
  static const _optimizeMediaKey = 'settings.media.optimize';

  Future<void> save({
    required String user,
    required String pass,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_devIdKey);
    await prefs.remove(_devPassKey);
    await prefs.setString(_userKey, user.trim());
    await prefs.setString(_userPassKey, pass);
  }

  Future<Map<String, String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString(_userKey) ?? '';
    final pass = prefs.getString(_userPassKey) ?? '';

    return {'user': user, 'pass': pass};
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_devIdKey);
    await prefs.remove(_devPassKey);
    await prefs.remove(_userKey);
    await prefs.remove(_userPassKey);
  }

  Future<void> saveSettings({
    required String romFolder,
    required Map<int, String> systemFolders,
    required String frontend,
    required List<String> media,
    required String mix,
    required bool cache,
    required bool overwrite,
    required int threads,
    required String nameCase,
    required String descriptionCase,
    required String genreCase,
    required bool moveArticles,
    required bool useRegionInName,
    required bool keepFilenameDecorations,
    required bool keepUndecoratedFilename,
    required bool includeSynopsis,
    required String gamelistMode,
    required bool minimizeGamelist,
    required bool cleanupMedia,
    required bool optimizeMedia,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_romFolderKey, romFolder);
    await prefs.setStringList(
      _systemFoldersKey,
      systemFolders.entries
          .where((entry) => entry.value.trim().isNotEmpty)
          .map((entry) => '${entry.key}|${entry.value}')
          .toList(),
    );
    await prefs.setString(_frontendKey, frontend);
    await prefs.setStringList(_mediaKey, media);
    await prefs.setString(_mixKey, mix);
    await prefs.setBool(_cacheKey, cache);
    await prefs.setBool(_overwriteKey, overwrite);
    await prefs.setInt(_threadsKey, threads);
    await prefs.setString(_nameCaseKey, nameCase);
    await prefs.setString(_descriptionCaseKey, descriptionCase);
    await prefs.setString(_genreCaseKey, genreCase);
    await prefs.setBool(_moveArticlesKey, moveArticles);
    await prefs.setBool(_useRegionInNameKey, useRegionInName);
    await prefs.setBool(_keepDecorationsKey, keepFilenameDecorations);
    await prefs.setBool(_keepUndecoratedKey, keepUndecoratedFilename);
    await prefs.setBool(_includeSynopsisKey, includeSynopsis);
    await prefs.setString(_gamelistModeKey, gamelistMode);
    await prefs.setBool(_minimizeGamelistKey, minimizeGamelist);
    await prefs.setBool(_cleanupMediaKey, cleanupMedia);
    await prefs.setBool(_optimizeMediaKey, optimizeMedia);
  }

  Future<Map<String, Object>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final systemFolders = <int, String>{};
    for (final entry in prefs.getStringList(_systemFoldersKey) ?? const []) {
      final separator = entry.indexOf('|');
      if (separator <= 0) {
        continue;
      }
      final id = int.tryParse(entry.substring(0, separator));
      final path = entry.substring(separator + 1);
      if (id != null && path.isNotEmpty) {
        systemFolders[id] = path;
      }
    }

    return {
      'romFolder': prefs.getString(_romFolderKey) ?? '',
      'systemFolders': systemFolders,
      'frontend': prefs.getString(_frontendKey) ?? 'emulationStation',
      'media':
          prefs.getStringList(_mediaKey) ?? ['box3d', 'screenshot', 'logo'],
      'mix': prefs.getString(_mixKey) ?? 'detailed',
      'cache': prefs.getBool(_cacheKey) ?? true,
      'overwrite': prefs.getBool(_overwriteKey) ?? false,
      'threads': prefs.getInt(_threadsKey) ?? 2,
      'nameCase': prefs.getString(_nameCaseKey) ?? 'asIs',
      'descriptionCase': prefs.getString(_descriptionCaseKey) ?? 'asIs',
      'genreCase': prefs.getString(_genreCaseKey) ?? 'asIs',
      'moveArticles': prefs.getBool(_moveArticlesKey) ?? false,
      'useRegionInName': prefs.getBool(_useRegionInNameKey) ?? false,
      'keepFilenameDecorations': prefs.getBool(_keepDecorationsKey) ?? false,
      'keepUndecoratedFilename': prefs.getBool(_keepUndecoratedKey) ?? false,
      'includeSynopsis': prefs.getBool(_includeSynopsisKey) ?? true,
      'gamelistMode': prefs.getString(_gamelistModeKey) ?? 'backupAndUpdate',
      'minimizeGamelist': prefs.getBool(_minimizeGamelistKey) ?? false,
      'cleanupMedia': prefs.getBool(_cleanupMediaKey) ?? true,
      'optimizeMedia': prefs.getBool(_optimizeMediaKey) ?? true,
    };
  }
}

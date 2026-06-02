import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'core/api/screenscraper_service.dart';
import 'core/storage/api_storage.dart';
import 'core/utils/exporters.dart';
import 'core/utils/rom_scanner.dart';
import 'models/game_metadata.dart';
import 'models/rom.dart';
import 'models/scraper_settings.dart';
import 'models/system_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
        Locale('fr', 'FR'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('es', 'ES'),
      child: const ProviderScope(child: RetroScrapeApp()),
    ),
  );
}

class RetroScrapeApp extends StatelessWidget {
  const RetroScrapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00A8A8),
      brightness: Brightness.dark,
      primary: const Color(0xFF00C2B8),
      secondary: const Color(0xFFE5B54A),
      tertiary: const Color(0xFFE96F53),
      surface: const Color(0xFF14171D),
    );
    return MaterialApp(
      title: 'RetroScrape Modern',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFF0F1117),
        cardTheme: const CardThemeData(
          color: Color(0xFF171B23),
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = ApiStorage();
  final _scanner = RomScanner();
  final _service = ScreenScraperService();

  final _userController = TextEditingController();
  final _passController = TextEditingController();

  String _romFolder = '';
  Map<int, String> _systemFolders = {};
  List<RomFile> _romFiles = [];
  RomFile? _selectedRom;
  int? _selectedSystemId;
  int _processed = 0;
  bool _isScanning = false;
  bool _isScraping = false;
  String _status = 'Listo';
  String? _lastExportPath;
  int _scanVersion = 0;
  ScreenScraperQuota? _apiQuota;
  int _previewMediaIndex = 0;

  FrontendTarget _frontend = FrontendTarget.emulationStation;
  MixStyle _mixStyle = MixStyle.detailed;
  Set<String> _selectedMedia = {'box3d', 'screenshot', 'logo'};
  bool _useCache = true;
  bool _overwriteMedia = false;
  bool _cleanupMedia = true;
  bool _optimizeMedia = true;
  int _parallelism = 2;
  TextCaseMode _nameCase = TextCaseMode.asIs;
  TextCaseMode _descriptionCase = TextCaseMode.asIs;
  TextCaseMode _genreCase = TextCaseMode.asIs;
  bool _moveArticles = false;
  bool _useRegionInName = false;
  bool _keepFilenameDecorations = false;
  bool _keepUndecoratedFilename = false;
  bool _includeSynopsis = true;
  GamelistUpdateMode _gamelistMode = GamelistUpdateMode.backupAndUpdate;
  bool _minimizeGamelist = false;

  int get _doneCount =>
      _romFiles.where((rom) => rom.status == RomStatus.done).length;
  int get _errorCount =>
      _romFiles.where((rom) => rom.status == RomStatus.error).length;
  int get _total => _romFiles.length;
  List<RomFile> get _visibleRoms {
    final selectedSystemId = _selectedSystemId;
    if (selectedSystemId == null) {
      return _romFiles;
    }
    return _romFiles.where((rom) => rom.systemId == selectedSystemId).toList();
  }

  List<int> get _knownSystemIds {
    final ids = <int>{
      ..._systemFolders.keys,
      ..._romFiles.map((rom) => rom.systemId),
    };
    final sorted = ids.toList()
      ..sort(
        (a, b) =>
            SystemCatalog.byId(a).name.compareTo(SystemCatalog.byId(b).name),
      );
    return sorted;
  }

  double get _progress => _total == 0 ? 0 : _processed / _total;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final credentials = await _storage.load();
    final settings = await _storage.loadSettings();
    if (!mounted) {
      return;
    }

    _userController.text = credentials['user'] ?? '';
    _passController.text = credentials['pass'] ?? '';
    _service.configure(
      user: _userController.text,
      pass: _passController.text,
    );

    setState(() {
      _romFolder = settings['romFolder'] as String;
      _systemFolders = Map<int, String>.from(settings['systemFolders'] as Map);
      _frontend = _parseFrontend(settings['frontend'] as String);
      _selectedMedia = (settings['media'] as List<String>).toSet();
      _mixStyle = _parseMix(settings['mix'] as String);
      _useCache = settings['cache'] as bool;
      _overwriteMedia = settings['overwrite'] as bool;
      _parallelism = settings['threads'] as int;
      _cleanupMedia = settings['cleanupMedia'] as bool;
      _optimizeMedia = settings['optimizeMedia'] as bool;
      _nameCase = _parseTextCase(settings['nameCase'] as String);
      _descriptionCase = _parseTextCase(settings['descriptionCase'] as String);
      _genreCase = _parseTextCase(settings['genreCase'] as String);
      _moveArticles = settings['moveArticles'] as bool;
      _useRegionInName = settings['useRegionInName'] as bool;
      _keepFilenameDecorations = settings['keepFilenameDecorations'] as bool;
      _keepUndecoratedFilename = settings['keepUndecoratedFilename'] as bool;
      _includeSynopsis = settings['includeSynopsis'] as bool;
      _gamelistMode = _parseGamelistMode(settings['gamelistMode'] as String);
      _minimizeGamelist = settings['minimizeGamelist'] as bool;
    });

    if (_romFolder.isNotEmpty) {
      await _scanRoms();
    }
    if (_service.isConfigured) {
      await _refreshApiQuota(showErrors: false);
    }
  }

  Future<void> _saveSettings() {
    return _storage.saveSettings(
      romFolder: _romFolder,
      systemFolders: _systemFolders,
      frontend: _frontend.name,
      media: _selectedMedia.toList()..sort(),
      mix: _mixStyle.name,
      cache: _useCache,
      overwrite: _overwriteMedia,
      threads: _parallelism,
      nameCase: _nameCase.name,
      descriptionCase: _descriptionCase.name,
      genreCase: _genreCase.name,
      moveArticles: _moveArticles,
      useRegionInName: _useRegionInName,
      keepFilenameDecorations: _keepFilenameDecorations,
      keepUndecoratedFilename: _keepUndecoratedFilename,
      includeSynopsis: _includeSynopsis,
      gamelistMode: _gamelistMode.name,
      minimizeGamelist: _minimizeGamelist,
      cleanupMedia: _cleanupMedia,
      optimizeMedia: _optimizeMedia,
    );
  }

  Future<void> _saveCredentials({bool showMessage = true}) async {
    await _storage.save(
      user: _userController.text,
      pass: _passController.text,
    );
    _service.configure(
      user: _userController.text,
      pass: _passController.text,
    );
    if (mounted && showMessage) {
      _snack('Credenciales guardadas');
    }
    await _refreshApiQuota(showErrors: showMessage);
  }

  Future<void> _refreshApiQuota({bool showErrors = false}) async {
    if (!_service.isConfigured) {
      return;
    }

    try {
      final quota = await _service.fetchUserQuota(language: _apiLanguage());
      if (!mounted || quota == null) {
        return;
      }
      setState(() => _apiQuota = quota);
      if (quota.isExceeded && showErrors) {
        _showQuotaLimitMessage(quota);
      }
    } on ScreenScraperQuotaExceededException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _apiQuota = error.quota ?? _apiQuota);
      if (showErrors) {
        _snack(error.message, isError: true);
      }
    } catch (_) {
      if (showErrors) {
        _snack('api.quota_failed'.tr(), isError: true);
      }
    }
  }

  Future<void> _selectFolder() async {
    final initialDirectory =
        _romFolder.isNotEmpty && Directory(_romFolder).existsSync()
            ? _romFolder
            : null;
    final path = await FilePicker.platform.getDirectoryPath(
      initialDirectory: initialDirectory,
    );
    if (path == null) {
      return;
    }
    setState(() {
      if (_isScanning) {
        _scanVersion++;
      }
      _romFolder = path;
      _lastExportPath = null;
      _selectedRom = null;
    });
    await _saveSettings();
    await _scanRoms();
  }

  Future<void> _selectSystemFolder(int systemId) async {
    final current = _systemFolders[systemId];
    final initialDirectory =
        current != null && Directory(current).existsSync() ? current : null;
    final path = await FilePicker.platform.getDirectoryPath(
      initialDirectory: initialDirectory,
    );
    if (path == null) {
      return;
    }
    setState(() {
      if (_isScanning) {
        _scanVersion++;
      }
      _systemFolders = {..._systemFolders, systemId: path};
      _selectedSystemId = systemId;
      _selectedRom = null;
      _lastExportPath = null;
    });
    await _saveSettings();
    await _scanRoms();
  }

  Future<void> _scanRoms() async {
    if (_romFolder.isEmpty &&
        _systemFolders.values.every((path) => path.trim().isEmpty)) {
      return;
    }
    final scanVersion = ++_scanVersion;
    setState(() {
      _isScanning = true;
      _status = 'Escaneando ROMs y calculando hashes...';
      _processed = 0;
    });

    final files = <RomFile>[];
    final scannedPaths = <String>{};
    if (_romFolder.isNotEmpty && Directory(_romFolder).existsSync()) {
      files.addAll(await _scanner.scan(_romFolder));
      scannedPaths.add(p.normalize(_romFolder).toLowerCase());
    }
    for (final entry in _systemFolders.entries) {
      final path = entry.value;
      final normalized = p.normalize(path).toLowerCase();
      if (path.isEmpty ||
          scannedPaths.contains(normalized) ||
          !Directory(path).existsSync()) {
        continue;
      }
      files.addAll(
        await _scanner.scan(path, forcedProfile: SystemCatalog.byId(entry.key)),
      );
      scannedPaths.add(normalized);
    }
    final byIdentity = <String, RomFile>{};
    for (final rom in files) {
      byIdentity[
              '${p.normalize(rom.path).toLowerCase()}|${rom.innerPath ?? ''}'] =
          rom;
    }
    files
      ..clear()
      ..addAll(byIdentity.values);
    files.sort((a, b) {
      final systemCompare = a.systemName.compareTo(b.systemName);
      if (systemCompare != 0) {
        return systemCompare;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    if (!mounted) {
      return;
    }
    if (scanVersion != _scanVersion) {
      return;
    }

    setState(() {
      _romFiles = files;
      final visible = _selectedSystemId == null
          ? files
          : files.where((rom) => rom.systemId == _selectedSystemId).toList();
      _selectedRom = visible.isEmpty
          ? (files.isEmpty ? null : files.first)
          : visible.first;
      _isScanning = false;
      _status = files.isEmpty
          ? 'No se encontraron ROMs compatibles'
          : 'Listo para scrapear';
    });
  }

  Future<void> _startScraping() async {
    if (_romFiles.isEmpty || _isScraping) {
      return;
    }
    if (!_service.isConfigured) {
      _snack(
        _service.hasDeveloperCredentials
            ? 'Configura tus credenciales ScreenScraper primero'
            : 'Esta build no incluye las credenciales internas de ScreenScraper',
        isError: true,
      );
      return;
    }

    await _saveSettings();
    await _saveCredentials();
    final quota = _apiQuota;
    if (quota != null && quota.isExceeded) {
      _showQuotaLimitMessage(quota);
      return;
    }

    setState(() {
      _isScraping = true;
      _processed = 0;
      _status = 'Scraping en curso...';
      _lastExportPath = null;
      for (final rom in _romFiles) {
        rom.status = RomStatus.pending;
        rom.message = '';
      }
    });

    final queue = List<RomFile>.from(_romFiles);
    final workers = List.generate(_parallelism, (_) => _scrapeQueue(queue));
    await Future.wait(workers);

    if (!mounted) {
      return;
    }
    setState(() {
      _isScraping = false;
      _status = 'Scraping terminado: $_doneCount OK, $_errorCount con error';
    });
  }

  Future<void> _scrapeQueue(List<RomFile> queue) async {
    while (_isScraping && queue.isNotEmpty) {
      final rom = queue.removeAt(0);
      await _scrapeRom(rom);
      if (!mounted) {
        return;
      }
      setState(() {
        _processed += 1;
      });
    }
  }

  Future<void> _scrapeRom(RomFile rom) async {
    setState(() {
      rom.status = RomStatus.scraping;
      rom.message = 'Consultando ScreenScraper';
    });

    if ((rom.md5 ?? '').isEmpty ||
        (rom.crc ?? '').isEmpty ||
        (rom.sha1 ?? '').isEmpty) {
      _markError(rom, 'No se pudieron calcular los hashes');
      return;
    }

    final systemRoot = _systemRootForRom(rom);
    final cacheDir = p.join(systemRoot, '.retroscrape_cache');
    late final GameMetadata? metadata;
    try {
      metadata = await _service.fetchByHash(
        md5: rom.md5!,
        crc: rom.crc!,
        sha1: rom.sha1!,
        systemId: rom.systemId,
        romName: rom.innerPath ?? p.basename(rom.path),
        romSize: rom.size,
        language: _apiLanguage(),
        cacheDir: cacheDir,
        useCache: _useCache,
      );
      _syncQuotaFromService();
    } on ScreenScraperQuotaExceededException catch (error) {
      _handleQuotaExceeded(rom, error);
      return;
    }

    if (metadata == null) {
      _markError(rom, 'Juego no encontrado');
      return;
    }

    _applyMetadata(rom, metadata);
    final downloaded = await _downloadSelectedMedia(rom, metadata);

    if (_mixStyle != MixStyle.none) {
      await _createMixPlaceholder(rom);
    }

    setState(() {
      rom.scraped = true;
      rom.status = RomStatus.done;
      rom.message = downloaded == 0
          ? 'Metadatos OK, sin medios descargados'
          : 'Descargados $downloaded medios';
    });
  }

  Future<int> _downloadSelectedMedia(RomFile rom, GameMetadata metadata) async {
    var downloaded = 0;
    for (final mediaId in _selectedMedia) {
      final url = _urlFor(mediaId, metadata);
      if (url == null) {
        continue;
      }
      final choice = MediaCatalog.byId(mediaId);
      final systemRoot = _systemRootForRom(rom);
      final outDir = Directory(p.join(systemRoot, 'media', choice.folder));
      final outPath = p.join(
        outDir.path,
        '${_safeFileName(rom.name)}.${choice.extension}',
      );
      final outFile = File(outPath);
      if (outFile.existsSync() && !_overwriteMedia) {
        rom.localMediaPaths = {...rom.localMediaPaths, mediaId: outPath};
        continue;
      }

      final bytes = await _service.downloadBytes(url);
      if (bytes == null || bytes.isEmpty) {
        continue;
      }
      await outDir.create(recursive: true);
      await outFile.writeAsBytes(bytes, flush: true);
      rom.localMediaPaths = {...rom.localMediaPaths, mediaId: outPath};
      downloaded += 1;
    }
    return downloaded;
  }

  Future<void> _createMixPlaceholder(RomFile rom) async {
    final source = rom.localImagePath;
    if (source == null) {
      return;
    }
    final outDir = Directory(p.join(_systemRootForRom(rom), 'media', 'mix'));
    final outPath = p.join(outDir.path, '${_safeFileName(rom.name)}.png');
    await outDir.create(recursive: true);
    if (!File(outPath).existsSync() || _overwriteMedia) {
      await File(source).copy(outPath);
    }
    rom.localMediaPaths = {...rom.localMediaPaths, 'mix': outPath};
  }

  Future<void> _exportMetadata() async {
    if (_doneCount == 0) {
      _snack('Primero scrapea al menos una ROM', isError: true);
      return;
    }
    final paths = <String>[];
    if (_frontend == FrontendTarget.launchBox) {
      final path = await MetadataExporter.export(
        target: _frontend,
        roms: _romFiles,
        rootFolder: _exportRootFolder(),
        options: _exportOptions(),
      );
      if (path != null) {
        paths.add(path);
      }
    } else {
      for (final systemId in _romFiles.map((rom) => rom.systemId).toSet()) {
        final roms = _romFiles
            .where((rom) => rom.systemId == systemId && rom.scraped)
            .toList();
        if (roms.isEmpty) {
          continue;
        }
        final root = _systemRootForRom(roms.first);
        final path = await MetadataExporter.export(
          target: _frontend,
          roms: roms,
          rootFolder: root,
          options: _exportOptions(),
        );
        if (path != null) {
          paths.add(path);
        }
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _lastExportPath = paths.join('\n');
    });
    _snack('Exportado: ${paths.length} archivo(s)');
  }

  String _systemRootForRom(RomFile rom) {
    final configured = _systemFolders[rom.systemId];
    if (configured != null && configured.isNotEmpty) {
      return configured;
    }

    final profile = SystemCatalog.byId(rom.systemId);
    final normalized = rom.path.replaceAll('\\', '/');
    final parts = normalized.split('/');
    for (var i = parts.length - 2; i >= 0; i--) {
      final folderName = parts[i].toLowerCase().replaceAll(
            RegExp(r'[^a-z0-9]'),
            '',
          );
      if (profile.folderNames.contains(folderName)) {
        return parts.take(i + 1).join(Platform.pathSeparator);
      }
    }

    return p.dirname(rom.path);
  }

  String _exportRootFolder() {
    if (_romFolder.isNotEmpty) {
      return _romFolder;
    }
    if (_systemFolders.isNotEmpty) {
      final firstPath = _systemFolders.values.firstWhere(
        (path) => path.isNotEmpty,
        orElse: () => '',
      );
      if (firstPath.isNotEmpty) {
        return p.dirname(firstPath);
      }
    }
    return Directory.current.path;
  }

  ExportOptions _exportOptions() {
    return ExportOptions(
      nameCase: _nameCase,
      descriptionCase: _descriptionCase,
      genreCase: _genreCase,
      moveArticles: _moveArticles,
      useRegionInName: _useRegionInName,
      keepFilenameDecorations: _keepFilenameDecorations,
      keepUndecoratedFilename: _keepUndecoratedFilename,
      includeSynopsis: _includeSynopsis,
      gamelistMode: _gamelistMode,
      minimizeGamelist: _minimizeGamelist,
    );
  }

  Future<void> _showAddSystemDialog() async {
    final existing = _knownSystemIds.toSet();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('systems.add'.tr()),
          content: SizedBox(
            width: 520,
            height: 420,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                for (final profile in SystemCatalog.profiles)
                  OutlinedButton(
                    onPressed: existing.contains(profile.id)
                        ? null
                        : () {
                            Navigator.pop(dialogContext);
                            _selectSystemFolder(profile.id);
                          },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _systemLogo(profile, size: 34),
                        const SizedBox(height: 6),
                        Text(
                          profile.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('action.close'.tr()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSettingsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('settings.title'.tr()),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _userController,
                  decoration: InputDecoration(
                    labelText: 'settings.user'.tr(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passController,
                  decoration: InputDecoration(
                    labelText: 'settings.password'.tr(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('action.cancel'.tr()),
            ),
            FilledButton.icon(
              onPressed: () async {
                await _saveCredentials(showMessage: false);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                if (mounted) {
                  _snack('settings.saved'.tr());
                }
              },
              icon: const Icon(Icons.save),
              label: Text('action.save'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _forgetSystemFolder(int systemId) {
    setState(() {
      _systemFolders = Map<int, String>.from(_systemFolders)..remove(systemId);
      if (_selectedSystemId == systemId) {
        _selectedSystemId = null;
      }
    });
    _saveSettings();
    _scanRoms();
  }

  void _cancelScraping() {
    setState(() {
      _isScraping = false;
      _status = 'Cancelando...';
    });
  }

  String _apiLanguage() {
    return context.locale.languageCode == 'fr'
        ? 'fr'
        : (context.locale.languageCode == 'en' ? 'en' : 'es');
  }

  void _syncQuotaFromService() {
    final quota = _service.latestQuota;
    if (!mounted || quota == null) {
      return;
    }
    setState(() => _apiQuota = quota);
  }

  void _handleQuotaExceeded(
    RomFile rom,
    ScreenScraperQuotaExceededException error,
  ) {
    final quota = error.quota ?? _apiQuota;
    setState(() {
      _apiQuota = quota;
      _isScraping = false;
      _status = error.message;
      rom.status = RomStatus.error;
      rom.message = 'api.limit_reached_short'.tr();
    });
    if (quota != null) {
      _showQuotaLimitMessage(quota);
    } else {
      _snack(error.message, isError: true);
    }
  }

  void _showQuotaLimitMessage(ScreenScraperQuota quota) {
    _snack(
      'api.quota_reached'.tr(
        namedArgs: {
          'used': quota.usedToday.toString(),
          'max': quota.maxPerDay.toString(),
        },
      ),
      isError: true,
    );
  }

  void _applyMetadata(RomFile rom, GameMetadata metadata) {
    rom.title = _cleanDisplayTitle(metadata.name, fallback: rom.name);
    rom.description = metadata.description;
    rom.release = metadata.release;
    rom.developer = metadata.developer;
    rom.publisher = metadata.publisher;
    rom.genre = metadata.genre;
    rom.players = metadata.players;
    rom.rating = metadata.rating;
  }

  void _markError(RomFile rom, String message) {
    setState(() {
      rom.status = RomStatus.error;
      rom.message = message;
    });
  }

  String? _urlFor(String mediaId, GameMetadata metadata) {
    final choice = MediaCatalog.maybeById(mediaId);
    final hit = choice == null ? null : metadata.mediaUrlFor(choice.apiTypes);
    if (hit != null) {
      return hit;
    }
    switch (mediaId) {
      case 'box3d':
        return metadata.boxUrl ?? metadata.box2dUrl;
      case 'box2d':
        return metadata.box2dUrl ?? metadata.boxUrl;
      case 'screenshot':
        return metadata.screenshotUrl ?? metadata.titleScreenshotUrl;
      case 'title':
        return metadata.titleScreenshotUrl;
      case 'logo':
        return metadata.logoUrl;
      case 'fanart':
        return metadata.fanartUrl;
      case 'video':
        return metadata.videoUrl;
      case 'manual':
        return metadata.manualUrl;
      default:
        return null;
    }
  }

  List<MapEntry<String, String>> _previewMediaEntries(RomFile rom) {
    final ordered = <MapEntry<String, String>>[];
    final seen = <String>{};
    for (final id in MediaCatalog.previewPriority) {
      final path = rom.localMediaPaths[id];
      if (path != null && _isImageMedia(path)) {
        ordered.add(MapEntry(id, path));
        seen.add(id);
      }
    }
    for (final entry in rom.localMediaPaths.entries) {
      if (seen.contains(entry.key) || !_isImageMedia(entry.value)) {
        continue;
      }
      ordered.add(entry);
    }
    return ordered;
  }

  bool _isImageMedia(String path) {
    switch (p.extension(path).toLowerCase()) {
      case '.png':
      case '.jpg':
      case '.jpeg':
      case '.webp':
        return true;
      default:
        return false;
    }
  }

  MapEntry<String, String>? _currentPreviewMedia(RomFile rom) {
    final media = _previewMediaEntries(rom);
    if (media.isEmpty) {
      return null;
    }
    final index = _previewMediaIndex.clamp(0, media.length - 1).toInt();
    return media[index];
  }

  String _mediaLabel(String id) {
    if (id == 'mix') {
      return 'Mix';
    }
    return MediaCatalog.maybeById(id)?.label ?? id;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedRom;
    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr()),
        actions: [
          PopupMenuButton<Locale>(
            tooltip: 'language.change'.tr(),
            icon: const Icon(Icons.language),
            onSelected: context.setLocale,
            itemBuilder: (menuContext) => const [
              PopupMenuItem(
                value: Locale('es', 'ES'),
                child: Text('Español'),
              ),
              PopupMenuItem(
                value: Locale('en', 'US'),
                child: Text('English'),
              ),
              PopupMenuItem(
                value: Locale('fr', 'FR'),
                child: Text('Français'),
              ),
            ],
          ),
          Tooltip(
            message: 'action.rescan'.tr(),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isScanning || _isScraping ? null : _scanRoms,
            ),
          ),
          Tooltip(
            message: 'settings.title'.tr(),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettingsDialog,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _topWorkflow(),
          Expanded(
            child: Row(
              children: [
                SizedBox(width: 360, child: _leftPanel()),
                const VerticalDivider(width: 1),
                Expanded(child: _centerPanel(selected)),
                const VerticalDivider(width: 1),
                SizedBox(width: 380, child: _rightPanel(selected)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _topWorkflow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: const Color(0xFF131720),
      child: Row(
        children: [
          _metric('ROMs', _total.toString(), Icons.sports_esports),
          _metric('OK', _doneCount.toString(), Icons.check_circle),
          _metric('Errores', _errorCount.toString(), Icons.error),
          _apiQuotaMetric(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_status, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _isScanning ? null : _progress,
                  ),
                ],
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: _isScraping ? _cancelScraping : _startScraping,
            icon: Icon(_isScraping ? Icons.stop : Icons.play_arrow),
            label: Text(
              _isScraping ? 'action.cancel'.tr() : 'action.start_scraping'.tr(),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _doneCount == 0 || _isScraping ? null : _exportMetadata,
            icon: const Icon(Icons.file_download),
            label: Text('action.export'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _apiQuotaMetric() {
    final quota = _apiQuota;
    final color = quota == null
        ? Colors.white38
        : quota.isExceeded
            ? Theme.of(context).colorScheme.tertiary
            : quota.ratio >= 0.9
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.primary;
    final value = quota == null
        ? '--'
        : '${_compactNumber(quota.usedToday)}/${_compactNumber(quota.maxPerDay)}';
    final tooltip = quota == null
        ? 'api.usage_unknown'.tr()
        : 'api.usage_tooltip'.tr(
            namedArgs: {
              'used': quota.usedToday.toString(),
              'max': quota.maxPerDay.toString(),
              'remaining': quota.remaining.toString(),
            },
          );

    return Tooltip(
      message: tooltip,
      child: Container(
        width: 132,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A202B),
          border: Border.all(color: color.withValues(alpha: 0.42)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_sync, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'api.usage_today'.tr(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value, IconData icon) {
    return Container(
      width: 104,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A202B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _compactNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value >= 10000 ? 0 : 1)}k';
    }
    return value.toString();
  }

  Widget _leftPanel() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('library.title'.tr()),
        FilledButton.tonalIcon(
          onPressed: _isScraping ? null : _selectFolder,
          icon: const Icon(Icons.folder_open),
          label: Text(
            _romFolder.isEmpty
                ? 'library.choose_folder'.tr()
                : 'library.change_folder'.tr(),
          ),
        ),
        if (_romFolder.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _romFolder,
              style: const TextStyle(fontSize: 12, color: Colors.white60),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const SizedBox(height: 16),
        _sectionTitle('systems.title'.tr()),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              avatar: const Icon(Icons.all_inclusive, size: 18),
              label: Text('systems.all'.tr()),
              selected: _selectedSystemId == null,
              onSelected: (_) => setState(() {
                _selectedSystemId = null;
                _selectedRom = _romFiles.isEmpty ? null : _romFiles.first;
              }),
            ),
            for (final systemId in _knownSystemIds)
              ChoiceChip(
                avatar: _systemLogo(SystemCatalog.byId(systemId), size: 18),
                label: Text(
                  _shortSystemName(SystemCatalog.byId(systemId).name),
                ),
                selected: _selectedSystemId == systemId,
                onSelected: (_) => setState(() {
                  _selectedSystemId = systemId;
                  final visible = _visibleRoms;
                  _selectedRom = visible.isEmpty ? null : visible.first;
                }),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isScraping ? null : _showAddSystemDialog,
                icon: const Icon(Icons.add),
                label: Text('systems.add'.tr()),
              ),
            ),
          ],
        ),
        if (_selectedSystemId != null) ...[
          const SizedBox(height: 8),
          _systemPathEditor(_selectedSystemId!),
        ],
        const SizedBox(height: 20),
        _systemsSummary(),
        const SizedBox(height: 20),
        _sectionTitle('output.title'.tr()),
        SegmentedButton<FrontendTarget>(
          segments: const [
            ButtonSegment(
              value: FrontendTarget.emulationStation,
              icon: Icon(Icons.view_list),
              label: Text('ES'),
            ),
            ButtonSegment(
              value: FrontendTarget.launchBox,
              icon: Icon(Icons.grid_view),
              label: Text('LaunchBox'),
            ),
          ],
          selected: {_frontend},
          onSelectionChanged: (value) {
            setState(() => _frontend = value.first);
            _saveSettings();
          },
        ),
      ],
    );
  }

  Widget _centerPanel(RomFile? selected) {
    final visibleRoms = _visibleRoms;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: 'roms.detected'.tr(),
            ),
            child: Text(
              _selectedSystemId == null
                  ? '${_romFiles.length} archivos compatibles'
                  : '${visibleRoms.length} archivos de ${SystemCatalog.byId(_selectedSystemId!).name}',
            ),
          ),
        ),
        Expanded(
          child: visibleRoms.isEmpty
              ? Center(child: Text('library.choose_to_start'.tr()))
              : ListView.builder(
                  itemCount: visibleRoms.length,
                  itemBuilder: (context, index) {
                    final rom = visibleRoms[index];
                    final selected = identical(rom, _selectedRom);
                    return ListTile(
                      selected: selected,
                      leading: Icon(
                        _iconFor(rom.status),
                        color: _colorFor(rom.status),
                      ),
                      title: Text(
                        _cleanDisplayTitle(
                          rom.title ?? rom.name,
                          fallback: rom.name,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${rom.systemName}  |  ${rom.message.isEmpty ? rom.ext : rom.message}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: rom.localImagePath == null
                          ? null
                          : const Icon(Icons.image, color: Colors.tealAccent),
                      onTap: () => setState(() {
                        _selectedRom = rom;
                        _previewMediaIndex = 0;
                      }),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _rightPanel(RomFile? selected) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                  icon: const Icon(Icons.badge_outlined),
                  text: 'tab.metadata'.tr()),
              Tab(
                  icon: const Icon(Icons.image_outlined),
                  text: 'tab.media'.tr()),
              Tab(icon: const Icon(Icons.list_alt), text: 'tab.gamelist'.tr()),
              Tab(
                  icon: const Icon(Icons.visibility_outlined),
                  text: 'tab.preview'.tr()),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _metadataOptionsPanel(),
                _mediaOptionsPanel(),
                _gamelistOptionsPanel(),
                _previewPanel(selected),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelList(List<Widget> children) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: children,
    );
  }

  Widget _metadataOptionsPanel() {
    return _panelList([
      _sectionTitle('metadata.text_case'.tr()),
      _caseSelector('metadata.name'.tr(), _nameCase,
          (value) => setState(() => _nameCase = value)),
      const SizedBox(height: 8),
      _caseSelector('metadata.description'.tr(), _descriptionCase,
          (value) => setState(() => _descriptionCase = value)),
      const SizedBox(height: 8),
      _caseSelector('metadata.genre'.tr(), _genreCase,
          (value) => setState(() => _genreCase = value)),
      const SizedBox(height: 16),
      _settingsSwitch(
        'metadata.move_articles'.tr(),
        _moveArticles,
        (value) => setState(() => _moveArticles = value),
      ),
      _settingsSwitch(
        'metadata.use_region'.tr(),
        _useRegionInName,
        (value) => setState(() => _useRegionInName = value),
      ),
      _settingsSwitch(
        'metadata.keep_decorations'.tr(),
        _keepFilenameDecorations,
        (value) => setState(() => _keepFilenameDecorations = value),
      ),
      _settingsSwitch(
        'metadata.keep_undecorated'.tr(),
        _keepUndecoratedFilename,
        (value) => setState(() => _keepUndecoratedFilename = value),
      ),
      _settingsSwitch(
        'metadata.include_synopsis'.tr(),
        _includeSynopsis,
        (value) => setState(() => _includeSynopsis = value),
      ),
      const SizedBox(height: 8),
      FilledButton.tonalIcon(
        onPressed: _saveSettings,
        icon: const Icon(Icons.save),
        label: Text('action.save_options'.tr()),
      ),
    ]);
  }

  Widget _mediaOptionsPanel() {
    return _panelList([
      _sectionTitle('media.downloaded'.tr()),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final choice in MediaCatalog.choices)
            FilterChip(
              label: Text(choice.label),
              selected: _selectedMedia.contains(choice.id),
              onSelected: (value) {
                setState(() {
                  value
                      ? _selectedMedia.add(choice.id)
                      : _selectedMedia.remove(choice.id);
                });
                _saveSettings();
              },
            ),
        ],
      ),
      const SizedBox(height: 16),
      _sectionTitle('media.mix'.tr()),
      SegmentedButton<MixStyle>(
        segments: [
          ButtonSegment(
              value: MixStyle.none,
              icon: const Icon(Icons.hide_image),
              label: Text('common.no'.tr())),
          ButtonSegment(
              value: MixStyle.detailed,
              icon: const Icon(Icons.dashboard_customize),
              label: Text('mix.detail'.tr())),
          ButtonSegment(
              value: MixStyle.poster,
              icon: const Icon(Icons.photo_size_select_actual),
              label: Text('mix.poster'.tr())),
        ],
        selected: {_mixStyle},
        onSelectionChanged: (value) {
          setState(() => _mixStyle = value.first);
          _saveSettings();
        },
      ),
      const SizedBox(height: 12),
      _settingsSwitch('media.use_cache'.tr(), _useCache,
          (value) => setState(() => _useCache = value)),
      _settingsSwitch('media.overwrite'.tr(), _overwriteMedia,
          (value) => setState(() => _overwriteMedia = value)),
      _settingsSwitch('media.cleanup'.tr(), _cleanupMedia,
          (value) => setState(() => _cleanupMedia = value)),
      _settingsSwitch('media.optimize'.tr(), _optimizeMedia,
          (value) => setState(() => _optimizeMedia = value)),
      const SizedBox(height: 12),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('media.parallel'.tr()),
        subtitle: Slider(
          min: 1,
          max: 5,
          divisions: 4,
          value: _parallelism.toDouble(),
          label: _parallelism.toString(),
          onChanged: _isScraping
              ? null
              : (value) {
                  setState(() => _parallelism = value.round());
                  _saveSettings();
                },
        ),
        trailing: Text('x$_parallelism'),
      ),
    ]);
  }

  Widget _gamelistOptionsPanel() {
    return _panelList([
      _sectionTitle('gamelist.type'.tr()),
      SegmentedButton<FrontendTarget>(
        segments: const [
          ButtonSegment(
              value: FrontendTarget.emulationStation,
              icon: Icon(Icons.view_list),
              label: Text('ES')),
          ButtonSegment(
              value: FrontendTarget.launchBox,
              icon: Icon(Icons.grid_view),
              label: Text('LaunchBox')),
        ],
        selected: {_frontend},
        onSelectionChanged: (value) {
          setState(() => _frontend = value.first);
          _saveSettings();
        },
      ),
      const SizedBox(height: 16),
      _sectionTitle('gamelist.update'.tr()),
      SegmentedButton<GamelistUpdateMode>(
        segments: [
          ButtonSegment(
              value: GamelistUpdateMode.overwrite,
              icon: const Icon(Icons.edit_document),
              label: Text('gamelist.recreate'.tr())),
          ButtonSegment(
              value: GamelistUpdateMode.backupAndUpdate,
              icon: const Icon(Icons.backup),
              label: Text('gamelist.backup'.tr())),
          ButtonSegment(
              value: GamelistUpdateMode.updateOnly,
              icon: const Icon(Icons.update),
              label: Text('gamelist.update_only'.tr())),
        ],
        selected: {_gamelistMode},
        onSelectionChanged: (value) {
          setState(() => _gamelistMode = value.first);
          _saveSettings();
        },
      ),
      const SizedBox(height: 12),
      _settingsSwitch('gamelist.minimize'.tr(), _minimizeGamelist,
          (value) => setState(() => _minimizeGamelist = value)),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: _doneCount == 0 || _isScraping ? null : _exportMetadata,
        icon: const Icon(Icons.file_download),
        label: Text('gamelist.export'.tr()),
      ),
      if (_lastExportPath != null) ...[
        const SizedBox(height: 16),
        _sectionTitle('gamelist.last_export'.tr()),
        SelectableText(_lastExportPath!, style: const TextStyle(fontSize: 12)),
      ],
    ]);
  }

  Widget _previewPanel(RomFile? selected) {
    return _panelList([
      _sectionTitle('preview.title'.tr()),
      if (selected == null)
        Text('preview.select_rom'.tr())
      else ...[
        _previewMediaNavigator(selected),
        const SizedBox(height: 8),
        _preview(selected),
      ],
    ]);
  }

  Widget _previewMediaNavigator(RomFile rom) {
    final media = _previewMediaEntries(rom);
    final hasMedia = media.isNotEmpty;
    final currentIndex =
        hasMedia ? _previewMediaIndex.clamp(0, media.length - 1).toInt() : 0;
    final current = hasMedia ? media[currentIndex] : null;
    return Row(
      children: [
        IconButton.outlined(
          tooltip: 'Media anterior',
          icon: const Icon(Icons.chevron_left),
          onPressed: media.length <= 1
              ? null
              : () => setState(() {
                    _previewMediaIndex =
                        (_previewMediaIndex - 1 + media.length) % media.length;
                  }),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            current == null
                ? 'Sin media visual descargada'
                : '${_mediaLabel(current.key)}  ${currentIndex + 1}/${media.length}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          tooltip: 'Media siguiente',
          icon: const Icon(Icons.chevron_right),
          onPressed: media.length <= 1
              ? null
              : () => setState(() {
                    _previewMediaIndex =
                        (_previewMediaIndex + 1) % media.length;
                  }),
        ),
      ],
    );
  }

  Widget _systemsSummary() {
    final systems = _knownSystemIds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('systems.to_scrape'.tr()),
        if (systems.isEmpty)
          Text(
            'systems.none_detected'.tr(),
            style: const TextStyle(color: Colors.white54),
          )
        else
          for (final systemId in systems)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  _systemLogo(SystemCatalog.byId(systemId), size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      SystemCatalog.byId(systemId).name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _romFiles
                        .where((rom) => rom.systemId == systemId)
                        .length
                        .toString(),
                    style: const TextStyle(color: Colors.white60),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  Widget _caseSelector(
    String label,
    TextCaseMode value,
    ValueChanged<TextCaseMode> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        SegmentedButton<TextCaseMode>(
          segments: [
            ButtonSegment(
                value: TextCaseMode.asIs, label: Text('case.as_is'.tr())),
            ButtonSegment(
                value: TextCaseMode.lower, label: Text('case.lower'.tr())),
            ButtonSegment(
                value: TextCaseMode.upper, label: Text('case.upper'.tr())),
          ],
          selected: {value},
          onSelectionChanged: (selection) {
            onChanged(selection.first);
            _saveSettings();
          },
        ),
      ],
    );
  }

  Widget _settingsSwitch(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      onChanged: (next) {
        onChanged(next);
        _saveSettings();
      },
    );
  }

  Widget _preview(RomFile rom) {
    final previewMedia = _currentPreviewMedia(rom);
    final image = previewMedia?.value ?? rom.localImagePath;
    final title = _cleanDisplayTitle(rom.title ?? rom.name, fallback: rom.name);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0D12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: image == null
                    ? const Center(
                        child: Icon(
                          Icons.videogame_asset,
                          size: 54,
                          color: Colors.white38,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(image), fit: BoxFit.contain),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              rom.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.white38),
            ),
            const SizedBox(height: 6),
            Text(
              rom.systemName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 8),
            if (rom.description != null && !_looksLikeRawMap(rom.description!))
              Text(
                rom.description!,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (rom.genre != null) Chip(label: Text(rom.genre!)),
                if (rom.players != null)
                  Chip(label: Text('${rom.players} jugador(es)')),
                if (rom.release != null) Chip(label: Text(rom.release!)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _systemPathEditor(int systemId) {
    final profile = SystemCatalog.byId(systemId);
    final path = _systemFolders[systemId] ?? '';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _systemLogo(profile, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    profile.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Cambiar ruta',
                  onPressed:
                      _isScraping ? null : () => _selectSystemFolder(systemId),
                  icon: const Icon(Icons.folder_open),
                ),
                IconButton(
                  tooltip: 'Quitar ruta manual',
                  onPressed:
                      _isScraping || !_systemFolders.containsKey(systemId)
                          ? null
                          : () => _forgetSystemFolder(systemId),
                  icon: const Icon(Icons.link_off),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              path.isEmpty
                  ? 'Ruta inferida automaticamente desde la carpeta raiz'
                  : path,
              style: const TextStyle(fontSize: 12, color: Colors.white60),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              'Media: ${path.isEmpty ? 'carpeta del sistema detectada' : p.join(path, 'media')}',
              style: const TextStyle(fontSize: 11, color: Colors.white38),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _systemLogo(SystemProfile profile, {required double size}) {
    final text = _logoText(profile.name);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _logoColor(profile.id),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Color _logoColor(int systemId) {
    const colors = [
      Color(0xFF00C2B8),
      Color(0xFFE5B54A),
      Color(0xFFE96F53),
      Color(0xFF9BE564),
      Color(0xFF6FA8FF),
      Color(0xFFFF8CC6),
    ];
    return colors[systemId.abs() % colors.length];
  }

  String _logoText(String name) {
    final words = name
        .replaceAll('/', ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      return '?';
    }
    if (words.length == 1) {
      final end = words.first.length < 3 ? words.first.length : 3;
      return words.first.substring(0, end).toUpperCase();
    }
    return words.take(2).map((word) => word[0]).join().toUpperCase();
  }

  String _shortSystemName(String name) {
    return name
        .replaceAll('Nintendo ', '')
        .replaceAll('Sega ', '')
        .replaceAll('Sony ', '')
        .replaceAll(' / ', '/');
  }

  Widget _bottomBar() {
    return BottomAppBar(
      height: 52,
      child: Row(
        children: [
          const Icon(Icons.storage, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _romFolder.isEmpty ? 'Sin carpeta seleccionada' : _romFolder,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Text('$_processed / $_total'),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white70,
        ),
      ),
    );
  }

  IconData _iconFor(RomStatus status) {
    switch (status) {
      case RomStatus.pending:
        return Icons.radio_button_unchecked;
      case RomStatus.scraping:
        return Icons.sync;
      case RomStatus.done:
        return Icons.check_circle;
      case RomStatus.error:
        return Icons.error;
    }
  }

  Color _colorFor(RomStatus status) {
    switch (status) {
      case RomStatus.pending:
        return Colors.white38;
      case RomStatus.scraping:
        return Theme.of(context).colorScheme.secondary;
      case RomStatus.done:
        return Colors.greenAccent;
      case RomStatus.error:
        return Theme.of(context).colorScheme.tertiary;
    }
  }

  void _snack(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.teal,
      ),
    );
  }

  String _safeFileName(String input) {
    final normalized = input.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return normalized.isEmpty ? 'rom' : normalized;
  }

  String _cleanDisplayTitle(String input, {required String fallback}) {
    final text = input.trim();
    if (_looksLikeRawMap(text)) {
      return fallback;
    }
    return text.isEmpty ? fallback : text;
  }

  bool _looksLikeRawMap(String input) {
    final text = input.trim();
    return text.startsWith('{') ||
        text.startsWith('[') ||
        text.contains('romfilename:');
  }

  FrontendTarget _parseFrontend(String value) {
    return FrontendTarget.values.firstWhere(
      (target) => target.name == value,
      orElse: () => FrontendTarget.emulationStation,
    );
  }

  MixStyle _parseMix(String value) {
    return MixStyle.values.firstWhere(
      (mix) => mix.name == value,
      orElse: () => MixStyle.detailed,
    );
  }

  TextCaseMode _parseTextCase(String value) {
    return TextCaseMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => TextCaseMode.asIs,
    );
  }

  GamelistUpdateMode _parseGamelistMode(String value) {
    return GamelistUpdateMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => GamelistUpdateMode.backupAndUpdate,
    );
  }
}

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

import '../../models/rom.dart';
import '../../models/scraper_settings.dart';

class MetadataExporter {
  static Future<String> exportEmulationStation({
    required List<RomFile> roms,
    required String rootFolder,
    ExportOptions options = const ExportOptions(),
  }) async {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element(
      'gameList',
      nest: () {
        for (final rom in roms.where((rom) => rom.scraped)) {
          builder.element(
            'game',
            nest: () {
              _element(builder, 'path', './${_relative(rootFolder, rom.path)}');
              _element(builder, 'name', _gameName(rom, options));
              if (options.includeSynopsis) {
                _element(
                  builder,
                  'desc',
                  _applyCase(rom.description, options.descriptionCase),
                );
              }
              _element(
                builder,
                'image',
                _media(rootFolder, rom, 'mix') ??
                    _media(rootFolder, rom, 'box3d') ??
                    _media(rootFolder, rom, 'box2d') ??
                    _media(rootFolder, rom, 'screenshot'),
              );
              _element(
                builder,
                'thumbnail',
                _media(rootFolder, rom, 'box2d') ??
                    _media(rootFolder, rom, 'box3d') ??
                    _media(rootFolder, rom, 'screenshot'),
              );
              _element(builder, 'marquee', _media(rootFolder, rom, 'logo'));
              _element(builder, 'video', _media(rootFolder, rom, 'video'));
              _element(builder, 'manual', _media(rootFolder, rom, 'manual'));
              _element(builder, 'fanart', _media(rootFolder, rom, 'fanart'));
              _element(builder, 'titleshot', _media(rootFolder, rom, 'title'));
              _element(
                builder,
                'boxart',
                _media(rootFolder, rom, 'box2d') ??
                    _media(rootFolder, rom, 'box3d'),
              );
              _element(
                builder,
                'screenshot',
                _media(rootFolder, rom, 'screenshot'),
              );
              _element(builder, 'mix', _media(rootFolder, rom, 'mix'));
              _element(builder, 'wheel', _media(rootFolder, rom, 'logo'));
              _element(builder, 'box2d', _media(rootFolder, rom, 'box2d'));
              _element(builder, 'box3d', _media(rootFolder, rom, 'box3d'));
              _element(builder, 'releasedate', _esDate(rom.release));
              _element(builder, 'developer', rom.developer);
              _element(builder, 'publisher', rom.publisher);
              _element(
                  builder, 'genre', _applyCase(rom.genre, options.genreCase));
              _element(builder, 'players', rom.players?.toString());
              _element(
                builder,
                'rating',
                rom.rating == null
                    ? null
                    : (rom.rating! / 20).clamp(0, 1).toStringAsFixed(2),
              );
            },
          );
        }
      },
    );

    final out = File(p.join(rootFolder, 'gamelist.xml'));
    if (out.existsSync() &&
        options.gamelistMode == GamelistUpdateMode.backupAndUpdate) {
      final backup = File(p.join(rootFolder, 'gamelist.xml.bak'));
      await out.copy(backup.path);
    }
    await out.writeAsString(
      builder.buildDocument().toXmlString(
            pretty: !options.minimizeGamelist,
            indent: options.minimizeGamelist ? '' : '  ',
          ),
    );
    return out.path;
  }

  static Future<String> exportLaunchBox({
    required List<RomFile> roms,
    required String rootFolder,
    ExportOptions options = const ExportOptions(),
  }) async {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element(
      'LaunchBox',
      nest: () {
        for (final rom in roms.where((rom) => rom.scraped)) {
          builder.element(
            'Game',
            nest: () {
              _element(builder, 'Title', _gameName(rom, options));
              _element(builder, 'ApplicationPath', rom.path);
              _element(builder, 'Platform', rom.systemName);
              if (options.includeSynopsis) {
                _element(
                  builder,
                  'Notes',
                  _applyCase(rom.description, options.descriptionCase),
                );
              }
              _element(builder, 'Developer', rom.developer);
              _element(builder, 'Publisher', rom.publisher);
              _element(
                  builder, 'Genre', _applyCase(rom.genre, options.genreCase));
              _element(builder, 'ReleaseDate', rom.release);
              _element(builder, 'MaxPlayers', rom.players?.toString());
              _element(
                builder,
                'CommunityStarRating',
                rom.rating?.toStringAsFixed(1),
              );
            },
          );
        }
      },
    );

    final out = File(p.join(rootFolder, 'LaunchBox.xml'));
    await out.writeAsString(
      builder.buildDocument().toXmlString(
            pretty: !options.minimizeGamelist,
            indent: options.minimizeGamelist ? '' : '  ',
          ),
    );
    return out.path;
  }

  static Future<String?> export({
    required FrontendTarget target,
    required List<RomFile> roms,
    required String rootFolder,
    ExportOptions options = const ExportOptions(),
  }) {
    switch (target) {
      case FrontendTarget.emulationStation:
        return exportEmulationStation(
          roms: roms,
          rootFolder: rootFolder,
          options: options,
        );
      case FrontendTarget.launchBox:
        return exportLaunchBox(
          roms: roms,
          rootFolder: rootFolder,
          options: options,
        );
    }
  }

  static String? _media(String rootFolder, RomFile rom, String id) {
    final path = rom.localMediaPaths[id];
    if (path == null || path.isEmpty) {
      return null;
    }
    return './${_relative(rootFolder, path)}';
  }

  static String _gameName(RomFile rom, ExportOptions options) {
    final source = (rom.title == null || rom.title!.trim().isEmpty)
        ? rom.name
        : rom.title!;
    var clean = p.basenameWithoutExtension(source.trim());
    if (!options.keepFilenameDecorations) {
      clean = clean.replaceAll(RegExp(r'\([^)]*\)|\[[^\]]*\]'), ' ').trim();
    }
    clean = clean
        .replaceAll(RegExp(r'[_\-.]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (options.moveArticles) {
      clean = _moveLeadingArticle(clean);
    }
    if (options.useRegionInName) {
      final region = _firstRegion(source);
      if (region != null && !clean.contains(region)) {
        clean = '$clean ($region)';
      }
    }
    return _applyCase(clean.isEmpty ? rom.name : clean, options.nameCase) ??
        rom.name;
  }

  static String? _applyCase(String? value, TextCaseMode mode) {
    if (value == null) {
      return null;
    }
    switch (mode) {
      case TextCaseMode.asIs:
        return value;
      case TextCaseMode.lower:
        return value.toLowerCase();
      case TextCaseMode.upper:
        return value.toUpperCase();
    }
  }

  static String _moveLeadingArticle(String value) {
    final match = RegExp(r'^(the|a|an|el|la|los|las|le|les|un|une)\s+(.+)$',
            caseSensitive: false)
        .firstMatch(value);
    if (match == null) {
      return value;
    }
    return '${match.group(2)}, ${match.group(1)}';
  }

  static String? _firstRegion(String value) {
    final match = RegExp(
            r'\(([^)]*(USA|Europe|Japan|World|Spain|France|Germany)[^)]*)\)',
            caseSensitive: false)
        .firstMatch(value);
    return match?.group(1);
  }

  static String _relative(String rootFolder, String filePath) {
    return p.relative(filePath, from: rootFolder).replaceAll('\\', '/');
  }

  static String? _esDate(String? value) {
    if (value == null || value.length < 4) {
      return value;
    }
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 8) {
      return '${digits.substring(0, 8)}T000000';
    }
    return value;
  }

  static void _element(XmlBuilder builder, String name, String? value) {
    if (value == null || value.trim().isEmpty) {
      return;
    }
    builder.element(name, nest: value.trim());
  }
}

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../../models/rom.dart';
import '../../models/system_profile.dart';

class RomScanner {
  static const _ignoredFolders = {
    'media',
    'images',
    'downloaded_images',
    'downloaded_media',
    '.retroscrape_cache',
    'videos',
    'manuals',
    'screenshots',
    'box3d',
    'box2d',
    'logos',
    'fanart',
    'mix',
  };

  Future<List<RomFile>> scan(
    String folderPath, {
    SystemProfile? forcedProfile,
  }) async {
    if (folderPath.trim().isEmpty) {
      return [];
    }

    final folder = Directory(folderPath);
    if (!folder.existsSync()) {
      return [];
    }

    final roms = <RomFile>[];

    await _scanDirectory(folder, roms, forcedProfile: forcedProfile);

    roms.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return roms;
  }

  Future<void> _scanDirectory(
    Directory folder,
    List<RomFile> roms, {
    SystemProfile? forcedProfile,
  }) async {
    await for (final entity in folder.list(followLinks: false)) {
      if (entity is Directory) {
        final name = p.basename(entity.path).toLowerCase();
        if (_ignoredFolders.contains(name)) {
          continue;
        }
        await _scanDirectory(entity, roms, forcedProfile: forcedProfile);
        continue;
      }
      if (entity is! File) {
        continue;
      }

      final ext = p.extension(entity.path).toLowerCase();
      if (ext == '.zip') {
        final zippedRoms = await _scanZip(entity, forcedProfile: forcedProfile);
        if (zippedRoms.isNotEmpty) {
          roms.addAll(zippedRoms);
          continue;
        }
      }

      if (!SystemCatalog.supportedExtensions.contains(ext)) {
        continue;
      }

      final profile = forcedProfile ?? SystemCatalog.detect(ext, entity.path);

      final rom = RomFile(
        path: entity.path,
        name: p.basenameWithoutExtension(entity.path),
        ext: ext,
        systemId: profile.id,
        systemName: profile.name,
        size: await entity.length(),
      );

      try {
        final bytes = await entity.readAsBytes();
        rom.md5 = md5.convert(bytes).toString();
        rom.sha1 = sha1.convert(bytes).toString();
        rom.crc = _crc32Hex(bytes);
      } catch (_) {
        rom.md5 = null;
      }

      roms.add(rom);
    }
  }

  Future<List<RomFile>> _scanZip(
    File zipFile, {
    SystemProfile? forcedProfile,
  }) async {
    final roms = <RomFile>[];

    try {
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes, verify: false);

      for (final entry in archive.files) {
        if (!entry.isFile) {
          continue;
        }

        final ext = p.extension(entry.name).toLowerCase();
        if (!SystemCatalog.supportedExtensions.contains(ext)) {
          continue;
        }

        final profile = forcedProfile ??
            SystemCatalog.detect(ext, '${zipFile.path}/${entry.name}');

        final rom = RomFile(
          path: zipFile.path,
          innerPath: entry.name,
          name: p.basenameWithoutExtension(entry.name),
          ext: ext,
          systemId: profile.id,
          systemName: profile.name,
          size: entry.size,
        );

        final content = entry.content;
        if (content is List<int>) {
          rom.md5 = md5.convert(content).toString();
          rom.sha1 = sha1.convert(content).toString();
          rom.crc = _crc32Hex(content);
        }

        roms.add(rom);
      }
    } catch (_) {
      // Keep scanning even when one archive is corrupted.
    }

    return roms;
  }

  String _crc32Hex(List<int> bytes) {
    var crc = 0xffffffff;
    for (final byte in bytes) {
      crc ^= byte;
      for (var i = 0; i < 8; i++) {
        final mask = -(crc & 1);
        crc = (crc >> 1) ^ (0xedb88320 & mask);
      }
    }
    return ((crc ^ 0xffffffff) & 0xffffffff)
        .toRadixString(16)
        .padLeft(8, '0')
        .toUpperCase();
  }
}

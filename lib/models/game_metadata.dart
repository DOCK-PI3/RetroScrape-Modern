class GameMetadata {
  const GameMetadata({
    required this.id,
    required this.name,
    this.description,
    this.release,
    this.developer,
    this.publisher,
    this.genre,
    this.players,
    this.rating,
    this.family,
    this.serial,
    this.boxUrl,
    this.box2dUrl,
    this.screenshotUrl,
    this.titleScreenshotUrl,
    this.logoUrl,
    this.fanartUrl,
    this.videoUrl,
    this.manualUrl,
  });

  final int id;
  final String name;
  final String? description;
  final String? release;
  final String? developer;
  final String? publisher;
  final String? genre;
  final int? players;
  final double? rating;
  final String? family;
  final String? serial;
  final String? boxUrl;
  final String? box2dUrl;
  final String? screenshotUrl;
  final String? titleScreenshotUrl;
  final String? logoUrl;
  final String? fanartUrl;
  final String? videoUrl;
  final String? manualUrl;

  factory GameMetadata.fromApi(Map<String, dynamic> game) {
    final romName = _romDisplayName(game['roms']) ??
        _romDisplayName(game['rom']) ??
        _romDisplayName(game['romnom']);
    final names = game['noms'];
    final title = _displayText(game['nom']) ?? _localizedText(names, 'nom');

    final synopsis = game['synopsis'];
    String? description;
    if (synopsis is List && synopsis.isNotEmpty) {
      description = _asString((synopsis.first as Map?)?['text']);
    } else if (synopsis is Map) {
      description = _asString(
        synopsis['text'] ??
            synopsis['synopsis_es'] ??
            synopsis['synopsis_en'] ??
            synopsis['synopsis_fr'],
      );
    }

    String? boxUrl;
    String? box2dUrl;
    String? screenshotUrl;
    String? titleScreenshotUrl;
    String? logoUrl;
    String? fanartUrl;
    String? videoUrl;
    String? manualUrl;

    void assignMedia(String? type, String? url) {
      if (type == null || url == null) return;
      if (boxUrl == null && (type == 'box-3d' || type == 'box3d')) {
        boxUrl = url;
      }
      if (box2dUrl == null && (type == 'box-2d' || type == 'box2dfront')) {
        box2dUrl = url;
      }
      if (screenshotUrl == null && (type == 'ss' || type == 'screenshot')) {
        screenshotUrl = url;
      }
      if (titleScreenshotUrl == null &&
          (type == 'sstitle' || type == 'ss-title')) {
        titleScreenshotUrl = url;
      }
      if (logoUrl == null &&
          (type == 'wheel' || type == 'marquee' || type == 'logo')) {
        logoUrl = url;
      }
      if (fanartUrl == null && (type == 'fanart' || type == 'bezel')) {
        fanartUrl = url;
      }
      if (videoUrl == null && type == 'video') {
        videoUrl = url;
      }
      if (manualUrl == null && (type == 'manuel' || type == 'manual')) {
        manualUrl = url;
      }
    }

    final medias = game['medias'];
    if (medias is List) {
      for (final media in medias) {
        if (media is! Map) {
          continue;
        }
        final type = _asString(media['type'])?.toLowerCase() ??
            _asString(media['media'])?.toLowerCase();
        final url = _urlFromMediaValue(media['url']) ??
            _asString(media['url_image']) ??
            _asString(media['url_video']) ??
            _asString(media['url_manual']) ??
            _urlFromMediaValue(media);
        assignMedia(type, url);
      }
    } else if (medias is Map) {
      for (final entry in medias.entries) {
        final key = entry.key.toString().toLowerCase();
        final url = _urlFromMediaValue(entry.value);
        if (key.contains('box3d') || key.contains('box-3d')) {
          assignMedia('box-3d', url);
        }
        if (key.contains('box2d') || key.contains('box-2d')) {
          assignMedia('box-2d', url);
        }
        if (key.contains('screenshot') || key.endsWith('_ss')) {
          assignMedia('screenshot', url);
        }
        if (key.contains('sstitle') || key.contains('title')) {
          assignMedia('sstitle', url);
        }
        if (key.contains('wheel') ||
            key.contains('logo') ||
            key.contains('marquee')) {
          assignMedia('wheel', url);
        }
        if (key.contains('fanart')) {
          assignMedia('fanart', url);
        }
        if (key.contains('video')) {
          assignMedia('video', url);
        }
        if (key.contains('manuel') || key.contains('manual')) {
          assignMedia('manual', url);
        }
      }
    }

    return GameMetadata(
      id: _asInt(game['id']) ?? 0,
      name: title ?? romName ?? 'Unknown',
      description: description,
      release: _fromListEntry(game['dates'], 'date') ??
          _fromRegionalMap(game['dates'], 'date'),
      developer: _fromListEntry(game['developpeur'], 'text') ??
          _displayText(game['developpeur']),
      publisher: _fromListEntry(game['editeur'], 'text') ??
          _displayText(game['editeur']),
      genre: _fromListEntry(game['genres'], 'text') ??
          _fromRegionalMap(game['genres'], 'genres'),
      players: _asInt(_fromListEntry(game['joueurs'], 'text')),
      rating: _asDouble(game['note']),
      family: _fromListEntry(game['familles'], 'text'),
      serial: _fromListEntry(game['roms'], 'serial'),
      boxUrl: boxUrl,
      box2dUrl: box2dUrl,
      screenshotUrl: screenshotUrl,
      titleScreenshotUrl: titleScreenshotUrl,
      logoUrl: logoUrl,
      fanartUrl: fanartUrl,
      videoUrl: videoUrl,
      manualUrl: manualUrl,
    );
  }

  static String? _fromRegionalMap(dynamic value, String prefix) {
    if (value is! Map) {
      return null;
    }
    for (final suffix in ['_es', '_en', '_eu', '_us', '_jp', '_fr']) {
      final hit = _asString(value['$prefix$suffix']);
      if (hit != null) {
        return hit;
      }
    }
    return null;
  }

  static String? _localizedText(dynamic value, String prefix) {
    if (value is! Map) {
      return _displayText(value);
    }
    for (final key in [
      '${prefix}_es',
      '${prefix}_en',
      '${prefix}_eu',
      '${prefix}_us',
      '${prefix}_wor',
      '${prefix}_ss',
      prefix,
      'text',
    ]) {
      final hit = _displayText(value[key]);
      if (hit != null) {
        return hit;
      }
    }
    for (final entry in value.values) {
      final hit = _displayText(entry);
      if (hit != null) {
        return hit;
      }
    }
    return null;
  }

  static String? _romDisplayName(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return _romDisplayName(value.first);
    }
    if (value is Map) {
      return _displayText(
        value['romfilename'] ??
            value['romnom'] ??
            value['filename'] ??
            value['name'] ??
            value['nom'],
      );
    }
    return _displayText(value);
  }

  static String? _displayText(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Map) {
      return null;
    }
    if (value is List) {
      return value.isEmpty ? null : _displayText(value.first);
    }
    final text = value.toString().trim();
    if (text.isEmpty || text.startsWith('{') || text.startsWith('[')) {
      return null;
    }
    return text;
  }

  static String? _urlFromMediaValue(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      final text = value.trim();
      return text.startsWith('http') ? text : null;
    }
    if (value is Map) {
      for (final key in const [
        'url',
        'url_image',
        'url_video',
        'url_manual',
        'media',
        'download',
      ]) {
        final hit = _urlFromMediaValue(value[key]);
        if (hit != null) {
          return hit;
        }
      }
      for (final entry in value.values) {
        final hit = _urlFromMediaValue(entry);
        if (hit != null) {
          return hit;
        }
      }
    }
    return null;
  }

  static String? _fromListEntry(dynamic value, String field) {
    if (value is List && value.isNotEmpty && value.first is Map) {
      return _asString((value.first as Map)[field]);
    }
    if (value is Map) {
      return _asString(value[field]);
    }
    return null;
  }

  static String? _asString(dynamic value) {
    return _displayText(value);
  }

  static int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  static double? _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim().replaceAll(',', '.'));
    }
    return null;
  }
}

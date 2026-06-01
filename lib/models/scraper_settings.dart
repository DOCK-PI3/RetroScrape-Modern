enum FrontendTarget { emulationStation, launchBox }

enum MixStyle { none, detailed, poster }

enum TextCaseMode { asIs, lower, upper }

enum GamelistUpdateMode { overwrite, backupAndUpdate, updateOnly }

class ExportOptions {
  const ExportOptions({
    this.nameCase = TextCaseMode.asIs,
    this.descriptionCase = TextCaseMode.asIs,
    this.genreCase = TextCaseMode.asIs,
    this.moveArticles = false,
    this.useRegionInName = false,
    this.keepFilenameDecorations = false,
    this.keepUndecoratedFilename = false,
    this.includeSynopsis = true,
    this.gamelistMode = GamelistUpdateMode.backupAndUpdate,
    this.minimizeGamelist = false,
  });

  final TextCaseMode nameCase;
  final TextCaseMode descriptionCase;
  final TextCaseMode genreCase;
  final bool moveArticles;
  final bool useRegionInName;
  final bool keepFilenameDecorations;
  final bool keepUndecoratedFilename;
  final bool includeSynopsis;
  final GamelistUpdateMode gamelistMode;
  final bool minimizeGamelist;
}

class MediaChoice {
  const MediaChoice({
    required this.id,
    required this.label,
    required this.folder,
    required this.extension,
  });

  final String id;
  final String label;
  final String folder;
  final String extension;
}

class MediaCatalog {
  static const choices = <MediaChoice>[
    MediaChoice(
      id: 'box3d',
      label: 'Caja 3D',
      folder: 'box3d',
      extension: 'png',
    ),
    MediaChoice(
      id: 'box2d',
      label: 'Caja frontal',
      folder: 'box2d',
      extension: 'png',
    ),
    MediaChoice(
      id: 'screenshot',
      label: 'Screenshot',
      folder: 'screenshots',
      extension: 'png',
    ),
    MediaChoice(
      id: 'title',
      label: 'Screenshot titulo',
      folder: 'titles',
      extension: 'png',
    ),
    MediaChoice(
      id: 'logo',
      label: 'Logo / wheel',
      folder: 'logos',
      extension: 'png',
    ),
    MediaChoice(
      id: 'fanart',
      label: 'Fanart',
      folder: 'fanart',
      extension: 'jpg',
    ),
    MediaChoice(
      id: 'video',
      label: 'Video',
      folder: 'videos',
      extension: 'mp4',
    ),
    MediaChoice(
      id: 'manual',
      label: 'Manual',
      folder: 'manuals',
      extension: 'pdf',
    ),
  ];

  static MediaChoice byId(String id) {
    return choices.firstWhere((choice) => choice.id == id);
  }
}

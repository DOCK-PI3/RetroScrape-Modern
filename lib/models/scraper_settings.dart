enum FrontendTarget { emulationStation, launchBox }

enum MixStyle { none, mixV1, mixV2 }

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
    required this.apiTypes,
    this.previewable = true,
  });

  final String id;
  final String label;
  final String folder;
  final String extension;
  final List<String> apiTypes;
  final bool previewable;
}

class MediaCatalog {
  static const choices = <MediaChoice>[
    MediaChoice(
      id: 'box3d',
      label: 'Caja 3D',
      folder: 'box3d',
      extension: 'png',
      apiTypes: ['box-3d', 'box3d'],
    ),
    MediaChoice(
      id: 'box2d',
      label: 'Caja frontal',
      folder: 'box2d',
      extension: 'png',
      apiTypes: ['box-2d', 'box2dfront', 'box2d'],
    ),
    MediaChoice(
      id: 'box2dback',
      label: 'Caja trasera',
      folder: 'box2dback',
      extension: 'png',
      apiTypes: ['box-2d-back', 'box2dback', 'backcover', 'box-back'],
    ),
    MediaChoice(
      id: 'box3dback',
      label: 'Caja 3D trasera',
      folder: 'box3dback',
      extension: 'png',
      apiTypes: ['box-3d-back', 'box3dback'],
    ),
    MediaChoice(
      id: 'screenshot',
      label: 'Screenshot',
      folder: 'screenshots',
      extension: 'png',
      apiTypes: ['ss', 'screenshot'],
    ),
    MediaChoice(
      id: 'title',
      label: 'Screenshot titulo',
      folder: 'titles',
      extension: 'png',
      apiTypes: ['sstitle', 'ss-title', 'titlescreen'],
    ),
    MediaChoice(
      id: 'overlay',
      label: 'Overlay',
      folder: 'overlays',
      extension: 'png',
      apiTypes: ['overlay'],
    ),
    MediaChoice(
      id: 'logo',
      label: 'Logo / wheel',
      folder: 'logos',
      extension: 'png',
      apiTypes: ['wheel', 'logo'],
    ),
    MediaChoice(
      id: 'wheelhd',
      label: 'Wheel HD',
      folder: 'wheelhd',
      extension: 'png',
      apiTypes: ['wheel-hd', 'wheelhd', 'logo-hd'],
    ),
    MediaChoice(
      id: 'marquee',
      label: 'Marquee',
      folder: 'marquees',
      extension: 'png',
      apiTypes: [
        'screenmarquee',
        'screenmarque',
        'screen-marquee',
        'marquee-screen',
        'marquee',
      ],
    ),
    MediaChoice(
      id: 'box2dside',
      label: 'Lomo caja 2D',
      folder: 'box2dside',
      extension: 'png',
      apiTypes: ['box-2d-side', 'box2dside'],
    ),
    MediaChoice(
      id: 'boxtexture',
      label: 'Textura caja',
      folder: 'box-textures',
      extension: 'png',
      apiTypes: ['box-texture'],
    ),
    MediaChoice(
      id: 'cartridge',
      label: 'Cartucho / disco',
      folder: 'cartridges',
      extension: 'png',
      apiTypes: [
        'support-2d',
        'support2d',
        'support-texture',
        'cartouche',
        'cartridge',
      ],
    ),
    MediaChoice(
      id: 'cartridge3d',
      label: 'Cartucho / disco 3D',
      folder: 'cartridges3d',
      extension: 'png',
      apiTypes: ['support-3d', 'support3d', 'cartouche-3d', 'cartridge-3d'],
    ),
    MediaChoice(
      id: 'fanart',
      label: 'Fanart',
      folder: 'fanart',
      extension: 'jpg',
      apiTypes: ['fanart'],
    ),
    MediaChoice(
      id: 'flyer',
      label: 'Flyer',
      folder: 'flyers',
      extension: 'jpg',
      apiTypes: ['flyer'],
    ),
    MediaChoice(
      id: 'figurine',
      label: 'Figurine',
      folder: 'figurines',
      extension: 'png',
      apiTypes: ['figurine'],
    ),
    MediaChoice(
      id: 'boxscan',
      label: 'Scan caja',
      folder: 'box-scans',
      extension: 'png',
      apiTypes: ['box-scan'],
    ),
    MediaChoice(
      id: 'supportscan',
      label: 'Scan soporte',
      folder: 'support-scans',
      extension: 'png',
      apiTypes: ['support-scan'],
    ),
    MediaChoice(
      id: 'bezel',
      label: 'Bezel',
      folder: 'bezels',
      extension: 'png',
      apiTypes: ['bezel-4-3', 'bezel-16-9', 'bezel'],
    ),
    MediaChoice(
      id: 'bezel43v',
      label: 'Bezel 4:3 vertical',
      folder: 'bezels-4-3-v',
      extension: 'png',
      apiTypes: ['bezel-4-3-v'],
    ),
    MediaChoice(
      id: 'bezel43cocktail',
      label: 'Bezel 4:3 cocktail',
      folder: 'bezels-4-3-cocktail',
      extension: 'png',
      apiTypes: ['bezel-4-3-cocktail'],
    ),
    MediaChoice(
      id: 'bezel169v',
      label: 'Bezel 16:9 vertical',
      folder: 'bezels-16-9-v',
      extension: 'png',
      apiTypes: ['bezel-16-9-v'],
    ),
    MediaChoice(
      id: 'bezel169cocktail',
      label: 'Bezel 16:9 cocktail',
      folder: 'bezels-16-9-cocktail',
      extension: 'png',
      apiTypes: ['bezel-16-9-cocktail'],
    ),
    MediaChoice(
      id: 'wheel_tarcisios',
      label: 'Wheel Tarcisio',
      folder: 'wheel-tarcisios',
      extension: 'png',
      apiTypes: ['wheel-tarcisios'],
    ),
    MediaChoice(
      id: 'steamgrid',
      label: 'SteamGrid',
      folder: 'steamgrid',
      extension: 'jpg',
      apiTypes: ['steamgrid'],
    ),
    MediaChoice(
      id: 'map',
      label: 'Mapa',
      folder: 'maps',
      extension: 'jpg',
      apiTypes: ['map', 'maps', 'carte'],
    ),
    MediaChoice(
      id: 'video',
      label: 'Video',
      folder: 'videos',
      extension: 'mp4',
      apiTypes: ['video'],
      previewable: false,
    ),
    MediaChoice(
      id: 'video_normalized',
      label: 'Video normalizado',
      folder: 'videos-normalized',
      extension: 'mp4',
      apiTypes: ['video-normalized', 'videonormalized'],
      previewable: false,
    ),
    MediaChoice(
      id: 'videotable',
      label: 'Video table',
      folder: 'videos-table',
      extension: 'mp4',
      apiTypes: ['videotable'],
      previewable: false,
    ),
    MediaChoice(
      id: 'videotable4k',
      label: 'Video table 4K',
      folder: 'videos-table-4k',
      extension: 'mp4',
      apiTypes: ['videotable4k'],
      previewable: false,
    ),
    MediaChoice(
      id: 'videofronton169',
      label: 'Video fronton 16:9',
      folder: 'videos-fronton-16-9',
      extension: 'mp4',
      apiTypes: ['videofronton16-9'],
      previewable: false,
    ),
    MediaChoice(
      id: 'videofronton43',
      label: 'Video fronton 4:3',
      folder: 'videos-fronton-4-3',
      extension: 'mp4',
      apiTypes: ['videofronton4-3'],
      previewable: false,
    ),
    MediaChoice(
      id: 'videodmd',
      label: 'Video DMD',
      folder: 'videos-dmd',
      extension: 'mp4',
      apiTypes: ['videodmd'],
      previewable: false,
    ),
    MediaChoice(
      id: 'videotopper',
      label: 'Video topper',
      folder: 'videos-topper',
      extension: 'mp4',
      apiTypes: ['videotopper'],
      previewable: false,
    ),
    MediaChoice(
      id: 'sstable',
      label: 'Screenshot table',
      folder: 'screenshots-table',
      extension: 'jpg',
      apiTypes: ['sstable'],
    ),
    MediaChoice(
      id: 'ssfronton11',
      label: 'Screenshot fronton 1:1',
      folder: 'screenshots-fronton-1-1',
      extension: 'jpg',
      apiTypes: ['ssfronton1-1'],
    ),
    MediaChoice(
      id: 'ssfronton43',
      label: 'Screenshot fronton 4:3',
      folder: 'screenshots-fronton-4-3',
      extension: 'jpg',
      apiTypes: ['ssfronton4-3'],
    ),
    MediaChoice(
      id: 'ssfronton169',
      label: 'Screenshot fronton 16:9',
      folder: 'screenshots-fronton-16-9',
      extension: 'jpg',
      apiTypes: ['ssfronton16-9'],
    ),
    MediaChoice(
      id: 'ssdmd',
      label: 'Screenshot DMD',
      folder: 'screenshots-dmd',
      extension: 'jpg',
      apiTypes: ['ssdmd'],
    ),
    MediaChoice(
      id: 'sstopper',
      label: 'Screenshot topper',
      folder: 'screenshots-topper',
      extension: 'jpg',
      apiTypes: ['sstopper'],
    ),
    MediaChoice(
      id: 'themehs',
      label: 'Theme HyperSpin',
      folder: 'themes-hyperspin',
      extension: 'zip',
      apiTypes: ['themehs'],
      previewable: false,
    ),
    MediaChoice(
      id: 'themehb',
      label: 'Theme HyperBat',
      folder: 'themes-hyperbat',
      extension: 'zip',
      apiTypes: ['themehb'],
      previewable: false,
    ),
    MediaChoice(
      id: 'manual',
      label: 'Manual',
      folder: 'manuals',
      extension: 'pdf',
      apiTypes: ['manuel', 'manual'],
      previewable: false,
    ),
  ];

  static const previewPriority = <String>[
    'mix',
    'box3d',
    'box2d',
    'box2dback',
    'box3dback',
    'cartridge3d',
    'cartridge',
    'screenshot',
    'title',
    'overlay',
    'marquee',
    'logo',
    'wheelhd',
    'wheel_tarcisios',
    'fanart',
    'flyer',
    'figurine',
    'bezel',
    'bezel43v',
    'bezel43cocktail',
    'bezel169v',
    'bezel169cocktail',
    'steamgrid',
    'map',
    'sstable',
    'ssfronton11',
    'ssfronton43',
    'ssfronton169',
    'ssdmd',
    'sstopper',
  ];

  static MediaChoice byId(String id) {
    return choices.firstWhere((choice) => choice.id == id);
  }

  static MediaChoice? maybeById(String id) {
    for (final choice in choices) {
      if (choice.id == id) {
        return choice;
      }
    }
    return null;
  }
}

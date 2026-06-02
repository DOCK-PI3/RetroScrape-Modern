class RomFile {
  RomFile({
    required this.path,
    required this.name,
    required this.ext,
    required this.systemId,
    this.systemName = 'Unknown',
    this.innerPath,
    this.md5,
    this.crc,
    this.sha1,
    this.size = 0,
    this.title,
    this.description,
    this.release,
    this.developer,
    this.publisher,
    this.genre,
    this.players,
    this.rating,
    this.localMediaPaths = const {},
    this.scraped = false,
    this.status = RomStatus.pending,
    this.message = '',
  });

  final String path;
  final String name;
  final String ext;
  final int systemId;
  final String systemName;
  final String? innerPath;
  final int size;

  String? md5;
  String? crc;
  String? sha1;
  String? title;
  String? description;
  String? release;
  String? developer;
  String? publisher;
  String? genre;
  int? players;
  double? rating;
  Map<String, String> localMediaPaths;
  bool scraped;
  RomStatus status;
  String message;

  bool get isFromArchive => innerPath != null;
  String? get localImagePath {
    return localMediaPaths['mix'] ??
        localMediaPaths['box3d'] ??
        localMediaPaths['box2d'] ??
        localMediaPaths['box2dback'] ??
        localMediaPaths['box3dback'] ??
        localMediaPaths['cartridge3d'] ??
        localMediaPaths['cartridge'] ??
        localMediaPaths['box2dside'] ??
        localMediaPaths['boxtexture'] ??
        localMediaPaths['screenshot'] ??
        localMediaPaths['title'] ??
        localMediaPaths['overlay'] ??
        localMediaPaths['marquee'] ??
        localMediaPaths['logo'] ??
        localMediaPaths['wheelhd'] ??
        localMediaPaths['wheel_tarcisios'] ??
        localMediaPaths['fanart'] ??
        localMediaPaths['flyer'] ??
        localMediaPaths['figurine'] ??
        localMediaPaths['boxscan'] ??
        localMediaPaths['supportscan'] ??
        localMediaPaths['bezel'] ??
        localMediaPaths['bezel43v'] ??
        localMediaPaths['bezel43cocktail'] ??
        localMediaPaths['bezel169v'] ??
        localMediaPaths['bezel169cocktail'] ??
        localMediaPaths['steamgrid'] ??
        localMediaPaths['map'] ??
        localMediaPaths['sstable'] ??
        localMediaPaths['ssfronton11'] ??
        localMediaPaths['ssfronton43'] ??
        localMediaPaths['ssfronton169'] ??
        localMediaPaths['ssdmd'] ??
        localMediaPaths['sstopper'];
  }
}

enum RomStatus { pending, scraping, done, error }

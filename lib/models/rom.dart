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
        localMediaPaths['screenshot'];
  }
}

enum RomStatus { pending, scraping, done, error }

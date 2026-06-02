class SystemProfile {
  const SystemProfile({
    required this.id,
    required this.name,
    required this.folderNames,
    required this.extensions,
  });

  final int id;
  final String name;
  final List<String> folderNames;
  final List<String> extensions;
}

class SystemCatalog {
  static const profiles = <SystemProfile>[
    SystemProfile(
      id: 1,
      name: 'Sega Mega Drive / Genesis',
      folderNames: ['megadrive', 'genesis', 'md', 'segagenesis'],
      extensions: ['.md', '.gen', '.smd', '.bin'],
    ),
    SystemProfile(
      id: 2,
      name: 'Sega Master System',
      folderNames: ['mastersystem', 'sms', 'markiii', 'mark3'],
      extensions: ['.sms', '.sg', '.bin'],
    ),
    SystemProfile(
      id: 3,
      name: 'Nintendo NES / Famicom',
      folderNames: ['nes', 'famicom', 'fc', 'nintendoentertainmentsystem'],
      extensions: ['.nes', '.unf', '.unif'],
    ),
    SystemProfile(
      id: 4,
      name: 'Super Nintendo / Super Famicom',
      folderNames: ['snes', 'sfc', 'superfamicom', 'supernintendo'],
      extensions: ['.sfc', '.smc', '.fig', '.swc', '.bs'],
    ),
    SystemProfile(
      id: 9,
      name: 'Nintendo Game Boy',
      folderNames: ['gb', 'gameboy'],
      extensions: ['.gb'],
    ),
    SystemProfile(
      id: 10,
      name: 'Nintendo Game Boy Color',
      folderNames: ['gbc', 'gameboycolor'],
      extensions: ['.gbc'],
    ),
    SystemProfile(
      id: 11,
      name: 'Nintendo Virtual Boy',
      folderNames: ['virtualboy', 'vboy', 'vb'],
      extensions: ['.vb', '.vboy', '.bin'],
    ),
    SystemProfile(
      id: 12,
      name: 'Nintendo Game Boy Advance',
      folderNames: ['gba', 'gameboyadvance'],
      extensions: ['.gba'],
    ),
    SystemProfile(
      id: 13,
      name: 'Nintendo GameCube',
      folderNames: ['gamecube', 'gc', 'ngc'],
      extensions: ['.iso', '.gcm', '.gcz', '.rvz', '.ciso', '.wbfs'],
    ),
    SystemProfile(
      id: 14,
      name: 'Nintendo 64',
      folderNames: ['n64', 'nintendo64'],
      extensions: ['.z64', '.n64', '.v64'],
    ),
    SystemProfile(
      id: 15,
      name: 'Nintendo DS',
      folderNames: ['nds', 'ds', 'dsi'],
      extensions: ['.nds', '.dsi'],
    ),
    SystemProfile(
      id: 16,
      name: 'Nintendo Wii',
      folderNames: ['wii'],
      extensions: ['.iso', '.wbfs', '.rvz', '.ciso'],
    ),
    SystemProfile(
      id: 17,
      name: 'Nintendo 3DS',
      folderNames: ['3ds', '2ds', 'nintendo3ds'],
      extensions: ['.3ds', '.cia', '.cci', '.cxi'],
    ),
    SystemProfile(
      id: 18,
      name: 'Nintendo Wii U',
      folderNames: ['wiiu', 'wii-u'],
      extensions: ['.wua', '.wux', '.wud', '.rpx'],
    ),
    SystemProfile(
      id: 19,
      name: 'Sega Mega Drive 32X',
      folderNames: ['32x', 'sega32x', 'megadrive32x', 'genesis32x'],
      extensions: ['.32x', '.smd', '.bin', '.md'],
    ),
    SystemProfile(
      id: 20,
      name: 'Sega Mega-CD / Sega CD',
      folderNames: ['segacd', 'megacd', 'mega-cd', 'sega-cd'],
      extensions: ['.cue', '.iso', '.chd', '.bin'],
    ),
    SystemProfile(
      id: 21,
      name: 'Sega Game Gear',
      folderNames: ['gamegear', 'gg'],
      extensions: ['.gg'],
    ),
    SystemProfile(
      id: 22,
      name: 'Sega Saturn',
      folderNames: ['saturn', 'segasaturn'],
      extensions: ['.cue', '.iso', '.chd', '.bin', '.mds'],
    ),
    SystemProfile(
      id: 23,
      name: 'Sega Dreamcast',
      folderNames: ['dreamcast', 'dc'],
      extensions: ['.gdi', '.cdi', '.chd', '.cue'],
    ),
    SystemProfile(
      id: 25,
      name: 'Neo Geo Pocket',
      folderNames: ['ngp', 'neogeopocket'],
      extensions: ['.ngp', '.ngc'],
    ),
    SystemProfile(
      id: 26,
      name: 'Atari 2600',
      folderNames: ['atari2600', 'a2600', '2600'],
      extensions: ['.a26', '.bin'],
    ),
    SystemProfile(
      id: 27,
      name: 'Atari Jaguar',
      folderNames: ['jaguar', 'atarijaguar'],
      extensions: ['.j64', '.jag', '.rom', '.abs', '.bin'],
    ),
    SystemProfile(
      id: 28,
      name: 'Atari Lynx',
      folderNames: ['lynx', 'atarilynx'],
      extensions: ['.lnx', '.lyx'],
    ),
    SystemProfile(
      id: 29,
      name: 'Panasonic 3DO',
      folderNames: ['3do', 'panasonic3do'],
      extensions: ['.iso', '.cue', '.chd'],
    ),
    SystemProfile(
      id: 30,
      name: 'Nokia N-Gage',
      folderNames: ['ngage', 'n-gage'],
      extensions: ['.zip', '.ngage'],
    ),
    SystemProfile(
      id: 31,
      name: 'PC Engine / TurboGrafx-16',
      folderNames: ['pcengine', 'pce', 'tg16', 'turbografx16'],
      extensions: ['.pce', '.sgx', '.cue', '.chd'],
    ),
    SystemProfile(
      id: 32,
      name: 'Microsoft Xbox',
      folderNames: ['xbox'],
      extensions: ['.iso', '.xiso', '.xbe'],
    ),
    SystemProfile(
      id: 33,
      name: 'Microsoft Xbox 360',
      folderNames: ['xbox360', 'x360'],
      extensions: ['.iso', '.xex'],
    ),
    SystemProfile(
      id: 34,
      name: 'Microsoft Xbox One',
      folderNames: ['xboxone', 'xbone'],
      extensions: ['.iso'],
    ),
    SystemProfile(
      id: 40,
      name: 'Atari 5200',
      folderNames: ['atari5200', 'a5200', '5200'],
      extensions: ['.a52', '.bin'],
    ),
    SystemProfile(
      id: 41,
      name: 'Atari 7800',
      folderNames: ['atari7800', 'a7800', '7800'],
      extensions: ['.a78', '.bin'],
    ),
    SystemProfile(
      id: 44,
      name: 'Bally Astrocade',
      folderNames: ['astrocade', 'ballyastrocade'],
      extensions: ['.bin', '.rom'],
    ),
    SystemProfile(
      id: 45,
      name: 'Bandai WonderSwan',
      folderNames: ['wonderswan', 'wswan', 'ws'],
      extensions: ['.ws'],
    ),
    SystemProfile(
      id: 46,
      name: 'Bandai WonderSwan Color',
      folderNames: ['wonderswancolor', 'wswancolor', 'wsc'],
      extensions: ['.wsc'],
    ),
    SystemProfile(
      id: 48,
      name: 'ColecoVision',
      folderNames: ['colecovision', 'coleco'],
      extensions: ['.col', '.rom', '.bin'],
    ),
    SystemProfile(
      id: 50,
      name: 'NEC CoreGrafx',
      folderNames: ['coregrafx', 'pcengineduo', 'pceduo'],
      extensions: ['.pce', '.sgx'],
    ),
    SystemProfile(
      id: 52,
      name: 'Nintendo Game & Watch',
      folderNames: ['gameandwatch', 'gamewatch', 'gw'],
      extensions: ['.mgw'],
    ),
    SystemProfile(
      id: 57,
      name: 'Sony PlayStation',
      folderNames: ['psx', 'ps1', 'playstation', 'sonyplaystation'],
      extensions: ['.cue', '.iso', '.chd', '.pbp', '.img', '.bin', '.m3u'],
    ),
    SystemProfile(
      id: 58,
      name: 'Sony PlayStation 2',
      folderNames: ['ps2', 'playstation2'],
      extensions: ['.iso', '.chd', '.cso', '.gz', '.bin', '.mdf', '.nrg'],
    ),
    SystemProfile(
      id: 59,
      name: 'Sony PlayStation 3',
      folderNames: ['ps3', 'playstation3'],
      extensions: ['.iso', '.pkg'],
    ),
    SystemProfile(
      id: 60,
      name: 'Sony PlayStation 4',
      folderNames: ['ps4', 'playstation4'],
      extensions: ['.pkg'],
    ),
    SystemProfile(
      id: 61,
      name: 'Sony PSP',
      folderNames: ['psp', 'playstationportable'],
      extensions: ['.iso', '.cso', '.pbp'],
    ),
    SystemProfile(
      id: 62,
      name: 'Sony PlayStation Vita',
      folderNames: ['psvita', 'vita'],
      extensions: ['.vpk', '.pkg'],
    ),
    SystemProfile(
      id: 67,
      name: 'Epoch Super Cassette Vision',
      folderNames: ['supercassettevision', 'scv'],
      extensions: ['.bin', '.rom'],
    ),
    SystemProfile(
      id: 70,
      name: 'Neo Geo CD',
      folderNames: ['neogeocd', 'neogeocdrom'],
      extensions: ['.cue', '.iso', '.chd'],
    ),
    SystemProfile(
      id: 72,
      name: 'NEC PC-FX',
      folderNames: ['pcfx'],
      extensions: ['.cue', '.iso', '.chd'],
    ),
    SystemProfile(
      id: 74,
      name: 'Casio PV-1000',
      folderNames: ['pv1000', 'casiopv1000'],
      extensions: ['.bin', '.rom'],
    ),
    SystemProfile(
      id: 78,
      name: 'Entex Adventure Vision',
      folderNames: ['adventurevision'],
      extensions: ['.bin', '.rom'],
    ),
    SystemProfile(
      id: 80,
      name: 'Fairchild Channel F',
      folderNames: ['channelf', 'fairchild'],
      extensions: ['.bin', '.chf'],
    ),
    SystemProfile(
      id: 81,
      name: 'Action Max',
      folderNames: ['actionmax'],
      extensions: ['.bin', '.iso'],
    ),
    SystemProfile(
      id: 82,
      name: 'Neo Geo Pocket Color',
      folderNames: ['ngpc', 'neogeopocketcolor'],
      extensions: ['.ngc', '.ngp'],
    ),
    SystemProfile(
      id: 87,
      name: 'Amstrad GX4000',
      folderNames: ['gx4000', 'amstradgx4000'],
      extensions: ['.cpr', '.bin'],
    ),
    SystemProfile(
      id: 90,
      name: 'Mega Duck / Cougar Boy',
      folderNames: ['megaduck', 'cougarboy'],
      extensions: ['.bin', '.rom'],
    ),
    SystemProfile(
      id: 94,
      name: 'Arcadia 2001',
      folderNames: ['arcadia2001', 'emerson2001'],
      extensions: ['.bin', '.rom'],
    ),
    SystemProfile(
      id: 95,
      name: 'Epoch Game Pocket Computer',
      folderNames: ['gamepocketcomputer'],
      extensions: ['.bin', '.rom'],
    ),
    SystemProfile(
      id: 98,
      name: 'Casio Loopy',
      folderNames: ['loopy', 'casioloopy'],
      extensions: ['.bin', '.rom'],
    ),
    SystemProfile(
      id: 100,
      name: "Super A'Can",
      folderNames: ['superacan', 'supera-can'],
      extensions: ['.bin', '.rom'],
    ),
    SystemProfile(
      id: 101,
      name: 'GamePark GP32',
      folderNames: ['gp32'],
      extensions: ['.smc', '.fxe', '.gxb'],
    ),
    SystemProfile(
      id: 102,
      name: 'GCE Vectrex',
      folderNames: ['vectrex'],
      extensions: ['.vec', '.bin', '.gam'],
    ),
    SystemProfile(
      id: 103,
      name: 'Hartung Game Master',
      folderNames: ['gamemaster', 'systema2000'],
      extensions: ['.bin', '.rom'],
    ),
    SystemProfile(
      id: 104,
      name: 'Magnavox Odyssey 2 / Videopac',
      folderNames: ['odyssey2', 'videopac', 'o2em'],
      extensions: ['.bin', '.rom'],
    ),
    SystemProfile(
      id: 105,
      name: 'PC Engine SuperGrafx',
      folderNames: ['supergrafx', 'sgx'],
      extensions: ['.sgx', '.pce'],
    ),
    SystemProfile(
      id: 106,
      name: 'Nintendo Famicom Disk System',
      folderNames: ['fds', 'famicomdisksystem'],
      extensions: ['.fds'],
    ),
    SystemProfile(
      id: 107,
      name: 'Nintendo Satellaview',
      folderNames: ['satellaview', 'bsx'],
      extensions: ['.bs', '.sfc', '.smc'],
    ),
    SystemProfile(
      id: 109,
      name: 'Sega SG-1000',
      folderNames: ['sg1000', 'sc3000'],
      extensions: ['.sg', '.sc', '.bin', '.sms'],
    ),
    SystemProfile(
      id: 114,
      name: 'PC Engine CD-ROM',
      folderNames: ['pcenginecd', 'pcecd', 'turbografxcd', 'tgcd'],
      extensions: ['.cue', '.iso', '.chd'],
    ),
    SystemProfile(
      id: 115,
      name: 'Mattel Intellivision',
      folderNames: ['intellivision', 'intv'],
      extensions: ['.int', '.bin', '.rom'],
    ),
    SystemProfile(
      id: 120,
      name: 'VTech V.Smile',
      folderNames: ['vsmile'],
      extensions: ['.bin', '.rom'],
    ),
    SystemProfile(
      id: 121,
      name: 'Tiger Game.com',
      folderNames: ['gamecom', 'tiger-gamecom'],
      extensions: ['.bin', '.tgc'],
    ),
    SystemProfile(
      id: 122,
      name: 'Nintendo 64DD',
      folderNames: ['n64dd', '64dd'],
      extensions: ['.ndd', '.z64', '.n64'],
    ),
    SystemProfile(
      id: 130,
      name: 'Commodore Amiga CD32',
      folderNames: ['amigacd32', 'cd32'],
      extensions: ['.cue', '.iso', '.chd'],
    ),
    SystemProfile(
      id: 133,
      name: 'Philips CD-i',
      folderNames: ['cdi', 'philips-cdi'],
      extensions: ['.cue', '.iso', '.chd'],
    ),
    SystemProfile(
      id: 142,
      name: 'Neo Geo AES / MVS',
      folderNames: ['neogeo', 'neogeo-aes', 'neogeo-mvs'],
      extensions: ['.zip', '.7z', '.neo'],
    ),
    SystemProfile(
      id: 171,
      name: 'Atari Jaguar CD',
      folderNames: ['jaguarcd', 'atarijaguarcd'],
      extensions: ['.cue', '.iso', '.chd'],
    ),
    SystemProfile(
      id: 172,
      name: 'PlayStation Minis',
      folderNames: ['psminis', 'playstationminis'],
      extensions: ['.pbp', '.pkg'],
    ),
    SystemProfile(
      id: 207,
      name: 'Watara Supervision',
      folderNames: ['supervision', 'watara'],
      extensions: ['.sv', '.bin'],
    ),
    SystemProfile(
      id: 210,
      name: 'Super Nintendo MSU-1',
      folderNames: ['msu1', 'snesmsu1'],
      extensions: ['.sfc', '.smc', '.msu'],
    ),
    SystemProfile(
      id: 211,
      name: 'Pokemon Mini',
      folderNames: ['pokemonmini', 'pokemini'],
      extensions: ['.min'],
    ),
    SystemProfile(
      id: 216,
      name: 'Uzebox',
      folderNames: ['uzebox'],
      extensions: ['.uze'],
    ),
  ];

  static final supportedExtensions =
      profiles.expand((p) => p.extensions).toSet();

  static SystemProfile detect(String ext, String fullPath) {
    final normalizedExt = ext.toLowerCase();
    final parts = fullPath
        .replaceAll('\\', '/')
        .toLowerCase()
        .split('/')
        .map((part) => part.replaceAll(RegExp(r'[^a-z0-9]'), ''))
        .toList();

    for (final profile in profiles) {
      if (profile.folderNames.any(parts.contains)) {
        return profile;
      }
    }

    return profiles.firstWhere(
      (profile) => profile.extensions.contains(normalizedExt),
      orElse: () => profiles.first,
    );
  }

  static SystemProfile byId(int id) {
    return profiles.firstWhere(
      (profile) => profile.id == id,
      orElse: () => profiles.first,
    );
  }
}

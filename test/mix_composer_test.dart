import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:retroscape_modern/core/utils/mix_composer.dart';

void main() {
  testWidgets('Mix V1 composes screenshot, box and logo', (tester) async {
    await tester.runAsync(_testMixV1);
  });
  testWidgets('Mix V2 composes title, box, cartridge and logo', (tester) async {
    await tester.runAsync(_testMixV2);
  });
}

Future<void> _testMixV1() async {
  final temp = await Directory.systemTemp.createTemp('retroscrape-mix-v1-');
  addTearDown(() => temp.delete(recursive: true));

  final screenshot = await _solidPng(
    temp,
    'screenshot.png',
    const ui.Color(0xFFFF0000),
    1280,
    720,
  );
  final logo = await _solidPng(
    temp,
    'logo.png',
    const ui.Color(0xFF00FF00),
    800,
    200,
  );
  final box = await _solidPng(
    temp,
    'box.png',
    const ui.Color(0xFF0000FF),
    300,
    600,
  );
  final output = File('${temp.path}${Platform.pathSeparator}mix-v1.png');

  final created = await MixComposer.createV1(
    screenshotPath: screenshot.path,
    logoPath: logo.path,
    box3dPath: box.path,
    outputPath: output.path,
  );

  expect(created, isTrue);
  expect(output.existsSync(), isTrue);
  final decoded = await _decodePng(output);
  expect(decoded.image.width, MixComposer.width);
  expect(decoded.image.height, MixComposer.height);
  expect(_pixel(decoded.bytes, 700, 200), const [255, 0, 0, 255]);
  expect(_pixel(decoded.bytes, 100, 500), const [0, 0, 255, 255]);
  expect(_pixel(decoded.bytes, 800, 650), const [0, 255, 0, 255]);
  decoded.image.dispose();
}

Future<void> _testMixV2() async {
  final temp = await Directory.systemTemp.createTemp('retroscrape-mix-v2-');
  addTearDown(() => temp.delete(recursive: true));

  final title = await _solidPng(
    temp,
    'title.png',
    const ui.Color(0xFFFF0000),
    1280,
    720,
  );
  final logo = await _solidPng(
    temp,
    'logo.png',
    const ui.Color(0xFF00FF00),
    800,
    200,
  );
  final cartridge = await _solidPng(
    temp,
    'cartridge.png',
    const ui.Color(0xFFFFFF00),
    300,
    500,
  );
  final box = await _solidPng(
    temp,
    'box.png',
    const ui.Color(0xFF0000FF),
    300,
    600,
  );
  final output = File('${temp.path}${Platform.pathSeparator}mix-v2.png');

  final created = await MixComposer.createV2(
    titleScreenshotPath: title.path,
    logoPath: logo.path,
    cartridgePath: cartridge.path,
    box2dPath: box.path,
    outputPath: output.path,
  );

  expect(created, isTrue);
  expect(output.existsSync(), isTrue);
  final decoded = await _decodePng(output);
  expect(decoded.image.width, MixComposer.width);
  expect(decoded.image.height, MixComposer.height);
  expect(_pixel(decoded.bytes, 600, 200), const [255, 0, 0, 255]);
  expect(_pixel(decoded.bytes, 100, 500), const [0, 0, 255, 255]);
  expect(_pixel(decoded.bytes, 1100, 500), const [255, 255, 0, 255]);
  expect(_pixel(decoded.bytes, 600, 650), const [0, 255, 0, 255]);
  decoded.image.dispose();
}

Future<File> _solidPng(
  Directory directory,
  String name,
  ui.Color color,
  int width,
  int height,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawColor(color, ui.BlendMode.src);
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  picture.dispose();
  image.dispose();
  final file = File('${directory.path}${Platform.pathSeparator}$name');
  await file.writeAsBytes(
    data!.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
  return file;
}

Future<({ui.Image image, ByteData bytes})> _decodePng(File file) async {
  final codec = await ui.instantiateImageCodec(await file.readAsBytes());
  final frame = await codec.getNextFrame();
  codec.dispose();
  final bytes =
      await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
  return (image: frame.image, bytes: bytes!);
}

List<int> _pixel(ByteData data, int x, int y) {
  final offset = (y * MixComposer.width + x) * 4;
  return [
    data.getUint8(offset),
    data.getUint8(offset + 1),
    data.getUint8(offset + 2),
    data.getUint8(offset + 3),
  ];
}

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

class MixComposer {
  static const width = 1280;
  static const height = 720;

  static Future<bool> createV1({
    required String screenshotPath,
    required String logoPath,
    required String box3dPath,
    required String outputPath,
  }) {
    return _compose(
      sourcePaths: [screenshotPath, logoPath, box3dPath],
      outputPath: outputPath,
      paint: (canvas, images) {
        _paintLayer(
          canvas,
          images[0],
          const ui.Rect.fromLTWH(120, 20, 1140, 650),
          framed: true,
        );
        _paintLayer(
          canvas,
          images[2],
          const ui.Rect.fromLTWH(0, 175, 405, 525),
          alignment: Alignment.bottomLeft,
        );
        _paintLayer(
          canvas,
          images[1],
          const ui.Rect.fromLTWH(500, 490, 760, 220),
          alignment: Alignment.bottomRight,
        );
      },
    );
  }

  static Future<bool> createV2({
    required String titleScreenshotPath,
    required String logoPath,
    required String cartridgePath,
    required String box2dPath,
    required String outputPath,
  }) {
    return _compose(
      sourcePaths: [
        titleScreenshotPath,
        logoPath,
        cartridgePath,
        box2dPath,
      ],
      outputPath: outputPath,
      paint: (canvas, images) {
        _paintLayer(
          canvas,
          images[0],
          const ui.Rect.fromLTWH(170, 30, 1010, 625),
          framed: true,
        );
        _paintLayer(
          canvas,
          images[3],
          const ui.Rect.fromLTWH(5, 165, 360, 520),
          alignment: Alignment.bottomLeft,
        );
        _paintLayer(
          canvas,
          images[2],
          const ui.Rect.fromLTWH(915, 275, 345, 395),
          alignment: Alignment.bottomRight,
        );
        _paintLayer(
          canvas,
          images[1],
          const ui.Rect.fromLTWH(350, 500, 590, 200),
          alignment: Alignment.bottomCenter,
        );
      },
    );
  }

  static Future<bool> _compose({
    required List<String> sourcePaths,
    required String outputPath,
    required void Function(ui.Canvas canvas, List<ui.Image> images) paint,
  }) async {
    final decoded = await Future.wait(sourcePaths.map(_decodeImage));
    if (decoded.any((image) => image == null)) {
      for (final image in decoded) {
        image?.dispose();
      }
      return false;
    }

    final images = decoded.cast<ui.Image>();
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawColor(const ui.Color(0x00000000), ui.BlendMode.src);
    paint(canvas, images);

    final picture = recorder.endRecording();
    final outputImage = await picture.toImage(width, height);
    final png = await outputImage.toByteData(format: ui.ImageByteFormat.png);
    picture.dispose();
    outputImage.dispose();
    for (final image in images) {
      image.dispose();
    }
    if (png == null) {
      return false;
    }

    final output = File(outputPath);
    await output.parent.create(recursive: true);
    final bytes = png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes);
    await output.writeAsBytes(bytes, flush: true);
    return true;
  }

  static Future<ui.Image?> _decodeImage(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      codec.dispose();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  static void _paintLayer(
    ui.Canvas canvas,
    ui.Image image,
    ui.Rect rect, {
    Alignment alignment = Alignment.center,
    bool framed = false,
  }) {
    if (framed) {
      final frameRect = ui.RRect.fromRectAndRadius(
        rect.inflate(8),
        const ui.Radius.circular(12),
      );
      canvas.drawShadow(
        ui.Path()..addRRect(frameRect),
        const ui.Color(0xCC000000),
        18,
        true,
      );
      canvas.drawRRect(
        frameRect,
        ui.Paint()..color = const ui.Color(0xFF080A0F),
      );
    }
    paintImage(
      canvas: canvas,
      rect: rect,
      image: image,
      fit: BoxFit.contain,
      alignment: alignment,
      filterQuality: ui.FilterQuality.high,
    );
  }
}

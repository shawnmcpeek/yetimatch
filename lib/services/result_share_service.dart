import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../config/app_config.dart';

/// Builds a share card image and opens the system share sheet.
class ResultShareService {
  static const _cardWidth = 1080.0;
  static const _cardHeight = 1350.0;

  Future<void> shareResult({
    required String quizTitle,
    required String characterName,
    Rect? sharePositionOrigin,
  }) async {
    final file = await _buildCardFile(
      quizTitle: quizTitle,
      characterName: characterName,
    );
    final storeUrl = AppConfig.storeListingUrl;
    final text =
        'I got $characterName on YetiMatch\'s "$quizTitle" quiz!\n'
        'Take the quiz yourself: $storeUrl';

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: 'My YetiMatch result: $characterName',
        files: [XFile(file.path, mimeType: 'image/png')],
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  Future<File> _buildCardFile({
    required String quizTitle,
    required String characterName,
  }) async {
    final logoBytes = await rootBundle.load('assets/images/yetimatch.png');
    final codec = await ui.instantiateImageCodec(
      logoBytes.buffer.asUint8List(),
      targetWidth: 360,
    );
    final frame = await codec.getNextFrame();
    final logo = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(_cardWidth, _cardHeight);

    // Background
    final bg = Paint()..color = const Color(0xFFF5FAFC);
    canvas.drawRect(Offset.zero & size, bg);

    // Top accent bar
    final accent = Paint()..color = const Color(0xFF006684);
    canvas.drawRect(const Rect.fromLTWH(0, 0, _cardWidth, 24), accent);

    // Logo
    const logoW = 280.0;
    final logoH = logoW * (logo.height / logo.width);
    final logoX = (_cardWidth - logoW) / 2;
    const logoY = 80.0;
    canvas.drawImageRect(
      logo,
      Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
      Rect.fromLTWH(logoX, logoY, logoW, logoH),
      Paint()..filterQuality = FilterQuality.high,
    );

    var y = logoY + logoH + 64;

    // Quiz title
    y = _paintCenteredText(
      canvas,
      quizTitle,
      y: y,
      style: const TextStyle(
        color: Color(0xFF4D616C),
        fontSize: 42,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
      maxWidth: _cardWidth - 120,
    );

    y += 48;

    _paintCenteredText(
      canvas,
      'I got',
      y: y,
      style: const TextStyle(
        color: Color(0xFF006684),
        fontSize: 40,
        fontWeight: FontWeight.w600,
      ),
      maxWidth: _cardWidth - 120,
    );
    y += 64;

    y = _paintCenteredText(
      canvas,
      characterName,
      y: y,
      style: const TextStyle(
        color: Color(0xFF191C1E),
        fontSize: 96,
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
      maxWidth: _cardWidth - 100,
    );

    // CTA bar near bottom
    const ctaHeight = 120.0;
    const ctaMargin = 72.0;
    final ctaRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        ctaMargin,
        _cardHeight - ctaMargin - ctaHeight,
        _cardWidth - ctaMargin * 2,
        ctaHeight,
      ),
      const Radius.circular(24),
    );
    canvas.drawRRect(ctaRect, accent);

    _paintCenteredText(
      canvas,
      'Take the Quiz Yourself',
      y: _cardHeight - ctaMargin - ctaHeight + 36,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 44,
        fontWeight: FontWeight.w700,
      ),
      maxWidth: _cardWidth - ctaMargin * 2 - 40,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(_cardWidth.toInt(), _cardHeight.toInt());
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    if (png == null) {
      throw StateError('Failed to encode share card');
    }

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/yetimatch_result_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(png.buffer.asUint8List());
    return file;
  }

  double _paintCenteredText(
    Canvas canvas,
    String text, {
    required double y,
    required TextStyle style,
    required double maxWidth,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    final x = (_cardWidth - painter.width) / 2;
    painter.paint(canvas, Offset(x, y));
    return y + painter.height;
  }
}

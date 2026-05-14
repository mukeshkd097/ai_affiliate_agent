import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../constants/app_constants.dart';
import '../models/category_model.dart';
import '../models/screenshot_model.dart';

class CategorizationResult {
  final ScreenshotCategory category;
  final double confidence;
  final String? ocrText;

  const CategorizationResult({
    required this.category,
    required this.confidence,
    this.ocrText,
  });
}

class CategoryService {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  Future<CategorizationResult> categorize(String imagePath) async {
    String? ocrText;
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognised = await _textRecognizer.processImage(inputImage);
      ocrText = recognised.text;
    } catch (_) {
      // OCR failure — fall back to miscellaneous
    }

    if (ocrText == null || ocrText.trim().isEmpty) {
      return const CategorizationResult(
        category: ScreenshotCategory.miscellaneous,
        confidence: 0.5,
      );
    }

    final result = _classify(ocrText);
    return CategorizationResult(
      category: result.$1,
      confidence: result.$2,
      ocrText: ocrText,
    );
  }

  // Returns (category, confidence) using rule-based scoring.
  (ScreenshotCategory, double) _classify(String text) {
    final lower = text.toLowerCase();

    final scores = <ScreenshotCategory, double>{};

    // OTP: high-confidence 4–8 digit code + keyword context
    if (_hasOtpPattern(lower)) {
      scores[ScreenshotCategory.otp] =
          (_keywordScore(lower, AppConstants.otpKeywords) > 0 ? 0.97 : 0.80);
    }

    _scoreCategory(scores, lower, ScreenshotCategory.bills,
        AppConstants.billKeywords, 0.12);
    _scoreCategory(scores, lower, ScreenshotCategory.receipts,
        AppConstants.receiptKeywords, 0.12);
    _scoreCategory(scores, lower, ScreenshotCategory.trading,
        AppConstants.tradingKeywords, 0.10);
    _scoreCategory(scores, lower, ScreenshotCategory.crypto,
        AppConstants.cryptoKeywords, 0.10);
    _scoreCategory(scores, lower, ScreenshotCategory.shopping,
        AppConstants.shoppingKeywords, 0.10);
    _scoreCategory(scores, lower, ScreenshotCategory.tickets,
        AppConstants.ticketKeywords, 0.12);
    _scoreCategory(scores, lower, ScreenshotCategory.bankInfo,
        AppConstants.bankKeywords, 0.12);
    _scoreCategory(scores, lower, ScreenshotCategory.notes,
        AppConstants.notesKeywords, 0.08);

    if (scores.isEmpty) {
      return (ScreenshotCategory.miscellaneous, 0.5);
    }

    final best = scores.entries.reduce((a, b) => a.value > b.value ? a : b);

    if (best.value < 0.35) {
      return (ScreenshotCategory.miscellaneous, best.value);
    }
    return (best.key, best.value.clamp(0.0, 1.0));
  }

  bool _hasOtpPattern(String text) {
    // Match standalone 4–8 digit numbers (common OTP lengths)
    final otpRegex = RegExp(r'\b\d{4,8}\b');
    return otpRegex.hasMatch(text);
  }

  int _keywordScore(String text, List<String> keywords) {
    int hits = 0;
    for (final kw in keywords) {
      if (text.contains(kw)) hits++;
    }
    return hits;
  }

  void _scoreCategory(
    Map<ScreenshotCategory, double> scores,
    String text,
    ScreenshotCategory category,
    List<String> keywords,
    double weightPerHit,
  ) {
    final hits = _keywordScore(text, keywords);
    if (hits > 0) {
      scores[category] = (hits * weightPerHit).clamp(0.0, 0.95);
    }
  }

  // Batch categorise a list of screenshots
  Future<List<CategorizationResult>> categoriseBatch(
      List<ScreenshotModel> screenshots) async {
    final results = <CategorizationResult>[];
    for (final s in screenshots) {
      if (!File(s.localPath).existsSync()) {
        results.add(const CategorizationResult(
          category: ScreenshotCategory.miscellaneous,
          confidence: 0.0,
        ));
        continue;
      }
      results.add(await categorize(s.localPath));
    }
    return results;
  }

  void dispose() {
    _textRecognizer.close();
  }
}

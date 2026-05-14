import 'category_model.dart';

class ScreenshotModel {
  final String id;
  final String localPath;
  final ScreenshotCategory category;
  final double confidenceScore;
  final String? ocrText;
  final DateTime capturedAt;
  final DateTime processedAt;
  final bool isProcessed;
  final bool isFavorite;
  final List<String> tags;
  final int? fileSize;
  final String? thumbnailPath;

  const ScreenshotModel({
    required this.id,
    required this.localPath,
    required this.category,
    required this.confidenceScore,
    this.ocrText,
    required this.capturedAt,
    required this.processedAt,
    this.isProcessed = false,
    this.isFavorite = false,
    this.tags = const [],
    this.fileSize,
    this.thumbnailPath,
  });

  ScreenshotModel copyWith({
    String? id,
    String? localPath,
    ScreenshotCategory? category,
    double? confidenceScore,
    String? ocrText,
    DateTime? capturedAt,
    DateTime? processedAt,
    bool? isProcessed,
    bool? isFavorite,
    List<String>? tags,
    int? fileSize,
    String? thumbnailPath,
  }) {
    return ScreenshotModel(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      category: category ?? this.category,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      ocrText: ocrText ?? this.ocrText,
      capturedAt: capturedAt ?? this.capturedAt,
      processedAt: processedAt ?? this.processedAt,
      isProcessed: isProcessed ?? this.isProcessed,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      fileSize: fileSize ?? this.fileSize,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'local_path': localPath,
      'category': category.name,
      'confidence_score': confidenceScore,
      'ocr_text': ocrText,
      'captured_at': capturedAt.millisecondsSinceEpoch,
      'processed_at': processedAt.millisecondsSinceEpoch,
      'is_processed': isProcessed ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'tags': tags.join(','),
      'file_size': fileSize,
      'thumbnail_path': thumbnailPath,
    };
  }

  factory ScreenshotModel.fromMap(Map<String, dynamic> map) {
    return ScreenshotModel(
      id: map['id'] as String,
      localPath: map['local_path'] as String,
      category: ScreenshotCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => ScreenshotCategory.miscellaneous,
      ),
      confidenceScore: (map['confidence_score'] as num).toDouble(),
      ocrText: map['ocr_text'] as String?,
      capturedAt:
          DateTime.fromMillisecondsSinceEpoch(map['captured_at'] as int),
      processedAt:
          DateTime.fromMillisecondsSinceEpoch(map['processed_at'] as int),
      isProcessed: (map['is_processed'] as int) == 1,
      isFavorite: (map['is_favorite'] as int) == 1,
      tags: map['tags'] != null && (map['tags'] as String).isNotEmpty
          ? (map['tags'] as String).split(',')
          : [],
      fileSize: map['file_size'] as int?,
      thumbnailPath: map['thumbnail_path'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScreenshotModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

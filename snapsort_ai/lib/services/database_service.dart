import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';
import '../models/category_model.dart';
import '../models/screenshot_model.dart';

class DatabaseService {
  Database? _db;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.dbName);

    _db = await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Database get db {
    if (_db == null) throw StateError('DatabaseService not initialised. Call init() first.');
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE screenshots (
        id TEXT PRIMARY KEY,
        local_path TEXT NOT NULL,
        category TEXT NOT NULL,
        confidence_score REAL NOT NULL DEFAULT 0.0,
        ocr_text TEXT,
        captured_at INTEGER NOT NULL,
        processed_at INTEGER NOT NULL,
        is_processed INTEGER NOT NULL DEFAULT 0,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        tags TEXT NOT NULL DEFAULT '',
        file_size INTEGER,
        thumbnail_path TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_screenshots_category ON screenshots(category)
    ''');
    await db.execute('''
      CREATE INDEX idx_screenshots_captured_at ON screenshots(captured_at DESC)
    ''');
    await db.execute('''
      CREATE INDEX idx_screenshots_is_favorite ON screenshots(is_favorite)
    ''');

    // Full-text search virtual table over OCR text
    await db.execute('''
      CREATE VIRTUAL TABLE screenshots_fts USING fts5(
        id UNINDEXED,
        ocr_text,
        tags,
        content='screenshots',
        content_rowid='rowid'
      )
    ''');

    // Keep FTS in sync via triggers
    await db.execute('''
      CREATE TRIGGER screenshots_ai AFTER INSERT ON screenshots BEGIN
        INSERT INTO screenshots_fts(rowid, id, ocr_text, tags)
        VALUES (new.rowid, new.id, new.ocr_text, new.tags);
      END
    ''');
    await db.execute('''
      CREATE TRIGGER screenshots_ad AFTER DELETE ON screenshots BEGIN
        INSERT INTO screenshots_fts(screenshots_fts, rowid, id, ocr_text, tags)
        VALUES ('delete', old.rowid, old.id, old.ocr_text, old.tags);
      END
    ''');
    await db.execute('''
      CREATE TRIGGER screenshots_au AFTER UPDATE ON screenshots BEGIN
        INSERT INTO screenshots_fts(screenshots_fts, rowid, id, ocr_text, tags)
        VALUES ('delete', old.rowid, old.id, old.ocr_text, old.tags);
        INSERT INTO screenshots_fts(rowid, id, ocr_text, tags)
        VALUES (new.rowid, new.id, new.ocr_text, new.tags);
      END
    ''');

    await db.execute('''
      CREATE TABLE user_corrections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        screenshot_id TEXT NOT NULL,
        original_category TEXT NOT NULL,
        corrected_category TEXT NOT NULL,
        corrected_at INTEGER NOT NULL,
        FOREIGN KEY (screenshot_id) REFERENCES screenshots(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
  }

  // --- CRUD ---

  Future<void> insertScreenshot(ScreenshotModel s) async {
    await db.insert(
      'screenshots',
      s.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertScreenshots(List<ScreenshotModel> screenshots) async {
    final batch = db.batch();
    for (final s in screenshots) {
      batch.insert('screenshots', s.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<ScreenshotModel?> getScreenshot(String id) async {
    final rows = await db.query(
      'screenshots',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : ScreenshotModel.fromMap(rows.first);
  }

  Future<List<ScreenshotModel>> getAllScreenshots({
    int limit = 100,
    int offset = 0,
  }) async {
    final rows = await db.query(
      'screenshots',
      orderBy: 'captured_at DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(ScreenshotModel.fromMap).toList();
  }

  Future<List<ScreenshotModel>> getScreenshotsByCategory(
    ScreenshotCategory category, {
    int limit = 100,
    int offset = 0,
  }) async {
    final rows = await db.query(
      'screenshots',
      where: 'category = ?',
      whereArgs: [category.name],
      orderBy: 'captured_at DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(ScreenshotModel.fromMap).toList();
  }

  Future<List<ScreenshotModel>> getFavorites() async {
    final rows = await db.query(
      'screenshots',
      where: 'is_favorite = 1',
      orderBy: 'captured_at DESC',
    );
    return rows.map(ScreenshotModel.fromMap).toList();
  }

  // Full-text search using FTS5
  Future<List<ScreenshotModel>> searchScreenshots(String query) async {
    if (query.trim().isEmpty) return [];
    final sanitised = query.trim().replaceAll("'", "''");
    final rows = await db.rawQuery('''
      SELECT s.* FROM screenshots s
      INNER JOIN screenshots_fts fts ON s.id = fts.id
      WHERE screenshots_fts MATCH '$sanitised*'
      ORDER BY s.captured_at DESC
      LIMIT 200
    ''');
    return rows.map(ScreenshotModel.fromMap).toList();
  }

  // Recent OTPs — last 7 days
  Future<List<ScreenshotModel>> getRecentOTPs() async {
    final since = DateTime.now()
        .subtract(const Duration(days: 7))
        .millisecondsSinceEpoch;
    final rows = await db.query(
      'screenshots',
      where: 'category = ? AND captured_at > ?',
      whereArgs: [ScreenshotCategory.otp.name, since],
      orderBy: 'captured_at DESC',
    );
    return rows.map(ScreenshotModel.fromMap).toList();
  }

  Future<void> updateCategory(
    String id,
    ScreenshotCategory category,
    double confidence,
  ) async {
    await db.update(
      'screenshots',
      {'category': category.name, 'confidence_score': confidence},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    await db.update(
      'screenshots',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> saveCorrection(
    String screenshotId,
    ScreenshotCategory original,
    ScreenshotCategory corrected,
  ) async {
    await db.insert('user_corrections', {
      'screenshot_id': screenshotId,
      'original_category': original.name,
      'corrected_category': corrected.name,
      'corrected_at': DateTime.now().millisecondsSinceEpoch,
    });
    await updateCategory(screenshotId, corrected, 1.0);
  }

  Future<void> deleteScreenshot(String id) async {
    await db.delete('screenshots', where: 'id = ?', whereArgs: [id]);
  }

  // --- Stats ---

  Future<int> getTotalCount() async {
    final result =
        await db.rawQuery('SELECT COUNT(*) as c FROM screenshots');
    return (result.first['c'] as int? ?? 0);
  }

  Future<Map<ScreenshotCategory, int>> getCategoryCounts() async {
    final rows = await db.rawQuery(
        'SELECT category, COUNT(*) as c FROM screenshots GROUP BY category');
    final map = <ScreenshotCategory, int>{};
    for (final row in rows) {
      final cat = ScreenshotCategory.values.firstWhere(
        (c) => c.name == row['category'],
        orElse: () => ScreenshotCategory.miscellaneous,
      );
      map[cat] = row['c'] as int;
    }
    return map;
  }

  Future<List<CategoryStats>> getCategoryStats() async {
    final counts = await getCategoryCounts();
    return ScreenshotCategory.values.map((cat) {
      return CategoryStats(
        category: cat,
        count: counts[cat] ?? 0,
      );
    }).toList()
      ..sort((a, b) => b.count.compareTo(a.count));
  }

  Future<void> close() async => _db?.close();
}

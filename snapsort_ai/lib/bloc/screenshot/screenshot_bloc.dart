import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../models/category_model.dart';
import '../../models/screenshot_model.dart';
import '../../services/category_service.dart';
import '../../services/database_service.dart';
import '../../services/photo_service.dart';
import 'screenshot_event.dart';
import 'screenshot_state.dart';

class ScreenshotBloc extends Bloc<ScreenshotEvent, ScreenshotState> {
  final DatabaseService dbService;
  final CategoryService categoryService;
  final PhotoService photoService;
  final Uuid _uuid = const Uuid();

  ScreenshotBloc({
    required this.dbService,
    required this.categoryService,
    required this.photoService,
  }) : super(const ScreenshotInitial()) {
    on<LoadScreenshots>(_onLoad);
    on<ScanNewScreenshots>(_onScan);
    on<FilterByCategory>(_onFilter);
    on<SearchScreenshots>(_onSearch);
    on<CorrectCategory>(_onCorrect);
    on<ToggleFavorite>(_onToggleFavorite);
    on<LoadCategoryScreenshots>(_onLoadCategory);
    on<RefreshStats>(_onRefreshStats);
  }

  Future<void> _onLoad(
      LoadScreenshots event, Emitter<ScreenshotState> emit) async {
    emit(const ScreenshotLoading());
    try {
      final screenshots = await dbService.getAllScreenshots(limit: 500);
      final stats = await dbService.getCategoryStats();
      emit(ScreenshotLoaded(
        screenshots: screenshots,
        filteredScreenshots: screenshots,
        categoryStats: stats,
      ));
    } catch (e) {
      emit(ScreenshotError('Failed to load screenshots: $e'));
    }
  }

  Future<void> _onScan(
      ScanNewScreenshots event, Emitter<ScreenshotState> emit) async {
    emit(const ScreenshotScanning(processed: 0, total: 0));
    try {
      final hasPermission = await photoService.hasPermission;
      if (!hasPermission) {
        emit(const ScreenshotError(
            'Photo library permission denied. Please enable in settings.'));
        return;
      }

      final stubs = await photoService.loadAllAsStubs();
      final total = stubs.length;

      if (total == 0) {
        add(const LoadScreenshots());
        return;
      }

      // Process in batches of 10 to emit progress
      const batchSize = 10;
      for (int i = 0; i < stubs.length; i += batchSize) {
        final batch = stubs.skip(i).take(batchSize).toList();
        final processed = <ScreenshotModel>[];

        for (final stub in batch) {
          final result = await categoryService.categorize(stub.localPath);
          processed.add(stub.copyWith(
            id: _uuid.v4(),
            category: result.category,
            confidenceScore: result.confidence,
            ocrText: result.ocrText,
            isProcessed: true,
            processedAt: DateTime.now(),
          ));
        }

        await dbService.insertScreenshots(processed);
        emit(ScreenshotScanning(
            processed: i + batch.length, total: total));
      }

      add(const LoadScreenshots());
    } catch (e) {
      emit(ScreenshotError('Scan failed: $e'));
    }
  }

  Future<void> _onFilter(
      FilterByCategory event, Emitter<ScreenshotState> emit) async {
    final current = state;
    if (current is! ScreenshotLoaded) return;

    if (event.category == null) {
      emit(current.copyWith(
        filteredScreenshots: current.screenshots,
        clearFilter: true,
      ));
      return;
    }

    final filtered = current.screenshots
        .where((s) => s.category == event.category)
        .toList();

    emit(current.copyWith(
      filteredScreenshots: filtered,
      activeFilter: event.category,
    ));
  }

  Future<void> _onSearch(
      SearchScreenshots event, Emitter<ScreenshotState> emit) async {
    final current = state;
    if (current is! ScreenshotLoaded) return;

    if (event.query.isEmpty) {
      emit(current.copyWith(
        filteredScreenshots: current.screenshots,
        searchQuery: '',
        isSearching: false,
        clearFilter: true,
      ));
      return;
    }

    emit(current.copyWith(isSearching: true, searchQuery: event.query));
    final results = await dbService.searchScreenshots(event.query);
    emit(current.copyWith(
      filteredScreenshots: results,
      searchQuery: event.query,
      isSearching: false,
    ));
  }

  Future<void> _onCorrect(
      CorrectCategory event, Emitter<ScreenshotState> emit) async {
    final current = state;
    if (current is! ScreenshotLoaded) return;

    await dbService.saveCorrection(
        event.screenshotId, event.originalCategory, event.newCategory);

    final updated = current.screenshots.map((s) {
      if (s.id == event.screenshotId) {
        return s.copyWith(
            category: event.newCategory, confidenceScore: 1.0);
      }
      return s;
    }).toList();

    final stats = await dbService.getCategoryStats();
    emit(current.copyWith(
      screenshots: updated,
      filteredScreenshots: current.activeFilter == null
          ? updated
          : updated
              .where((s) => s.category == current.activeFilter)
              .toList(),
      categoryStats: stats,
    ));
  }

  Future<void> _onToggleFavorite(
      ToggleFavorite event, Emitter<ScreenshotState> emit) async {
    final current = state;
    if (current is! ScreenshotLoaded) return;

    await dbService.toggleFavorite(event.screenshotId, event.isFavorite);

    final updated = current.screenshots.map((s) {
      if (s.id == event.screenshotId) {
        return s.copyWith(isFavorite: event.isFavorite);
      }
      return s;
    }).toList();

    emit(current.copyWith(
      screenshots: updated,
      filteredScreenshots: current.activeFilter == null
          ? updated
          : updated
              .where((s) => s.category == current.activeFilter)
              .toList(),
    ));
  }

  Future<void> _onLoadCategory(
      LoadCategoryScreenshots event, Emitter<ScreenshotState> emit) async {
    emit(const ScreenshotLoading());
    try {
      final screenshots =
          await dbService.getScreenshotsByCategory(event.category);
      final stats = await dbService.getCategoryStats();
      emit(ScreenshotLoaded(
        screenshots: screenshots,
        filteredScreenshots: screenshots,
        categoryStats: stats,
        activeFilter: event.category,
      ));
    } catch (e) {
      emit(ScreenshotError('Failed to load category: $e'));
    }
  }

  Future<void> _onRefreshStats(
      RefreshStats event, Emitter<ScreenshotState> emit) async {
    final current = state;
    if (current is! ScreenshotLoaded) return;
    final stats = await dbService.getCategoryStats();
    emit(current.copyWith(categoryStats: stats));
  }

  @override
  Future<void> close() {
    categoryService.dispose();
    return super.close();
  }
}

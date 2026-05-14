import 'package:equatable/equatable.dart';

import '../../models/category_model.dart';

abstract class ScreenshotEvent extends Equatable {
  const ScreenshotEvent();

  @override
  List<Object?> get props => [];
}

/// Load all screenshots from local database
class LoadScreenshots extends ScreenshotEvent {
  const LoadScreenshots();
}

/// Scan new screenshots from the device gallery and categorise them
class ScanNewScreenshots extends ScreenshotEvent {
  const ScanNewScreenshots();
}

/// Filter the displayed screenshots by a category (null = show all)
class FilterByCategory extends ScreenshotEvent {
  final ScreenshotCategory? category;
  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Full-text search
class SearchScreenshots extends ScreenshotEvent {
  final String query;
  const SearchScreenshots(this.query);

  @override
  List<Object?> get props => [query];
}

/// User manually changed a screenshot's category
class CorrectCategory extends ScreenshotEvent {
  final String screenshotId;
  final ScreenshotCategory originalCategory;
  final ScreenshotCategory newCategory;

  const CorrectCategory({
    required this.screenshotId,
    required this.originalCategory,
    required this.newCategory,
  });

  @override
  List<Object?> get props => [screenshotId, originalCategory, newCategory];
}

/// Toggle favourite status
class ToggleFavorite extends ScreenshotEvent {
  final String screenshotId;
  final bool isFavorite;

  const ToggleFavorite({
    required this.screenshotId,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [screenshotId, isFavorite];
}

/// Load screenshots for a specific category view
class LoadCategoryScreenshots extends ScreenshotEvent {
  final ScreenshotCategory category;
  const LoadCategoryScreenshots(this.category);

  @override
  List<Object?> get props => [category];
}

/// Refresh category stats
class RefreshStats extends ScreenshotEvent {
  const RefreshStats();
}

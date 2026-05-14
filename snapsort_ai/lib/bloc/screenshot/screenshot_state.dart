import 'package:equatable/equatable.dart';

import '../../models/category_model.dart';
import '../../models/screenshot_model.dart';

abstract class ScreenshotState extends Equatable {
  const ScreenshotState();

  @override
  List<Object?> get props => [];
}

class ScreenshotInitial extends ScreenshotState {
  const ScreenshotInitial();
}

class ScreenshotLoading extends ScreenshotState {
  const ScreenshotLoading();
}

class ScreenshotScanning extends ScreenshotState {
  final int processed;
  final int total;

  const ScreenshotScanning({required this.processed, required this.total});

  double get progress => total > 0 ? processed / total : 0.0;

  @override
  List<Object?> get props => [processed, total];
}

class ScreenshotLoaded extends ScreenshotState {
  final List<ScreenshotModel> screenshots;
  final List<ScreenshotModel> filteredScreenshots;
  final ScreenshotCategory? activeFilter;
  final String searchQuery;
  final List<CategoryStats> categoryStats;
  final bool isSearching;

  const ScreenshotLoaded({
    required this.screenshots,
    required this.filteredScreenshots,
    required this.categoryStats,
    this.activeFilter,
    this.searchQuery = '',
    this.isSearching = false,
  });

  ScreenshotLoaded copyWith({
    List<ScreenshotModel>? screenshots,
    List<ScreenshotModel>? filteredScreenshots,
    ScreenshotCategory? activeFilter,
    bool clearFilter = false,
    String? searchQuery,
    List<CategoryStats>? categoryStats,
    bool? isSearching,
  }) {
    return ScreenshotLoaded(
      screenshots: screenshots ?? this.screenshots,
      filteredScreenshots: filteredScreenshots ?? this.filteredScreenshots,
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      categoryStats: categoryStats ?? this.categoryStats,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
        screenshots,
        filteredScreenshots,
        activeFilter,
        searchQuery,
        categoryStats,
        isSearching,
      ];
}

class ScreenshotError extends ScreenshotState {
  final String message;
  const ScreenshotError(this.message);

  @override
  List<Object?> get props => [message];
}

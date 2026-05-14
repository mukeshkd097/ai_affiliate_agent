import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../bloc/screenshot/screenshot_bloc.dart';
import '../../bloc/screenshot/screenshot_event.dart';
import '../../bloc/screenshot/screenshot_state.dart';
import '../../models/category_model.dart';
import '../../models/screenshot_model.dart';
import '../../theme/app_theme.dart';
import '../category/category_screen.dart';
import '../pro/pro_upgrade_screen.dart';
import '../search/search_screen.dart';
import '../../widgets/category_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/pro_banner.dart';
import '../../widgets/screenshot_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<ScreenshotBloc>().add(const LoadScreenshots());
  }

  void _onScan() {
    context.read<ScreenshotBloc>().add(const ScanNewScreenshots());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: const [
          _GalleryTab(),
          _CategoriesTab(),
          _FavoritesTab(),
        ],
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: _onScan,
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Scan',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (i) => setState(() => _selectedTab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library),
              label: 'Gallery'),
          NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder),
              label: 'Categories'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favorites'),
        ],
      ),
    );
  }
}

class _GalleryTab extends StatelessWidget {
  const _GalleryTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          title: Row(
            children: [
              Text(
                'SnapSort',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              const Text(' AI'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.workspace_premium_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProUpgradeScreen()),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: BlocBuilder<ScreenshotBloc, ScreenshotState>(
              builder: (context, state) {
                ScreenshotCategory? active;
                if (state is ScreenshotLoaded) active = state.activeFilter;
                return _CategoryChips(activeFilter: active);
              },
            ),
          ),
        ),
        BlocBuilder<ScreenshotBloc, ScreenshotState>(
          builder: (context, state) {
            if (state is ScreenshotLoading) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is ScreenshotScanning) {
              return SliverFillRemaining(
                child: _ScanProgress(state: state),
              );
            }
            if (state is ScreenshotError) {
              return SliverFillRemaining(
                child: Center(
                  child: Text(state.message,
                      textAlign: TextAlign.center),
                ),
              );
            }
            if (state is ScreenshotLoaded) {
              if (state.filteredScreenshots.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyState(
                    emoji: '📸',
                    title: 'No screenshots yet',
                    subtitle:
                        'Tap the Scan button to analyse your gallery.',
                  ),
                );
              }
              return _ScreenshotGrid(
                  screenshots: state.filteredScreenshots);
            }
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          },
        ),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final ScreenshotCategory? activeFilter;
  const _CategoryChips({this.activeFilter});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _Chip(
            label: 'All',
            isSelected: activeFilter == null,
            color: AppTheme.primary,
            onTap: () => context
                .read<ScreenshotBloc>()
                .add(const FilterByCategory(null)),
          ),
          ...ScreenshotCategory.values.map((cat) => _Chip(
                label: '${cat.emoji} ${cat.displayName}',
                isSelected: activeFilter == cat,
                color: cat.color,
                onTap: () => context
                    .read<ScreenshotBloc>()
                    .add(FilterByCategory(cat)),
              )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScreenshotGrid extends StatelessWidget {
  final List<ScreenshotModel> screenshots;
  const _ScreenshotGrid({required this.screenshots});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childCount: screenshots.length,
        itemBuilder: (context, index) =>
            ScreenshotCard(screenshot: screenshots[index]),
      ),
    );
  }
}

class _ScanProgress extends StatelessWidget {
  final ScreenshotScanning state;
  const _ScanProgress({required this.state});

  @override
  Widget build(BuildContext context) {
    final pct =
        state.total > 0 ? (state.processed / state.total * 100).round() : 0;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🤖',
              style: TextStyle(fontSize: 64)),
          const SizedBox(height: 24),
          Text(
            'Scanning your screenshots',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${state.processed} of ${state.total} processed',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation(AppTheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$pct%',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          title: Text('Categories'),
        ),
        BlocBuilder<ScreenshotBloc, ScreenshotState>(
          builder: (context, state) {
            if (state is! ScreenshotLoaded) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final stats = state.categoryStats
                .where((s) => s.count > 0)
                .toList();

            if (stats.isEmpty) {
              return const SliverFillRemaining(
                child: EmptyState(
                  emoji: '📁',
                  title: 'No categories yet',
                  subtitle: 'Scan your gallery to auto-organise.',
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: stats
                    .map((s) => CategoryTile(
                          stats: s,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryScreen(
                                  category: s.category),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScreenshotBloc, ScreenshotState>(
      builder: (context, state) {
        final favorites = state is ScreenshotLoaded
            ? state.screenshots.where((s) => s.isFavorite).toList()
            : <ScreenshotModel>[];

        return CustomScrollView(
          slivers: [
            const SliverAppBar(floating: true, title: Text('Favorites')),
            if (favorites.isEmpty)
              const SliverFillRemaining(
                child: EmptyState(
                  emoji: '❤️',
                  title: 'No favorites yet',
                  subtitle: 'Tap the heart on any screenshot to save it.',
                ),
              )
            else
              _ScreenshotGrid(screenshots: favorites),
          ],
        );
      },
    );
  }
}

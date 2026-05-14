import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../bloc/screenshot/screenshot_bloc.dart';
import '../../bloc/screenshot/screenshot_event.dart';
import '../../bloc/screenshot/screenshot_state.dart';
import '../../models/category_model.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screenshot_card.dart';

class CategoryScreen extends StatefulWidget {
  final ScreenshotCategory category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<ScreenshotBloc>()
        .add(LoadCategoryScreenshots(widget.category));
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(cat.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(cat.displayName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // TODO: sort options
            },
          ),
        ],
      ),
      body: BlocBuilder<ScreenshotBloc, ScreenshotState>(
        builder: (context, state) {
          if (state is ScreenshotLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ScreenshotLoaded) {
            if (state.filteredScreenshots.isEmpty) {
              return EmptyState(
                emoji: cat.emoji,
                title: 'No ${cat.displayName} screenshots',
                subtitle: 'Scan your gallery to find them.',
              );
            }
            return MasonryGridView.count(
              padding: const EdgeInsets.all(12),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: state.filteredScreenshots.length,
              itemBuilder: (context, index) =>
                  ScreenshotCard(screenshot: state.filteredScreenshots[index]),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

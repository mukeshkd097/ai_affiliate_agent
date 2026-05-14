import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/screenshot/screenshot_bloc.dart';
import '../../bloc/screenshot/screenshot_event.dart';
import '../../models/category_model.dart';
import '../../models/screenshot_model.dart';
import '../../theme/app_theme.dart';

class ScreenshotDetailScreen extends StatelessWidget {
  final ScreenshotModel screenshot;

  const ScreenshotDetailScreen({super.key, required this.screenshot});

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CategoryPicker(
        current: screenshot.category,
        onSelected: (cat) {
          context.read<ScreenshotBloc>().add(CorrectCategory(
                screenshotId: screenshot.id,
                originalCategory: screenshot.category,
                newCategory: cat,
              ));
          Navigator.pop(ctx);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cat = screenshot.category;
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(
        screenshot.capturedAt);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              screenshot.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: screenshot.isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () => context.read<ScreenshotBloc>().add(ToggleFavorite(
                  screenshotId: screenshot.id,
                  isFavorite: !screenshot.isFavorite,
                )),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Share logic via share_plus (future)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Center(
                child: Image.file(
                  File(screenshot.localPath),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),

          // Bottom info panel
          Container(
            color: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Category badge
                    GestureDetector(
                      onTap: () => _showCategoryPicker(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: cat.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cat.color, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(cat.emoji),
                            const SizedBox(width: 6),
                            Text(
                              cat.displayName,
                              style: TextStyle(
                                color: cat.color,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.edit, size: 12, color: cat.color),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(screenshot.confidenceScore * 100).round()}% match',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  dateStr,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 13),
                ),
                if (screenshot.ocrText != null &&
                    screenshot.ocrText!.isNotEmpty) ...
                [
                  const SizedBox(height: 12),
                  const Text(
                    'Detected text',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    screenshot.ocrText!.length > 200
                        ? '${screenshot.ocrText!.substring(0, 200)}…'
                        : screenshot.ocrText!,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12, height: 1.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final ScreenshotCategory current;
  final ValueChanged<ScreenshotCategory> onSelected;

  const _CategoryPicker(
      {required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Move to category',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: ScreenshotCategory.values.map((cat) {
              final isSelected = cat == current;
              return ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cat.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      Center(child: Text(cat.emoji)),
                ),
                title: Text(cat.displayName),
                trailing: isSelected
                    ? Icon(Icons.check_circle,
                        color: cat.color)
                    : null,
                onTap: () => onSelected(cat),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

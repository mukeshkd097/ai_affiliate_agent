import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/screenshot/screenshot_bloc.dart';
import '../bloc/screenshot/screenshot_event.dart';
import '../models/screenshot_model.dart';
import '../screens/detail/screenshot_detail_screen.dart';

class ScreenshotCard extends StatelessWidget {
  final ScreenshotModel screenshot;

  const ScreenshotCard({super.key, required this.screenshot});

  @override
  Widget build(BuildContext context) {
    final cat = screenshot.category;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<ScreenshotBloc>(),
            child: ScreenshotDetailScreen(screenshot: screenshot),
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Screenshot image
            Image.file(
              File(screenshot.localPath),
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                height: 160,
                color: cat.color.withOpacity(0.1),
                child: Center(
                  child: Icon(cat.icon, color: cat.color, size: 40),
                ),
              ),
            ),

            // Category badge
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cat.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  cat.emoji,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),

            // Favorite button
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: Icon(
                  screenshot.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: screenshot.isFavorite
                      ? Colors.red
                      : Colors.white70,
                  size: 20,
                ),
                onPressed: () =>
                    context.read<ScreenshotBloc>().add(ToggleFavorite(
                          screenshotId: screenshot.id,
                          isFavorite: !screenshot.isFavorite,
                        )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

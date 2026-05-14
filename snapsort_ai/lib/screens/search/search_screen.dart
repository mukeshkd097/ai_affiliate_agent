import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../bloc/screenshot/screenshot_bloc.dart';
import '../../bloc/screenshot/screenshot_event.dart';
import '../../bloc/screenshot/screenshot_state.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screenshot_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _debounce = _Debouncer(delay: const Duration(milliseconds: 400));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce.run(() {
      context.read<ScreenshotBloc>().add(SearchScreenshots(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 8,
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: 'Search screenshots…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      _onChanged('');
                    },
                  )
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
      body: BlocBuilder<ScreenshotBloc, ScreenshotState>(
        builder: (context, state) {
          if (state is ScreenshotLoaded && state.isSearching) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ScreenshotLoaded) {
            if (_controller.text.isEmpty) {
              return const EmptyState(
                emoji: '🔍',
                title: 'Search your screenshots',
                subtitle:
                    'Try: "OTP", "amazon", "zerodha", "receipt"…',
              );
            }

            if (state.filteredScreenshots.isEmpty) {
              return EmptyState(
                emoji: '🤷',
                title: 'Nothing found',
                subtitle: 'No screenshots matched "${_controller.text}".',
              );
            }

            return MasonryGridView.count(
              padding: const EdgeInsets.all(12),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: state.filteredScreenshots.length,
              itemBuilder: (context, index) => ScreenshotCard(
                  screenshot: state.filteredScreenshots[index]),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _Debouncer {
  final Duration delay;
  DateTime? _last;

  _Debouncer({required this.delay});

  void run(VoidCallback action) {
    _last = DateTime.now();
    final last = _last!;
    Future.delayed(delay, () {
      if (_last == last) action();
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'search_provider.dart';
import '../player/player_provider.dart';
import 'widgets/search_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final text = _searchController.text;
    if (_hasText != text.isNotEmpty) {
      setState(() => _hasText = text.isNotEmpty);
    }
    ref.read(searchProvider.notifier).setQuery(text);
  }

  void _onSubmit(String query) {
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      ref.read(searchProvider.notifier).addToHistory(trimmed);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _focusNode.requestFocus();
  }

  void _onHistoryTap(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            focusNode: _focusNode,
            hasText: _hasText,
            onSubmitted: _onSubmit,
            onClear: _clearSearch,
            colorScheme: colorScheme,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: state.query.isEmpty
                  ? _EmptySearchView(
                      key: const ValueKey('empty'),
                      state: state,
                      onHistoryTap: _onHistoryTap,
                      onClearHistory: () =>
                          ref.read(searchProvider.notifier).clearHistory(),
                      onRemoveHistory: (q) =>
                          ref.read(searchProvider.notifier).removeFromHistory(q),
                    )
                  : _ResultsView(
                      key: const ValueKey('results'),
                      state: state,
                      onSuggestionTap: (suggestion) {
                        _searchController.text = suggestion;
                        _searchController.selection = TextSelection.fromPosition(
                          TextPosition(offset: suggestion.length),
                        );
                        ref.read(searchProvider.notifier).addToHistory(suggestion);
                      },
                      onTrackTap: (track, results) {
                        ref.read(playerProvider.notifier).playTrack(track, queue: results);
                        final q = _searchController.text.trim();
                        if (q.isNotEmpty) {
                          ref.read(searchProvider.notifier).addToHistory(q);
                        }
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search Bar ────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final ColorScheme colorScheme;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.hasText,
    required this.onSubmitted,
    required this.onClear,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: 'What do you want to listen to?',
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          suffixIcon: hasText
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ─── Empty State (no query) ────────────────────────────────────────────────

class _EmptySearchView extends StatelessWidget {
  final SearchState state;
  final ValueChanged<String> onHistoryTap;
  final VoidCallback onClearHistory;
  final ValueChanged<String> onRemoveHistory;

  const _EmptySearchView({
    super.key,
    required this.state,
    required this.onHistoryTap,
    required this.onClearHistory,
    required this.onRemoveHistory,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () => Future.delayed(const Duration(milliseconds: 300)),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Browse section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _BrowseChipData.values.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final chip = _BrowseChipData.values[index];
                      return FilterChip(
                        avatar: Icon(chip.icon, size: 16),
                        label: Text(chip.label),
                        onSelected: (_) {
                          // Placeholder — no action yet
                        },
                        selected: false,
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Recent searches
          if (state.searchHistory.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: onClearHistory,
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            ...state.searchHistory.map(
              (query) => ListTile(
                leading: Icon(
                  Icons.history,
                  size: 20,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                title: Text(
                  query,
                  style: textTheme.bodyMedium,
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                  onPressed: () => onRemoveHistory(query),
                  visualDensity: VisualDensity.compact,
                ),
                onTap: () => onHistoryTap(query),
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Results State (has query) ─────────────────────────────────────────────

class _ResultsView extends StatelessWidget {
  final SearchState state;
  final ValueChanged<String> onSuggestionTap;
  final void Function(Track track, List<Track> results) onTrackTap;

  const _ResultsView({
    super.key,
    required this.state,
    required this.onSuggestionTap,
    required this.onTrackTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (state.isSearching) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 3),
      );
    }

    if (state.results.isEmpty && state.suggestions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 72,
                color: colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final itemCount = _computeItemCount();

    return RefreshIndicator(
      onRefresh: () async {
        // Re-trigger the current search
        // The provider handles this synchronously
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return _buildItem(context, index, colorScheme, textTheme);
        },
      ),
    );
  }

  int _computeItemCount() {
    int count = 0;
    if (state.suggestions.isNotEmpty) count += state.suggestions.length + 1; // header + items
    if (state.results.isNotEmpty) count += state.results.length + 1; // header + items
    return count;
  }

  Widget _buildItem(BuildContext context, int index, ColorScheme colorScheme, TextTheme textTheme) {
    final hasSuggestions = state.suggestions.isNotEmpty;

    // Suggestions section
    if (hasSuggestions && index == 0) {
      return _sectionHeader('Suggestions', colorScheme, textTheme);
    }

    if (hasSuggestions && index >= 1 && index <= state.suggestions.length) {
      final suggestion = state.suggestions[index - 1];
      return ListTile(
        leading: Icon(
          Icons.trending_up,
          size: 20,
          color: colorScheme.primary.withValues(alpha: 0.7),
        ),
        title: Text(suggestion, style: textTheme.bodyMedium),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: () => onSuggestionTap(suggestion),
      );
    }

    // Results section
    final adjusted = index - (hasSuggestions ? state.suggestions.length + 1 : 0);

    if (adjusted == 0 && state.results.isNotEmpty) {
      return _sectionHeader('Songs', colorScheme, textTheme);
    }

    final trackIndex = adjusted - 1;
    if (trackIndex >= 0 && trackIndex < state.results.length) {
      final track = state.results[trackIndex];
      return SearchTile(
        track: track,
        onTap: () => onTrackTap(track, state.results),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _sectionHeader(String title, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: textTheme.titleSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Browse chip data ─────────────────────────────────────────────────────

class _BrowseChipData {
  final String label;
  final IconData icon;

  const _BrowseChipData(this.label, this.icon);

  static const List<_BrowseChipData> values = [
    _BrowseChipData('Pop', Icons.music_note),
    _BrowseChipData('Rock', Icons.flash_on),
    _BrowseChipData('Hip-Hop', Icons.mic),
    _BrowseChipData('Electronic', Icons.waves),
    _BrowseChipData('R&B', Icons.favorite),
    _BrowseChipData('Mood', Icons.mood),
    _BrowseChipData('Workout', Icons.fitness_center),
    _BrowseChipData('Chill', Icons.beach_access),
    _BrowseChipData('Indie', Icons.headphones),
    _BrowseChipData('Jazz', Icons.piano),
    _BrowseChipData('Classical', Icons.auto_stories),
    _BrowseChipData('Country', Icons.landscape),
    _BrowseChipData('Metal', Icons.bolt),
    _BrowseChipData('Folk', Icons.people),
    _BrowseChipData('Latin', Icons.celebration),
  ];
}

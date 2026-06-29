import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'library_provider.dart';
import 'widgets/library_grid_card.dart';
import '../player/player_provider.dart';

enum _LibraryFilter { playlists, albums, artists, songs }

const _filterLabels = {
  _LibraryFilter.playlists: 'Playlists',
  _LibraryFilter.albums: 'Albums',
  _LibraryFilter.artists: 'Artists',
  _LibraryFilter.songs: 'Songs',
};

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  _LibraryFilter _selectedFilter = _LibraryFilter.playlists;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(libraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterChips(
            selected: _selectedFilter,
            onSelected: (filter) => setState(() => _selectedFilter = filter),
          ),
          Expanded(
            child: state.isLoading
                ? const _LibraryShimmer()
                : RefreshIndicator(
                    onRefresh: () => ref.read(libraryProvider.notifier).refresh(),
                    child: _buildContent(context, ref, state),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, LibraryState state) {
    final hasContent = switch (_selectedFilter) {
      _LibraryFilter.playlists => state.playlists.isNotEmpty,
      _LibraryFilter.albums => state.likedAlbums.isNotEmpty,
      _LibraryFilter.artists => state.followedArtists.isNotEmpty,
      _LibraryFilter.songs => state.likedTracks.isNotEmpty,
    };

    if (!hasContent) {
      return _buildEmptyState(context);
    }

    return switch (_selectedFilter) {
      _LibraryFilter.playlists => _buildPlaylistsGrid(context, ref, state),
      _LibraryFilter.albums => _buildAlbumsGrid(context, ref, state),
      _LibraryFilter.artists => _buildArtistsGrid(context, ref, state),
      _LibraryFilter.songs => _buildSongsList(context, ref, state),
    };
  }

  Widget _buildPlaylistsGrid(BuildContext context, WidgetRef ref, LibraryState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 600 ? 3 : 2;
        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: state.playlists.length,
          itemBuilder: (context, index) {
            final playlist = state.playlists[index];
            return LibraryGridCard(
              imageUrl: playlist.imageUrl,
              title: playlist.name,
              subtitle: '${playlist.trackCount} songs',
              onTap: () => context.go('/playlist/${playlist.id}'),
            ).animate().fadeIn(
              duration: 400.ms,
              delay: (index * 30).ms,
            ).slideY(
              begin: 0.1,
              duration: 400.ms,
              delay: (index * 30).ms,
              curve: Curves.easeOutCubic,
            );
          },
        );
      },
    );
  }

  Widget _buildAlbumsGrid(BuildContext context, WidgetRef ref, LibraryState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 600 ? 3 : 2;
        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: state.likedAlbums.length,
          itemBuilder: (context, index) {
            final album = state.likedAlbums[index];
            return LibraryGridCard(
              imageUrl: album.imageUrl,
              title: album.title,
              subtitle: album.artist,
              onTap: () => context.go('/album/${album.id}'),
            ).animate().fadeIn(
              duration: 400.ms,
              delay: (index * 30).ms,
            ).slideY(
              begin: 0.1,
              duration: 400.ms,
              delay: (index * 30).ms,
              curve: Curves.easeOutCubic,
            );
          },
        );
      },
    );
  }

  Widget _buildArtistsGrid(BuildContext context, WidgetRef ref, LibraryState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 600 ? 3 : 2;
        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: state.followedArtists.length,
          itemBuilder: (context, index) {
            final artist = state.followedArtists[index];
            return LibraryGridCard(
              imageUrl: artist.imageUrl,
              title: artist.name,
              subtitle: 'Artist',
              isCircularImage: true,
              onTap: () => context.go('/artist/${artist.id}'),
            ).animate().fadeIn(
              duration: 400.ms,
              delay: (index * 30).ms,
            ).slideY(
              begin: 0.1,
              duration: 400.ms,
              delay: (index * 30).ms,
              curve: Curves.easeOutCubic,
            );
          },
        );
      },
    );
  }

  Widget _buildSongsList(BuildContext context, WidgetRef ref, LibraryState state) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: state.likedTracks.length,
      itemBuilder: (context, index) {
        final track = state.likedTracks[index];
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 48,
              height: 48,
              color: colorScheme.surfaceContainerHighest,
              child: track.albumArtUrl != null
                  ? Image.network(track.albumArtUrl!, fit: BoxFit.cover)
                  : Center(
                      child: Icon(
                        Icons.music_note,
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
            ),
          ),
          title: Text(
            track.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            track.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onPressed: () {
              // TODO: Show track options
            },
          ),
          onTap: () {
            ref.read(playerProvider.notifier).playTrack(track);
          },
        ).animate().fadeIn(
          duration: 400.ms,
          delay: (index * 20).ms,
        ).slideX(
          begin: 0.05,
          duration: 400.ms,
          delay: (index * 20).ms,
          curve: Curves.easeOutCubic,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              switch (_selectedFilter) {
                _LibraryFilter.playlists => Icons.playlist_play_outlined,
                _LibraryFilter.albums => Icons.album_outlined,
                _LibraryFilter.artists => Icons.person_outline,
                _LibraryFilter.songs => Icons.music_note_outlined,
              },
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 16),
            Text(
              switch (_selectedFilter) {
                _LibraryFilter.playlists => 'No playlists yet',
                _LibraryFilter.albums => 'No saved albums',
                _LibraryFilter.artists => 'No followed artists',
                _LibraryFilter.songs => 'No liked songs',
              },
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your library is empty',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, duration: 600.ms);
  }
}

// ---------------------------------------------------------------------------
// Filter Chips Row
// ---------------------------------------------------------------------------
class _FilterChips extends StatelessWidget {
  final _LibraryFilter selected;
  final ValueChanged<_LibraryFilter> onSelected;

  const _FilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _LibraryFilter.values.map((filter) {
          final isSelected = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_filterLabels[filter]!),
              selected: isSelected,
              onSelected: (_) => onSelected(filter),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: colorScheme.surfaceContainerHighest,
              selectedColor: colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
              checkmarkColor: colorScheme.onPrimary,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer Loading Placeholder
// ---------------------------------------------------------------------------
class _LibraryShimmer extends StatefulWidget {
  const _LibraryShimmer();

  @override
  State<_LibraryShimmer> createState() => _LibraryShimmerState();
}

class _LibraryShimmerState extends State<_LibraryShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFE0E0E0);
    final highlightColor = theme.brightness == Brightness.dark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFF0F0F0);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shade = Tween<double>(begin: 0.0, end: 1.0).evaluate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
        );
        final shimmer = Color.lerp(baseColor, highlightColor, shade)!;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: shimmer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    color: shimmer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    color: shimmer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

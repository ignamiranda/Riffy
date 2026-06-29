import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../player/player_provider.dart';

String _formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String _totalDuration(List<Track> tracks) {
  final total = tracks.fold<Duration>(Duration.zero, (sum, t) => sum + t.duration);
  final hours = total.inHours;
  final minutes = total.inMinutes.remainder(60);
  if (hours > 0) return '${hours}h ${minutes}min';
  return '${minutes}min';
}

class AlbumScreen extends ConsumerWidget {
  final String albumId;
  const AlbumScreen({super.key, required this.albumId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final playerState = ref.watch(playerProvider);

    final albumTitle = 'Sample Album';
    final artistName = 'Sample Artist';
    final artistId = 'artist-1';
    final year = '2024';

    final tracks = List.generate(12, (i) => Track(
      id: '$albumId-track-${i + 1}',
      title: 'Track ${i + 1}${i == 3 ? ' (feat. Another Artist)' : ''}',
      artist: i == 3 ? 'Sample Artist, Another Artist' : artistName,
      album: albumTitle,
      duration: Duration(seconds: 180 + i * 12 + (i % 3) * 7),
    ));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              title: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Text(
                  albumTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: colorScheme.primaryContainer,
                    child: Center(
                      child: Icon(
                        Icons.album,
                        size: 160,
                        color: colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          albumTitle,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => context.push('/artist/$artistId'),
                          child: Text(
                            artistName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          year,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  FilledButton.icon(
                    onPressed: tracks.isNotEmpty
                        ? () {
                            ref.read(playerProvider.notifier).playTrack(
                              tracks.first,
                              queue: tracks,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Shuffle Play'),
                  ),
                  const SizedBox(width: 12),
                  IconButton.outlined(
                    onPressed: () {},
                    icon: const Icon(Icons.library_add_outlined),
                    tooltip: 'Add to Library',
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                '${tracks.length} songs, ${_totalDuration(tracks)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final track = tracks[index];
                final isCurrent = playerState.currentTrack?.id == track.id;
                final showArtist = track.artist != artistName;

                return _TrackRow(
                  index: index,
                  track: track,
                  isCurrent: isCurrent,
                  showArtist: showArtist,
                  onTap: () {
                    ref.read(playerProvider.notifier).playTrack(
                      track,
                      queue: tracks,
                    );
                  },
                );
              },
              childCount: tracks.length,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
          ),
        ],
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  final int index;
  final Track track;
  final bool isCurrent;
  final bool showArtist;
  final VoidCallback onTap;

  const _TrackRow({
    required this.index,
    required this.track,
    required this.isCurrent,
    required this.showArtist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: SizedBox(
        width: 24,
        child: Text(
          '${index + 1}',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isCurrent
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
          color: isCurrent ? colorScheme.primary : null,
        ),
      ),
      subtitle: showArtist
          ? Text(
              track.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: Text(
        _formatDuration(track.duration),
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      onTap: onTap,
    );
  }
}

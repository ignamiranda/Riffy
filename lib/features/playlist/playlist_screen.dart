import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class PlaylistScreen extends ConsumerWidget {
  final String playlistId;
  const PlaylistScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final playerState = ref.watch(playerProvider);

    final playlistName = 'Sample Playlist';
    final playlistDesc = 'A curated collection of sample tracks for demonstration.';
    final ownerName = 'YouTube Music';
    final trackCount = 20;

    final tracks = List.generate(trackCount, (i) => Track(
      id: '$playlistId-track-${i + 1}',
      title: 'Playlist Track ${i + 1}',
      artist: i.isEven ? 'Artist Alpha' : 'Artist Beta',
      album: 'Album ${(i ~/ 4) + 1}',
      duration: Duration(seconds: 200 + i * 8 + (i % 5) * 10),
    ));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
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
                  playlistName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: colorScheme.tertiaryContainer,
                    child: Center(
                      child: Icon(
                        Icons.playlist_play,
                        size: 140,
                        color: colorScheme.tertiary.withValues(alpha: 0.2),
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
                          stops: const [0.4, 1.0],
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 48,
                            height: 48,
                            color: colorScheme.tertiary.withValues(alpha: 0.3),
                            child: Icon(
                              Icons.playlist_play,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          playlistName,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (playlistDesc.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            playlistDesc,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '$ownerName · $trackCount songs',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white60,
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
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Download'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface.withValues(alpha: 0.7),
                      side: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                '$trackCount songs, ${_totalDuration(tracks)}',
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

                return _PlaylistTrackRow(
                  index: index,
                  track: track,
                  isCurrent: isCurrent,
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

class _PlaylistTrackRow extends StatelessWidget {
  final int index;
  final Track track;
  final bool isCurrent;
  final VoidCallback onTap;

  const _PlaylistTrackRow({
    required this.index,
    required this.track,
    required this.isCurrent,
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
      subtitle: Text(
        track.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatDuration(track.duration),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.drag_handle,
            size: 20,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

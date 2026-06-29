import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../player/player_provider.dart';

String _formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class ArtistScreen extends ConsumerWidget {
  final String artistId;
  const ArtistScreen({super.key, required this.artistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final playerState = ref.watch(playerProvider);

    final artistName = 'Sample Artist';
    final isFollowing = false;

    final popularTracks = List.generate(5, (i) => Track(
      id: '$artistId-popular-${i + 1}',
      title: 'Popular Track ${i + 1}${i == 0 ? ' (Hit Song)' : ''}',
      artist: artistName,
      album: 'Album ${(i ~/ 2) + 1}',
      duration: Duration(seconds: 210 + i * 10),
    ));

    final albums = List.generate(6, (i) => _AlbumItem(
      id: '$artistId-album-${i + 1}',
      title: 'Album ${i + 1}',
      year: '${2024 - i}',
    ));

    final similarArtists = List.generate(6, (i) => _ArtistItem(
      id: 'similar-${i + 1}',
      name: 'Similar Artist ${i + 1}',
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
                  artistName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: colorScheme.secondaryContainer,
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 180,
                        color: colorScheme.secondary.withValues(alpha: 0.15),
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
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 24,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: colorScheme.secondary.withValues(alpha: 0.3),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          artistName,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Artist',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white60,
                            letterSpacing: 1.5,
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
                    onPressed: popularTracks.isNotEmpty
                        ? () {
                            ref.read(playerProvider.notifier).playTrack(
                              popularTracks.first,
                              queue: popularTracks,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Shuffle Play'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(isFollowing ? Icons.favorite : Icons.favorite_outline),
                    label: Text(isFollowing ? 'Following' : 'Follow'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isFollowing
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                      side: BorderSide(
                        color: isFollowing
                            ? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Popular tracks section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Popular',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final track = popularTracks[index];
                final isCurrent = playerState.currentTrack?.id == track.id;

                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: SizedBox(
                    width: 24,
                    child: Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
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
                    '${_formatDuration(track.duration)} · ${track.album ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isCurrent ? Icons.play_circle_filled : Icons.play_circle_outline,
                      color: isCurrent ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    onPressed: () {
                      ref.read(playerProvider.notifier).playTrack(
                        track,
                        queue: popularTracks,
                      );
                    },
                  ),
                  onTap: () {
                    ref.read(playerProvider.notifier).playTrack(
                      track,
                      queue: popularTracks,
                    );
                  },
                );
              },
              childCount: popularTracks.length,
            ),
          ),
          // Albums section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Albums',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: albums.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final album = albums[index];
                  return GestureDetector(
                    onTap: () => context.push('/album/${album.id}'),
                    child: SizedBox(
                      width: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 140,
                              height: 140,
                              color: colorScheme.primaryContainer.withValues(alpha: 0.3 + (index % 3) * 0.15),
                              child: Center(
                                child: Icon(
                                  Icons.album,
                                  size: 48,
                                  color: colorScheme.primary.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            album.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Album · ${album.year}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(
                    duration: 400.ms,
                    delay: (index * 50).ms,
                  ).slideX(
                    begin: 0.1,
                    duration: 400.ms,
                    delay: (index * 50).ms,
                    curve: Curves.easeOutCubic,
                  );
                },
              ),
            ),
          ),
          // Similar artists section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Similar Artists',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: similarArtists.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final artist = similarArtists[index];
                  return GestureDetector(
                    onTap: () => context.push('/artist/${artist.id}'),
                    child: SizedBox(
                      width: 90,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: colorScheme.secondaryContainer.withValues(alpha: 0.4),
                            child: Icon(
                              Icons.person,
                              size: 36,
                              color: colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            artist.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(
                    duration: 400.ms,
                    delay: (index * 50).ms,
                  );
                },
              ),
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

class _AlbumItem {
  final String id;
  final String title;
  final String year;
  const _AlbumItem({required this.id, required this.title, required this.year});
}

class _ArtistItem {
  final String id;
  final String name;
  const _ArtistItem({required this.id, required this.name});
}

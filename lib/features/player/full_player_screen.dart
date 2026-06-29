import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'player_provider.dart';
import 'queue_sheet.dart';

class FullPlayerScreen extends ConsumerWidget {
  const FullPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playerProvider);
    final track = state.currentTrack;

    if (track == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            'No track selected',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ----- Background: blurred album art -----
          if (track.albumArtUrl != null)
            Positioned.fill(
              child: Image.network(
                track.albumArtUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            )
          else
            Container(color: const Color(0xFF121212)),

          // Blur filter
          if (track.albumArtUrl != null)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),

          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.85),
                    const Color(0xFF0A0A0A),
                  ],
                ),
              ),
            ),
          ),

          // ----- Foreground content -----
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down, size: 28),
                        color: Colors.white,
                        onPressed: () => context.pop(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.queue_music),
                        color: Colors.white,
                        onPressed: () => _showQueue(context),
                      ),
                    ],
                  ),
                ),

                // Album art
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: track.albumArtUrl != null
                                ? Image.network(track.albumArtUrl!, fit: BoxFit.cover)
                                : Container(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    child: Icon(
                                      Icons.music_note,
                                      size: 80,
                                      color: Colors.white.withValues(alpha: 0.4),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Track info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        track.title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        track.artist,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withValues(alpha: 0.15),
                        ),
                        child: Slider(
                          value: state.duration.inMilliseconds > 0
                              ? state.position.inMilliseconds /
                                  state.duration.inMilliseconds
                              : 0.0,
                          onChanged: (value) {
                            final pos = Duration(
                              milliseconds:
                                  (value * state.duration.inMilliseconds).round(),
                            );
                            ref.read(playerProvider.notifier).seek(pos);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(state.position),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              _formatDuration(state.duration),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Controls row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Shuffle
                      IconButton(
                        icon: const Icon(Icons.shuffle),
                        iconSize: 24,
                        color: state.isShuffled
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white.withValues(alpha: 0.7),
                        onPressed: () => ref.read(playerProvider.notifier).toggleShuffle(),
                      ),
                      const SizedBox(width: 8),
                      // Previous
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 32,
                        color: Colors.white,
                        onPressed: () => ref.read(playerProvider.notifier).previous(),
                      ),
                      const SizedBox(width: 8),
                      // Play/Pause
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            state.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          iconSize: 32,
                          color: Colors.black,
                          onPressed: () => ref.read(playerProvider.notifier).togglePlayPause(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Next
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        iconSize: 32,
                        color: Colors.white,
                        onPressed: () => ref.read(playerProvider.notifier).next(),
                      ),
                      const SizedBox(width: 8),
                      // Repeat
                      _RepeatButton(),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQueue(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QueueSheet(),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _RepeatButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repeatMode = ref.watch(playerProvider.select((s) => s.repeatMode));

    IconData icon;
    Color color;
    switch (repeatMode) {
      case RepeatMode.off:
        icon = Icons.repeat;
        color = Colors.white.withValues(alpha: 0.7);
      case RepeatMode.one:
        icon = Icons.repeat_one;
        color = Theme.of(context).colorScheme.primary;
      case RepeatMode.all:
        icon = Icons.repeat;
        color = Theme.of(context).colorScheme.primary;
    }

    return IconButton(
      icon: Icon(icon),
      iconSize: 24,
      color: color,
      onPressed: () => ref.read(playerProvider.notifier).cycleRepeatMode(),
    );
  }
}

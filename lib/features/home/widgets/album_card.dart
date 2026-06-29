import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../player/player_provider.dart';

class AlbumCard extends ConsumerWidget {
  final Track track;
  final int index;

  const AlbumCard({
    super.key,
    required this.track,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        ref.read(playerProvider.notifier).playTrack(track);
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album art placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 140,
                height: 140,
                color: _cardColor(track.title, colorScheme),
                child: Center(
                  child: Text(
                    track.title.isNotEmpty
                        ? track.title[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            // Artist subtitle
            Text(
              track.artist,
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
  }

  Color _cardColor(String title, ColorScheme colorScheme) {
    // Deterministic color based on title hash for variety
    final hash = title.hashCode;
    final colors = [
      colorScheme.primary.withValues(alpha: 0.2),
      colorScheme.tertiary.withValues(alpha: 0.2),
      colorScheme.secondary.withValues(alpha: 0.2),
      Colors.orange.withValues(alpha: 0.2),
      Colors.teal.withValues(alpha: 0.2),
      Colors.indigo.withValues(alpha: 0.2),
    ];
    return colors[hash.abs() % colors.length];
  }
}

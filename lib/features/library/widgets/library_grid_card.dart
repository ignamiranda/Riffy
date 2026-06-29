import 'package:flutter/material.dart';

class LibraryGridCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String subtitle;
  final bool isCircularImage;
  final VoidCallback onTap;

  const LibraryGridCard({
    super.key,
    this.imageUrl,
    required this.title,
    required this.subtitle,
    this.isCircularImage = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: isCircularImage
                    ? BorderRadius.circular(999)
                    : BorderRadius.circular(12),
                color: colorScheme.surfaceContainerHighest,
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildImage(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (imageUrl != null) {
      return Image.network(imageUrl!, fit: BoxFit.cover);
    }

    return Center(
      child: Icon(
        Icons.music_note,
        size: 32,
        color: colorScheme.onSurface.withValues(alpha: 0.3),
      ),
    );
  }
}

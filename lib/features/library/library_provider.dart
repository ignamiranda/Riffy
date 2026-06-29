import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../player/player_provider.dart';

class PlaylistInfo {
  final String id;
  final String name;
  final int trackCount;
  final String? imageUrl;

  const PlaylistInfo({
    required this.id,
    required this.name,
    required this.trackCount,
    this.imageUrl,
  });
}

class AlbumInfo {
  final String id;
  final String title;
  final String artist;
  final String? imageUrl;
  final int? year;

  const AlbumInfo({
    required this.id,
    required this.title,
    required this.artist,
    this.imageUrl,
    this.year,
  });
}

class ArtistInfo {
  final String id;
  final String name;
  final String? imageUrl;

  const ArtistInfo({
    required this.id,
    required this.name,
    this.imageUrl,
  });
}

class LibraryState {
  final List<PlaylistInfo> playlists;
  final List<Track> likedTracks;
  final List<AlbumInfo> likedAlbums;
  final List<ArtistInfo> followedArtists;
  final bool isLoading;

  const LibraryState({
    this.playlists = const [],
    this.likedTracks = const [],
    this.likedAlbums = const [],
    this.followedArtists = const [],
    this.isLoading = false,
  });

  LibraryState copyWith({
    List<PlaylistInfo>? playlists,
    List<Track>? likedTracks,
    List<AlbumInfo>? likedAlbums,
    List<ArtistInfo>? followedArtists,
    bool? isLoading,
  }) {
    return LibraryState(
      playlists: playlists ?? this.playlists,
      likedTracks: likedTracks ?? this.likedTracks,
      likedAlbums: likedAlbums ?? this.likedAlbums,
      followedArtists: followedArtists ?? this.followedArtists,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  LibraryNotifier() : super(const LibraryState());

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    // TODO: Fetch library data from InnerTube/API
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(isLoading: false);
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>(
  (ref) => LibraryNotifier(),
);

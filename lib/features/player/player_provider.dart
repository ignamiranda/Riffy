import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class Track {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? albumArtUrl;
  final Duration duration;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.albumArtUrl,
    this.duration = Duration.zero,
  });
}

enum RepeatMode { off, one, all }

class PlayerState {
  final Track? currentTrack;
  final List<Track> queue;
  final bool isPlaying;
  final bool isShuffled;
  final RepeatMode repeatMode;
  final Duration position;
  final Duration duration;

  const PlayerState({
    this.currentTrack,
    this.queue = const [],
    this.isPlaying = false,
    this.isShuffled = false,
    this.repeatMode = RepeatMode.off,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  PlayerState copyWith({
    Track? currentTrack,
    List<Track>? queue,
    bool? isPlaying,
    bool? isShuffled,
    RepeatMode? repeatMode,
    Duration? position,
    Duration? duration,
  }) {
    return PlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      queue: queue ?? this.queue,
      isPlaying: isPlaying ?? this.isPlaying,
      isShuffled: isShuffled ?? this.isShuffled,
      repeatMode: repeatMode ?? this.repeatMode,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  final AudioPlayer _audioPlayer;

  PlayerNotifier() : _audioPlayer = AudioPlayer(), super(const PlayerState()) {
    _audioPlayer.positionStream.listen((pos) {
      if (!mounted) return;
      state = state.copyWith(position: pos);
    });
    _audioPlayer.durationStream.listen((dur) {
      if (!mounted) return;
      state = state.copyWith(duration: dur ?? Duration.zero);
    });
    _audioPlayer.playerStateStream.listen((playerState) {
      if (!mounted) return;
      state = state.copyWith(isPlaying: playerState.playing);
    });
  }

  Future<void> playTrack(Track track, {List<Track>? queue}) async {
    final q = queue ?? [track];
    state = state.copyWith(currentTrack: track, queue: q, isPlaying: true);
    // TODO: Set audio source from InnerTube stream URL
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> next() async {
    // TODO: Play next track in queue
  }

  Future<void> previous() async {
    // TODO: Play previous track
  }

  void toggleShuffle() {
    state = state.copyWith(isShuffled: !state.isShuffled);
  }

  void cycleRepeatMode() {
    final modes = RepeatMode.values;
    final currentIndex = modes.indexOf(state.repeatMode);
    final nextIndex = (currentIndex + 1) % modes.length;
    state = state.copyWith(repeatMode: modes[nextIndex]);
  }

  void setQueue(List<Track> tracks) {
    state = state.copyWith(queue: tracks);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((ref) => PlayerNotifier());

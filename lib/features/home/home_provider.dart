import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../player/player_provider.dart';

class HomeState {
  final List<Track> recentlyPlayed;
  final List<Track> recommended;
  final List<Track> quickPicks;
  final bool isLoading;

  const HomeState({
    this.recentlyPlayed = const [],
    this.recommended = const [],
    this.quickPicks = const [],
    this.isLoading = false,
  });

  HomeState copyWith({
    List<Track>? recentlyPlayed,
    List<Track>? recommended,
    List<Track>? quickPicks,
    bool? isLoading,
  }) {
    return HomeState(
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      recommended: recommended ?? this.recommended,
      quickPicks: quickPicks ?? this.quickPicks,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState(isLoading: true)) {
    _loadData();
  }

  Future<void> _loadData() async {
    // TODO: Fetch from InnerTube once the API client is ready
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(isLoading: false);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadData();
  }
}

final homeScreenProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});

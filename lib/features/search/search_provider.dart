import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../player/player_provider.dart';

class SearchState {
  final String query;
  final List<Track> results;
  final List<String> suggestions;
  final List<String> searchHistory;
  final bool isSearching;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.suggestions = const [],
    this.searchHistory = const [],
    this.isSearching = false,
  });

  SearchState copyWith({
    String? query,
    List<Track>? results,
    List<String>? suggestions,
    List<String>? searchHistory,
    bool? isSearching,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      suggestions: suggestions ?? this.suggestions,
      searchHistory: searchHistory ?? this.searchHistory,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  static const List<Track> _mockTracks = [
    Track(id: '1', title: 'Blinding Lights', artist: 'The Weeknd', album: 'After Hours', duration: Duration(seconds: 200)),
    Track(id: '2', title: 'Shape of You', artist: 'Ed Sheeran', album: '÷', duration: Duration(seconds: 234)),
    Track(id: '3', title: 'Bohemian Rhapsody', artist: 'Queen', album: 'A Night at the Opera', duration: Duration(seconds: 355)),
    Track(id: '4', title: 'Hotel California', artist: 'Eagles', album: 'Hotel California', duration: Duration(seconds: 391)),
    Track(id: '5', title: 'Stairway to Heaven', artist: 'Led Zeppelin', album: 'Led Zeppelin IV', duration: Duration(seconds: 482)),
    Track(id: '6', title: 'Billie Jean', artist: 'Michael Jackson', album: 'Thriller', duration: Duration(seconds: 294)),
    Track(id: '7', title: 'Smells Like Teen Spirit', artist: 'Nirvana', album: 'Nevermind', duration: Duration(seconds: 301)),
    Track(id: '8', title: 'Imagine', artist: 'John Lennon', album: 'Imagine', duration: Duration(seconds: 187)),
    Track(id: '9', title: 'Yesterday', artist: 'The Beatles', album: 'Help!', duration: Duration(seconds: 125)),
    Track(id: '10', title: 'Rolling in the Deep', artist: 'Adele', album: '21', duration: Duration(seconds: 228)),
    Track(id: '11', title: 'Lose Yourself', artist: 'Eminem', album: '8 Mile Soundtrack', duration: Duration(seconds: 326)),
    Track(id: '12', title: 'Take Five', artist: 'Dave Brubeck', album: 'Time Out', duration: Duration(seconds: 324)),
    Track(id: '13', title: 'Watermelon Sugar', artist: 'Harry Styles', album: 'Fine Line', duration: Duration(seconds: 174)),
    Track(id: '14', title: 'Good 4 U', artist: 'Olivia Rodrigo', album: 'SOUR', duration: Duration(seconds: 178)),
    Track(id: '15', title: 'Levitating', artist: 'Dua Lipa', album: 'Future Nostalgia', duration: Duration(seconds: 203)),
    Track(id: '16', title: 'Peaches', artist: 'Justin Bieber', album: 'Justice', duration: Duration(seconds: 198)),
    Track(id: '17', title: 'Montero (Call Me By Your Name)', artist: 'Lil Nas X', album: 'Montero', duration: Duration(seconds: 137)),
    Track(id: '18', title: 'Drivers License', artist: 'Olivia Rodrigo', album: 'SOUR', duration: Duration(seconds: 242)),
    Track(id: '19', title: 'Butter', artist: 'BTS', album: 'Butter', duration: Duration(seconds: 164)),
    Track(id: '20', title: 'Kiss Me More', artist: 'Doja Cat', album: 'Planet Her', duration: Duration(seconds: 208)),
    Track(id: '21', title: 'Sunflower', artist: 'Post Malone', album: 'Hollywood\'s Bleeding', duration: Duration(seconds: 158)),
    Track(id: '22', title: 'Bad Guy', artist: 'Billie Eilish', album: 'When We All Fall Asleep...', duration: Duration(seconds: 194)),
    Track(id: '23', title: 'Old Town Road', artist: 'Lil Nas X', album: '7', duration: Duration(seconds: 113)),
    Track(id: '24', title: 'Circles', artist: 'Post Malone', album: 'Hollywood\'s Bleeding', duration: Duration(seconds: 215)),
    Track(id: '25', title: 'Someone Like You', artist: 'Adele', album: '21', duration: Duration(seconds: 285)),
  ];

  static const List<String> _mockSuggestions = [
    'pop hits',
    'rock classics',
    'hip hop workout',
    'chill vibes',
    'r&b soul',
    'electronic dance',
    'mood booster',
    'late night feels',
    'acoustic covers',
    'live performances',
    'remixes',
    'indie gems',
    'top 2024',
    'throwback',
    'focus music',
  ];

  void setQuery(String query) {
    if (query.isEmpty) {
      state = state.copyWith(
        query: '',
        results: const [],
        suggestions: const [],
        isSearching: false,
      );
      return;
    }

    state = state.copyWith(query: query, isSearching: true);

    final lowerQuery = query.toLowerCase();
    final results = _mockTracks
        .where((t) =>
            t.title.toLowerCase().contains(lowerQuery) ||
            t.artist.toLowerCase().contains(lowerQuery) ||
            (t.album?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();

    final suggestions = _mockSuggestions
        .where((s) => s.toLowerCase().contains(lowerQuery))
        .toList();

    state = state.copyWith(
      results: results,
      suggestions: suggestions,
      isSearching: false,
    );
  }

  void addToHistory(String query) {
    if (query.trim().isEmpty) return;
    final history = List<String>.from(state.searchHistory);
    history.remove(query);
    history.insert(0, query);
    if (history.length > 20) history.removeLast();
    state = state.copyWith(searchHistory: history);
  }

  void removeFromHistory(String query) {
    final history = List<String>.from(state.searchHistory);
    history.remove(query);
    state = state.copyWith(searchHistory: history);
  }

  void clearHistory() {
    state = state.copyWith(searchHistory: const []);
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

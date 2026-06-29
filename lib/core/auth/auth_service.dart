import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, error }

class AuthState {
  final AuthStatus status;
  final String? error;
  final String? accessToken;

  const AuthState({this.status = AuthStatus.unauthenticated, this.error, this.accessToken});

  AuthState copyWith({AuthStatus? status, String? error, String? accessToken}) {
    return AuthState(status: status ?? this.status, error: error ?? this.error, accessToken: accessToken ?? this.accessToken);
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> signIn() async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      // TODO: Implement OAuth device flow
      state = state.copyWith(status: AuthStatus.authenticated);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> signOut() async {
    // TODO: Clear tokens
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

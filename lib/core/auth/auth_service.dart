import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/settings_service.dart';
import 'auth_config.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, error }

class AuthState {
  final AuthStatus status;
  final String? error;
  final String? accessToken;
  final String? userCode;
  final String? verificationUrl;
  final String? deviceCode;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.error,
    this.accessToken,
    this.userCode,
    this.verificationUrl,
    this.deviceCode,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? error,
    String? accessToken,
    String? userCode,
    String? verificationUrl,
    String? deviceCode,
  }) {
    return AuthState(
      status: status ?? this.status,
      error: error ?? this.error,
      accessToken: accessToken ?? this.accessToken,
      userCode: userCode ?? this.userCode,
      verificationUrl: verificationUrl ?? this.verificationUrl,
      deviceCode: deviceCode ?? this.deviceCode,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  Timer? _pollTimer;
  int _pollInterval = 5;
  bool _isPolling = false;

  AuthNotifier(this._ref) : super(const AuthState());

  /// Called by app.dart after settings service is initialized and a stored
  /// token is found. Synchronous — no async construction needed.
  void restoreToken(String token) {
    if (state.status == AuthStatus.unauthenticated) {
      state = AuthState(status: AuthStatus.authenticated, accessToken: token);
    }
  }

  Future<void> signIn() async {
    state = const AuthState(status: AuthStatus.authenticating);

    try {
      final deviceResponse = await http.post(
        Uri.parse(AuthConfig.deviceCodeUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': AuthConfig.clientId,
          'scope': AuthConfig.scope,
        },
      );

      final deviceData = json.decode(deviceResponse.body) as Map<String, dynamic>;

      if (deviceData.containsKey('error')) {
        state = AuthState(
          status: AuthStatus.error,
          error: deviceData['error_description'] as String? ?? deviceData['error'] as String,
        );
        return;
      }

      final deviceCode = deviceData['device_code'] as String;
      final userCode = deviceData['user_code'] as String;
      final verificationUrl = deviceData['verification_url'] as String;
      _pollInterval = deviceData['interval'] as int? ?? 5;

      state = AuthState(
        status: AuthStatus.authenticating,
        userCode: userCode,
        verificationUrl: verificationUrl,
        deviceCode: deviceCode,
      );

      _startPolling();
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.toString());
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(Duration(seconds: _pollInterval), (_) {
      _pollOnce();
    });
  }

  Future<void> _pollOnce() async {
    if (_isPolling) return;
    if (state.status != AuthStatus.authenticating || state.deviceCode == null) return;

    _isPolling = true;
    try {
      final response = await http.post(
        Uri.parse(AuthConfig.tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': AuthConfig.clientId,
          'device_code': state.deviceCode!,
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        },
      );

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data.containsKey('access_token')) {
        _pollTimer?.cancel();
        _pollTimer = null;
        final token = data['access_token'] as String;
        try {
          final settingsService = await _ref.read(settingsServiceProvider.future);
          await settingsService.setAccessToken(token);
        } catch (_) {
          // Persist failure — still mark authenticated in-memory
        }
        state = AuthState(status: AuthStatus.authenticated, accessToken: token);
        return;
      }

      final error = data['error'] as String?;
      switch (error) {
        case 'authorization_pending':
          // Continue polling
          break;
        case 'slow_down':
          _pollTimer?.cancel();
          _pollInterval += 5;
          _startPolling();
          break;
        case 'expired_token':
          _pollTimer?.cancel();
          _pollTimer = null;
          state = const AuthState(
            status: AuthStatus.error,
            error: 'Code expired. Please try again.',
          );
          break;
        case 'access_denied':
          _pollTimer?.cancel();
          _pollTimer = null;
          state = const AuthState(
            status: AuthStatus.error,
            error: 'Sign in cancelled.',
          );
          break;
        default:
          _pollTimer?.cancel();
          _pollTimer = null;
          state = AuthState(
            status: AuthStatus.error,
            error: error ?? 'Unknown error occurred.',
          );
          break;
      }
    } catch (e) {
      _pollTimer?.cancel();
      _pollTimer = null;
      state = AuthState(status: AuthStatus.error, error: e.toString());
    } finally {
      _isPolling = false;
    }
  }

  void cancelSignIn() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _isPolling = false;
    state = const AuthState();
  }

  Future<void> signOut() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    _isPolling = false;
    try {
      final settingsService = await _ref.read(settingsServiceProvider.future);
      await settingsService.setAccessToken(null);
    } catch (_) {
      // Proceed even if persistence fails
    }
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

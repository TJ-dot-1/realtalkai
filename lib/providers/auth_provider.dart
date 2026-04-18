import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';

/// Authentication state
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.email,
    this.displayName,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? displayName,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      error: error ?? this.error,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await AuthService.signInWithEmail(email, password);
      state = AuthState(
        status: AuthStatus.authenticated,
        userId: AuthService.currentUserId,
        email: AuthService.currentEmail,
        displayName: AuthService.currentDisplayName,
      );
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> signUpWithEmail(String email, String password, String name) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await AuthService.signUpWithEmail(email, password, name);
      state = AuthState(
        status: AuthStatus.authenticated,
        userId: AuthService.currentUserId,
        email: AuthService.currentEmail,
        displayName: name,
      );
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await AuthService.signInWithGoogle();
      state = AuthState(
        status: AuthStatus.authenticated,
        userId: AuthService.currentUserId,
        email: AuthService.currentEmail,
        displayName: AuthService.currentDisplayName,
      );
    } catch (e) {
      state = AuthState(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> signOut() async {
    await AuthService.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

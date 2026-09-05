// lib/features/auth/presentation/providers/auth_provider.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

enum AuthStatus {
  initial,
  authenticated,
  guest,
  unauthenticated,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final String? verificationId;
  final int? resendToken;
  final String? phoneNumber;
  final bool isDevOtpFallback;

  const AuthState({
    required this.status,
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.verificationId,
    this.resendToken,
    this.phoneNumber,
    this.isDevOtpFallback = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    bool? isLoading,
    String? errorMessage,
    String? verificationId,
    int? resendToken,
    String? phoneNumber,
    bool? isDevOtpFallback,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isDevOtpFallback: isDevOtpFallback ?? this.isDevOtpFallback,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService)
      : super(AuthState(
          status: _authService.isAuthenticated
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
          user: _authService.currentUser,
        )) {
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    if (_authService.isAuthenticated) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: _authService.currentUser,
      );
    } else {
      final isGuest = await _authService.isGuestUser();
      final persistedPhone = await _authService.getPersistedPhone();

      if (persistedPhone != null && persistedPhone.isNotEmpty) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          phoneNumber: persistedPhone,
        );
      } else if (isGuest) {
        state = state.copyWith(status: AuthStatus.guest);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    }
  }

  Future<bool> sendOtp(String rawPhone, String countryCode) async {
    var cleaned = rawPhone.replaceAll(RegExp(r'\D'), '');

    // Prevent duplicate country code e.g. +91919892600142 or leading 0
    if (countryCode == '+91' && cleaned.startsWith('91') && cleaned.length > 10) {
      cleaned = cleaned.substring(2);
    } else if (cleaned.startsWith('0') && cleaned.length > 10) {
      cleaned = cleaned.substring(1);
    }

    final fullNumber = '$countryCode$cleaned';

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      phoneNumber: fullNumber,
      isDevOtpFallback: false,
    );

    final completer = Completer<bool>();

    await _authService.sendOtp(
      phoneNumber: fullNumber,
      resendToken: state.resendToken,
      onCodeSent: (verificationId, resendToken, isDevFallback) {
        state = state.copyWith(
          isLoading: false,
          verificationId: verificationId,
          resendToken: resendToken,
          isDevOtpFallback: isDevFallback,
        );
        if (!completer.isCompleted) completer.complete(true);
      },
      onError: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error);
        if (!completer.isCompleted) completer.complete(false);
      },
      onAutoVerified: (credential) {
        state = state.copyWith(
          isLoading: false,
          status: AuthStatus.authenticated,
          user: credential.user,
        );
        if (!completer.isCompleted) completer.complete(true);
      },
    );

    return completer.future;
  }

  Future<bool> verifyOtp(String smsCode) async {
    if (state.verificationId == null) {
      state = state.copyWith(errorMessage: 'Verification session expired. Request code again.');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final credential = await _authService.verifyOtp(
        verificationId: state.verificationId!,
        smsCode: smsCode,
        phoneNumber: state.phoneNumber ?? '',
      );

      state = state.copyWith(
        isLoading: false,
        status: AuthStatus.authenticated,
        user: credential?.user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> skipLogin() async {
    await _authService.setGuestUser(true);
    state = state.copyWith(status: AuthStatus.guest);
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

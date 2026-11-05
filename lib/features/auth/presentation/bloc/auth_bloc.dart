import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC (Business Logic Component) untuk Autentikasi
class AuthBloc {
  AuthBloc({required this.loginUseCase}) {
    _eventController.stream.listen(_mapEventToState);
  }

  final LoginUseCase loginUseCase;

  AuthState _state = const AuthInitial();

  final _eventController = StreamController<AuthEvent>();
  final _stateController = StreamController<AuthState>.broadcast();

  /// State saat ini
  AuthState get state => _state;

  /// Stream perubahan state
  Stream<AuthState> get stream => _stateController.stream;

  /// Menambahkan event baru ke BLoC
  void add(AuthEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  void _emit(AuthState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  Future<void> _mapEventToState(AuthEvent event) async {
    switch (event) {
      case LoginSubmitted(:final username, :final password):
        _emit(const AuthLoading());
        try {
          final user = await loginUseCase.execute(
            username: username,
            password: password,
          );
          _emit(AuthSuccess(user));
        } catch (e) {
          final errorMsg = e is ArgumentError
              ? e.message.toString()
              : e.toString().replaceFirst('Exception: ', '');
          _emit(AuthFailure(errorMsg));
        }
        break;

      case LogoutRequested():
        _emit(const AuthInitial());
        break;

      case AuthCheckRequested():
        _emit(const AuthInitial());
        break;
    }
  }

  /// Menutup stream controller saat BLoC tidak lagi digunakan
  void close() {
    _eventController.close();
    _stateController.close();
  }
}

/// Widget Builder untuk mereaktifkan UI berdasarkan state [AuthBloc]
class AuthBlocBuilder extends StatelessWidget {
  const AuthBlocBuilder({
    super.key,
    required this.bloc,
    required this.builder,
  });

  final AuthBloc bloc;
  final Widget Function(BuildContext context, AuthState state) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      initialData: bloc.state,
      stream: bloc.stream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const AuthInitial();
        return builder(context, state);
      },
    );
  }
}

/// InheritedWidget untuk menyediakan instance [AuthBloc] ke widget tree di bawahnya
class AuthBlocProvider extends InheritedWidget {
  const AuthBlocProvider({
    super.key,
    required this.bloc,
    required super.child,
  });

  final AuthBloc bloc;

  static AuthBloc of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AuthBlocProvider>();
    assert(provider != null, 'Tidak ditemukan AuthBlocProvider dalam context');
    return provider!.bloc;
  }

  @override
  bool updateShouldNotify(AuthBlocProvider oldWidget) => bloc != oldWidget.bloc;
}

/// Alias typedef untuk kemudahan pemanggilan
typedef AppBlocBuilder = AuthBlocBuilder;
typedef AppBlocProvider = AuthBlocProvider;



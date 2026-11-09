import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/datasources/navigation_local_data_source.dart';
import '../../domain/entities/nav_item.dart';
import '../../domain/usecases/change_tab_usecase.dart';
import '../../domain/usecases/get_navigation_items_usecase.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

/// BLoC untuk mengontrol alur pergantian tab pada Navigation Bar
class NavigationBloc {
  NavigationBloc({
    required this.getItemsUseCase,
    required this.changeTabUseCase,
    String defaultRole = 'warehouse',
    List<NavItem>? initialItems,
  })  : _state = NavigationLoaded(
          currentIndex: 0,
          items: initialItems ?? NavigationLocalDataSourceImpl.defaultWarehouseItems,
          role: defaultRole,
        ) {
    _eventSubscription = _eventController.stream.listen(_mapEventToState);
  }

  final GetNavigationItemsUseCase getItemsUseCase;
  final ChangeTabUseCase changeTabUseCase;

  NavigationState _state;
  late final StreamSubscription<NavigationEvent> _eventSubscription;

  final _eventController = StreamController<NavigationEvent>();
  final _stateController = StreamController<NavigationState>.broadcast();

  NavigationState get state => _state;
  Stream<NavigationState> get stream => _stateController.stream;

  void add(NavigationEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  void _emit(NavigationState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  Future<void> _mapEventToState(NavigationEvent event) async {
    switch (event) {
      case LoadNavigationItems(:final role):
        _emit(const NavigationLoading());
        try {
          final items = await getItemsUseCase.execute(role: role);
          final savedTab = await changeTabUseCase.repository.getSavedTab();
          final validIndex = (savedTab >= 0 && savedTab < items.length) ? savedTab : 0;

          _emit(NavigationLoaded(
            currentIndex: validIndex,
            items: items,
            role: role,
          ));
        } catch (e) {
          _emit(NavigationError('Gagal memuat navigasi: ${e.toString()}'));
        }
        break;

      case ChangeNavigationTab(:final newIndex):
        final currentState = _state;
        if (currentState is NavigationLoaded) {
          if (currentState.currentIndex == newIndex) return;

          if (newIndex >= 0 && newIndex < currentState.items.length) {
            _emit(currentState.copyWith(currentIndex: newIndex));
            unawaited(changeTabUseCase.execute(
              newIndex,
              maxIndex: currentState.items.length - 1,
            ));
          }
        }
        break;

      case UpdateBadgeCount(:final index, :final count):
        final currentState = _state;
        if (currentState is NavigationLoaded) {
          if (index >= 0 && index < currentState.items.length) {
            final updatedItems = List.of(currentState.items);
            updatedItems[index] = updatedItems[index].copyWith(badgeCount: count);
            _emit(currentState.copyWith(items: updatedItems));
          }
        }
        break;
    }
  }

  void close() {
    _eventSubscription.cancel();
    _eventController.close();
    _stateController.close();
  }
}

/// Widget builder reaktif untuk NavigationBloc
class NavigationBlocBuilder extends StatelessWidget {
  const NavigationBlocBuilder({
    super.key,
    required this.bloc,
    required this.builder,
  });

  final NavigationBloc bloc;
  final Widget Function(BuildContext context, NavigationState state) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NavigationState>(
      initialData: bloc.state,
      stream: bloc.stream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const NavigationLoading();
        return builder(context, state);
      },
    );
  }
}

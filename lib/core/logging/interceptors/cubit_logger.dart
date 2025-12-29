import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:centabit/core/logging/app_logger.dart';

/// BlocObserver that automatically logs all cubit lifecycle events
///
/// This observer logs:
/// - Cubit creation
/// - State changes (verbose level)
/// - Errors (with stack traces)
/// - Cubit disposal
class CubitLogger extends BlocObserver {
  final _logger = AppLogger.instance;

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _logger.debug('[${bloc.runtimeType}] Created');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    _logger.verbose(
      '[${bloc.runtimeType}] ${change.currentState.runtimeType} → ${change.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _logger.error(
      '[${bloc.runtimeType}] Error',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    _logger.debug('[${bloc.runtimeType}] Closed');
  }
}

import 'dart:async';

class RetryManager {
  static final RetryManager _instance = RetryManager._internal();

  // Control de reintentos
  final Map<int, Timer?> _retryTimers = {};

  factory RetryManager() {
    return _instance;
  }

  RetryManager._internal();

  /// Cancela timer de reintento si existe
  void cancelRetryTimer(int puestoId) {
    _retryTimers[puestoId]?.cancel();
    _retryTimers.remove(puestoId);
  }

  /// Programa reintentos con delay configurable
  void scheduleRetry(
    int puestoId,
    Function() onRetry, {
    Duration delay = const Duration(seconds: 30),
  }) {
    cancelRetryTimer(puestoId);
    print(
      '[RETRY] Programando reintento para puesto $puestoId en ${delay.inSeconds}s',
    );
    _retryTimers[puestoId] = Timer(delay, () {
      onRetry();
    });
  }

  /// Limpia un reintento completado
  void clearRetry(int puestoId) {
    _retryTimers.remove(puestoId);
  }

  /// Limpia todos los timers (al cerrar app)
  void disposeAll() {
    print('[SYNC] Limpiando timers de sincronización...');
    for (final timer in _retryTimers.values) {
      timer?.cancel();
    }
    _retryTimers.clear();
  }

  /// Obtiene cantidad de reintentos pendientes
  int get pendingRetries => _retryTimers.length;
}

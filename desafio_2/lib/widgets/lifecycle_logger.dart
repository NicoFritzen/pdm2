import 'package:flutter/material.dart';

/// Loga um passo do ciclo de vida. Formato: `[ItemListScreen] initState`.
///
/// Filtre o console por `[`. Detalhes da sequência: `docs/crud-sqlite.md`.
void logLifecycle(String widgetName, String method) {
  debugPrint('[$widgetName] $method');
}

/// Mixin que loga `initState`, `deactivate`, `activate` e `dispose`.
///
/// `build` e `createState` ficam fora (ver guia). Cada [State] declara
/// [lifecycleName] e chama `super` nos overrides.
mixin LifecycleLogger<T extends StatefulWidget> on State<T> {
  /// Nome impresso entre colchetes.
  String get lifecycleName;

  @override
  void initState() {
    super.initState();
    logLifecycle(lifecycleName, 'initState');
  }

  @override
  void deactivate() {
    logLifecycle(lifecycleName, 'deactivate');
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    logLifecycle(lifecycleName, 'activate');
  }

  @override
  void dispose() {
    logLifecycle(lifecycleName, 'dispose');
    super.dispose();
  }
}

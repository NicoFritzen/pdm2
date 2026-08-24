import 'package:flutter/material.dart';

import 'screens/item_list_screen.dart';

/// Ponto de entrada. [WidgetsFlutterBinding.ensureInitialized] libera
/// os plugins nativos (`sqflite`, `path_provider`) antes do [runApp].
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ItemCrudApp());
}

/// Raiz do app: tema Material 3 e [home] na lista de itens.
class ItemCrudApp extends StatelessWidget {
  const ItemCrudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cadastro de Itens',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const ItemListScreen(),
    );
  }
}

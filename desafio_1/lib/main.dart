import 'package:flutter/material.dart';
import 'screens/product_list_screen.dart';

/// Ponto de entrada do aplicativo.
///
/// [runApp] infla a árvore de widgets a partir da raiz ([SuperApp]).
void main() {
  runApp(const SuperApp());
}

/// Raiz do app (StatelessWidget: não guarda estado próprio).
///
/// O [MaterialApp] é essencial porque:
/// - cria o [Navigator] (pilha de rotas) usado em push/pop;
/// - aplica o tema Material 3;
/// - define a tela inicial ([home]).
class SuperApp extends StatelessWidget {
  const SuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SuperApp',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      // Tela inicial: lista de produtos (StatefulWidget com busca + scroll).
      home: const ProductListScreen(),
    );
  }
}

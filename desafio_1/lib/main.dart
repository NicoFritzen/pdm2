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
/// O [MaterialApp] cria o [Navigator] (pilha de rotas). Nesta branch (raw),
/// a navegação usa [Navigator.pushReplacement], que SUBSTITUI rotas em vez
/// de empilhar — por isso o estado da lista se perde ao “voltar”.
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
      home: const ProductListScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/gallery_carousel_screen.dart';

/// Ponto de entrada do aplicativo da galeria.
void main() {
  runApp(const GalleryApp());
}

/// Raiz do app.
///
/// O [MaterialApp] cria o [Navigator] (pilha de rotas). Sem ele,
/// [Navigator.push] / [Navigator.pop] (empilhar / desempilhar) não funcionam.
class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Galeria Inteligente',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      // Tela inicial: carrossel (PageView + escala + setas).
      home: const GalleryCarouselScreen(),
    );
  }
}

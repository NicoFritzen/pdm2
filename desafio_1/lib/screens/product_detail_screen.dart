import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        centerTitle: true,
        // O Flutter adiciona automaticamente o botão de voltar quando há tela anterior
      ),
      body: const SizedBox.shrink(), // Tela em branco
    );
  }
}
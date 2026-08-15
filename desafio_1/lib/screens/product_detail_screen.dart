import 'package:flutter/material.dart';
import '../models/product.dart';

/// Tela de detalhes do produto (versão com preservação de estado).
///
/// O retorno usa o comportamento padrão do [Navigator] ([Navigator.pop]),
/// mantendo a rota da lista viva na pilha — com isso, o [State] anterior
/// (rolagem e busca) permanece intacto.
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        centerTitle: true,
        // Sem leading customizado: o Flutter adiciona o botão de voltar
        // automaticamente e chama Navigator.pop, preservando a lista.
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12.0),
            Text('ID: ${product.id}'),
            const SizedBox(height: 8.0),
            Text(
              'Preço: R\$ ${product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Ao voltar, a lista permanece na pilha de navegação e o '
              'estado (rolagem e busca) é preservado.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_list_screen.dart';

/// Tela de detalhes do produto (versão com perda de estado).
///
/// Ao voltar, a lista é recriada do zero com [Navigator.pushReplacement],
/// o que descarta o [State] anterior (rolagem e texto da busca).
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  /// Recria a lista sem restaurar o contexto anterior.
  void _voltarSemPreservarEstado(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductListScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _voltarSemPreservarEstado(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.title),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _voltarSemPreservarEstado(context),
          ),
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
                'Ao voltar, a lista será recriada e o estado '
                '(rolagem e busca) será perdido.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

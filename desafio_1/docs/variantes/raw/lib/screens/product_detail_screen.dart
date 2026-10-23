import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_list_screen.dart';

/// Tela de detalhes do produto (versão com perda de estado).
///
/// # Por que não usamos pop?
///
/// A lista chegou aqui via [Navigator.pushReplacement], então NÃO há rota
/// anterior na pilha. Um [Navigator.pop] simples não restauraria a lista
/// com o estado antigo — ela já foi descartada.
///
/// # “Voltar” nesta branch
///
/// [_voltarSemPreservarEstado] faz outro [pushReplacement] criando uma
/// [ProductListScreen] NOVA. É como recomeçar a lista do zero.
///
/// [PopScope] intercepta o botão voltar do sistema (Android) para o mesmo
/// comportamento do ícone do [AppBar].
class ProductDetailScreen extends StatelessWidget {
  /// Produto selecionado (parâmetro da navegação).
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  /// Recria a lista sem restaurar scroll/busca anteriores.
  void _voltarSemPreservarEstado(BuildContext context) {
    // Substitui o detalhe por uma lista nova (estado inicial).
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
      // Impede o pop padrão (não há lista “debaixo” com estado salvo).
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

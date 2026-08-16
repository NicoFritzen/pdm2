import 'package:flutter/material.dart';
import '../models/product.dart';

/// Tela de detalhes do produto (versão com preservação de estado).
///
/// # Desempilhamento (pop)
///
/// Não customizamos o botão voltar. O [AppBar] detecta que há rota anterior
/// na pilha e adiciona o ícone automaticamente. Ao tocar, o Flutter chama
/// [Navigator.pop], que REMOVE só esta tela do topo:
///
/// - Antes do pop: `[Lista, Detalhe]`
/// - Depois do pop: `[Lista]`
///
/// A lista nunca foi destruída → [State] intacto → preservação de estado.
///
/// # Passagem de parâmetros
///
/// O [product] chega pelo construtor (tipado). Alternativa comum seria
/// `ModalRoute.of(context)!.settings.arguments`, mas o construtor é mais
/// claro e seguro em tempo de compilação.
class ProductDetailScreen extends StatelessWidget {
  /// Produto selecionado na lista (parâmetro da navegação).
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        centerTitle: true,
        // Sem [leading] customizado de propósito:
        // um leading que fizesse pushReplacement(ProductListScreen())
        // recriaria a lista e PERDERIA o estado (abordagem da branch raw).
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

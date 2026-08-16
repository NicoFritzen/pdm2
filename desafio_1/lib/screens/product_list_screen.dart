import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

/// Lista de produtos com busca e rolagem.
///
/// # Perda de estado (versão raw — demonstração do problema)
///
/// Esta tela é [StatefulWidget] e guarda:
/// - texto da busca ([TextEditingController]);
/// - posição da rolagem ([ScrollController]);
/// - lista filtrada e flag do botão limpar.
///
/// Ao abrir o detalhe usamos [Navigator.pushReplacement] (SUBSTITUIÇÃO),
/// NÃO [Navigator.push] (empilhamento). A rota da lista sai da pilha e o
/// Flutter chama [dispose] neste [State] → controllers morrem → estado some.
///
/// Ao “voltar”, o detalhe cria uma [ProductListScreen] NOVA. Scroll no topo
/// e busca vazia. Não usamos [ScrollController.jumpTo] para forçar o reset:
/// a perda vem de descartar a rota de verdade.
///
/// A solução (branch `desafio1-solved`) troca isso por push + pop.
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Controla se o ícone "X" da busca aparece.
  bool _hasText = false;

  /// Fonte completa mockada (100 itens).
  final List<Product> _allProducts = List.generate(
    100,
    (index) => Product(
      id: index + 1,
      title: 'Produto ${index + 1}',
      price: (index + 1) * 10.0,
    ),
  );

  /// Resultado atual do filtro (o que a [ListView] exibe).
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = _allProducts;

    // A cada digitação, setState reconstrói a UI com o filtro aplicado.
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _hasText = _searchController.text.isNotEmpty;
        _filteredProducts = _allProducts
            .where((p) => p.title.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    // Na versão raw, dispose RODA ao ir para o detalhe (rota substituída).
    // Na versão solved (push), dispose NÃO rodaria nesse momento.
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('SuperApp'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            // ----- Barra de busca -----
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar produtos...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _hasText
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  border: defaultBorder,
                  enabledBorder: defaultBorder,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(
                      color: Colors.grey.shade600,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            // ----- Lista com scrollbar -----
            Expanded(
              child: _filteredProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum produto encontrado.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : RawScrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thumbColor: Colors.grey.shade400,
                      thickness: 6.0,
                      radius: const Radius.circular(10.0),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _filteredProducts.length,
                        padding: const EdgeInsets.only(left: 16.0, right: 24.0),
                        itemExtent: 48.0,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return InkWell(
                            onTap: () {
                              // SUBSTITUIÇÃO (pushReplacement) — NÃO é empilhamento:
                              // Pilha antes: [ProductListScreen]
                              // Pilha depois: [ProductDetailScreen]
                              //
                              // A lista sai da pilha → dispose → estado perdido.
                              // Passagem de parâmetro: [Product] no construtor.
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                    product: product,
                                  ),
                                ),
                              );
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                product.title,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

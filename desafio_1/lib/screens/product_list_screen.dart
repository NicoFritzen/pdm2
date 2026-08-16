import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

/// Lista de produtos com busca e rolagem.
///
/// # Preservação de estado (versão solved)
///
/// Esta tela é [StatefulWidget] porque guarda estado mutável:
/// - texto da busca ([TextEditingController]);
/// - posição da rolagem ([ScrollController]);
/// - lista filtrada e flag do botão limpar.
///
/// O truque da preservação: ao abrir o detalhe usamos [Navigator.push]
/// (EMPILHAMENTO). A rota desta lista permanece na pilha do [Navigator],
/// então o [State] NÃO passa por [dispose]. Ao voltar com [Navigator.pop]
/// (DESEMPILHAMENTO), busca e scroll continuam exatamente onde estavam.
///
/// # Contraste com a versão "raw" (perda de estado)
///
/// Se usássemos [Navigator.pushReplacement], esta rota seria SUBSTITUÍDA,
/// o [State] morreria no [dispose] e, ao "voltar", uma lista nova nasceria
/// do zero (scroll no topo, busca vazia). Não use [ScrollController.jumpTo]
/// só para "simular" a perda — o problema real é descartar a rota.
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Controllers vivem no State: enquanto a rota estiver na pilha, eles vivem.
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Controla se o ícone "X" da busca aparece.
  bool _hasText = false;

  /// Fonte completa mockada (100 itens) — lista base, nunca filtrada in-place.
  final List<Product> _allProducts = List.generate(
    100,
    (index) => Product(
      id: index + 1,
      title: 'Produto ${index + 1}',
      price: (index + 1) * 10.0,
    ),
  );

  /// Resultado atual do filtro (o que a [ListView] realmente exibe).
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    // No início, a lista filtrada mostra todos os produtos.
    _filteredProducts = _allProducts;

    // Listener: a cada digitação, [setState] reconstrói a UI com o filtro.
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
    // Só roda se a rota for removida da pilha (ex.: pushReplacement).
    // Com push/pop normal, dispose NÃO acontece ao ir ao detalhe.
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
            // O texto digitado fica no TextEditingController (estado preservado
            // enquanto este State existir).
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
            // Expanded ocupa o espaço restante abaixo da busca.
            Expanded(
              child: _filteredProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum produto encontrado.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : RawScrollbar(
                      // Mesmo ScrollController da ListView: thumb acompanha
                      // a posição (também preservada ao voltar do detalhe).
                      controller: _scrollController,
                      thumbVisibility: true,
                      thumbColor: Colors.grey.shade400,
                      thickness: 6.0,
                      radius: const Radius.circular(10.0),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _filteredProducts.length,
                        padding: const EdgeInsets.only(left: 16.0, right: 24.0),
                        // Altura fixa por item → rolagem previsível e leve.
                        itemExtent: 48.0,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return InkWell(
                            onTap: () {
                              // EMPILHAMENTO (push):
                              // Pilha antes: [ProductListScreen]
                              // Pilha depois: [ProductListScreen, ProductDetailScreen]
                              //
                              // Esta rota fica POR BAIXO do detalhe, viva.
                              // Por isso scroll + busca não se perdem.
                              //
                              // Passagem de parâmetro: o objeto [Product]
                              // vai no construtor da próxima tela.
                              Navigator.push(
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

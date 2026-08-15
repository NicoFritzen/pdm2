import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  // 1. Controller dedicado para manipular e resetar a rolagem
  final ScrollController _scrollController = ScrollController();
  bool _hasText = false;

  final List<Product> _allProducts = List.generate(
    100,
    (index) =>
        Product(id: index + 1, title: 'Produto ${index + 1}', price: 0.0),
  );

  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = _allProducts;

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
            // Barra de pesquisa
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

            // Lista com scrollbar azul visível e reset de estado ao voltar
            Expanded(
              child: _filteredProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum produto encontrado.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : // Substitua o bloco do RawScrollbar dentro do Expanded por:
                    RawScrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thumbColor: Colors
                          .grey
                          .shade400, // Tom cinza neutro no lugar do azul
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailScreen(product: product),
                                ),
                              ).then((_) {
                                if (_scrollController.hasClients) {
                                  _scrollController.jumpTo(0.0);
                                }
                              });
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

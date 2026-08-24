import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../models/item.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_card.dart';
import '../widgets/lifecycle_logger.dart';
import 'item_detail_screen.dart';
import 'item_form_screen.dart';

/// Lista de itens (Read). FAB cadastra; toque abre o detalhe.
class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() {
    logLifecycle('ItemListScreen', 'createState');
    return _ItemListScreenState();
  }
}

class _ItemListScreenState extends State<ItemListScreen>
    with LifecycleLogger<ItemListScreen> {
  @override
  String get lifecycleName => 'ItemListScreen';

  /// Repositório (a conexão do banco é singleton).
  final ItemRepository _repository = ItemRepository();

  /// Itens atualmente desenhados. Vazio no primeiro frame.
  List<Item> _items = <Item>[];

  /// `true` enquanto o SELECT não voltou (mostra o spinner).
  bool _loading = true;

  /// Mensagem se o banco falhar (permissão, disco, etc.).
  String? _error;

  @override
  void initState() {
    super.initState();
    // Primeira leitura: a tabela pode estar vazia (estado empty).
    _loadItems();
  }

  /// Carrega a lista. Chamado no [initState] e ao voltar de create/edit/delete.
  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final List<Item> items = await _repository.getAll();
      if (!mounted) {
        // A tela pode ter sido destruída enquanto o await rodava.
        return;
      }
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Não foi possível carregar os itens: $error';
        _loading = false;
      });
    }
  }

  /// Empilha o formulário de cadastro. Se salvou, recarrega a lista.
  Future<void> _openCreateForm() async {
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => const ItemFormScreen(),
      ),
    );
    if (saved == true) {
      await _loadItems();
    }
  }

  /// Abre o detalhe e recarrega a lista ao voltar.
  Future<void> _openDetail(Item item) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ItemDetailScreen(itemId: item.id!),
      ),
    );
    await _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    logLifecycle(lifecycleName, 'build');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus itens'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateForm,
        tooltip: 'Cadastrar item',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Escolhe spinner, erro, vazio ou a [ListView] conforme o estado.
  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return EmptyState(
        message: 'Erro ao carregar',
        subtitle: _error,
        actionLabel: 'Tentar de novo',
        onAction: _loadItems,
      );
    }
    if (_items.isEmpty) {
      return EmptyState(
        message: 'Nenhum item cadastrado',
        subtitle: 'Toque no botão para criar o primeiro.',
        actionLabel: 'Cadastrar item',
        onAction: _openCreateForm,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 88.0),
      itemCount: _items.length,
      itemBuilder: (BuildContext context, int index) {
        final Item item = _items[index];
        return ItemCard(
          item: item,
          onTap: () => _openDetail(item),
        );
      },
    );
  }
}

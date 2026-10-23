import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../models/item.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/item_image.dart';
import '../widgets/lifecycle_logger.dart';
import 'item_form_screen.dart';

/// Detalhe de um item (Read) com ações de editar e excluir.
///
/// Recebe só o [itemId] para recarregar do SQLite após uma edição.
class ItemDetailScreen extends StatefulWidget {
  /// Chave primária do item a consultar.
  final int itemId;

  const ItemDetailScreen({
    super.key,
    required this.itemId,
  });

  @override
  State<ItemDetailScreen> createState() {
    logLifecycle('ItemDetailScreen', 'createState');
    return _ItemDetailScreenState();
  }
}

class _ItemDetailScreenState extends State<ItemDetailScreen>
    with LifecycleLogger<ItemDetailScreen> {
  @override
  String get lifecycleName => 'ItemDetailScreen';

  final ItemRepository _repository = ItemRepository();

  /// Item atual. Nulo enquanto carrega ou se alguém apagou no meio.
  Item? _item;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  /// SELECT por id. Usado no início e depois de voltar do formulário.
  Future<void> _loadItem() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final Item? item = await _repository.getById(widget.itemId);
      if (!mounted) {
        return;
      }
      setState(() {
        _item = item;
        _loading = false;
        if (item == null) {
          _error = 'Item não encontrado. Talvez tenha sido excluído.';
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Não foi possível carregar o item: $error';
        _loading = false;
      });
    }
  }

  /// Empilha o formulário em modo edição. Se salvou, relê o banco.
  Future<void> _openEditForm() async {
    final Item? item = _item;
    if (item == null) {
      return;
    }
    final bool? saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => ItemFormScreen(item: item),
      ),
    );
    if (saved == true) {
      await _loadItem();
    }
  }

  /// Confirma, apaga linha + arquivo, e volta para a lista.
  Future<void> _confirmAndDelete() async {
    final Item? item = _item;
    if (item == null) {
      return;
    }
    final bool confirmed = await showConfirmDeleteDialog(
      context: context,
      itemName: item.name,
    );
    if (!confirmed) {
      return;
    }
    try {
      await _repository.delete(item);
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível excluir: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    logLifecycle(lifecycleName, 'build');

    final Item? item = _item;

    return Scaffold(
      appBar: AppBar(
        title: Text(item?.name ?? 'Detalhe'),
        actions: [
          if (item != null) ...[
            IconButton(
              tooltip: 'Editar',
              onPressed: _openEditForm,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Excluir',
              onPressed: _confirmAndDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ],
      ),
      body: _buildBody(context, item),
    );
  }

  Widget _buildBody(BuildContext context, Item? item) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || item == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(_error ?? 'Item indisponível.'),
        ),
      );
    }

    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ItemImage(imagePath: item.imagePath, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 16.0),
        Text(item.name, style: textTheme.headlineSmall),
        const SizedBox(height: 8.0),
        Chip(
          label: Text(item.category),
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(height: 16.0),
        Text(item.description, style: textTheme.bodyLarge),
      ],
    );
  }
}

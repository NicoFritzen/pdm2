import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../models/item.dart';
import '../widgets/app_text_form_field.dart';
import '../widgets/category_dropdown.dart';
import '../widgets/image_picker_field.dart';
import '../widgets/lifecycle_logger.dart';

/// Formulário de cadastro ([item] nulo) ou edição.
///
/// Controllers nascem em [initState] e devem morrer em [dispose].
class ItemFormScreen extends StatefulWidget {
  /// Item sendo editado. Nulo no cadastro.
  final Item? item;

  const ItemFormScreen({
    super.key,
    this.item,
  });

  @override
  State<ItemFormScreen> createState() {
    logLifecycle('ItemFormScreen', 'createState');
    return _ItemFormScreenState();
  }
}

class _ItemFormScreenState extends State<ItemFormScreen>
    with LifecycleLogger<ItemFormScreen> {
  @override
  String get lifecycleName => 'ItemFormScreen';

  final ItemRepository _repository = ItemRepository();

  /// Chave do [Form]: [FormState.validate] percorre todos os campos.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  /// Categoria do dropdown (`null` até a pessoa escolher no cadastro).
  String? _category;

  /// Caminho da foto (galeria temporária ou arquivo já persistido).
  String? _imagePath;

  /// Erro de imagem (não entra no [Form] porque o picker não é [FormField]).
  String? _imageError;

  /// Trava o botão Salvar enquanto o INSERT/UPDATE roda.
  bool _saving = false;

  /// Atalho: estamos no modo edição?
  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final Item? item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    _category = item?.category;
    _imagePath = item?.imagePath;
  }

  @override
  void dispose() {
    // Controllers são recursos: sem isso o listener fica preso.
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Valida nome: obrigatório, 3 a 80 caracteres (depois do trim).
  String? _validateName(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Informe o nome.';
    }
    if (text.length < 3) {
      return 'O nome precisa ter pelo menos 3 caracteres.';
    }
    if (text.length > 80) {
      return 'O nome pode ter no máximo 80 caracteres.';
    }
    return null;
  }

  /// Valida categoria: uma opção do dropdown é obrigatória.
  String? _validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Escolha uma categoria.';
    }
    return null;
  }

  /// Valida descrição: obrigatória, 10 a 500 caracteres.
  String? _validateDescription(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Informe a descrição.';
    }
    if (text.length < 10) {
      return 'A descrição precisa ter pelo menos 10 caracteres.';
    }
    if (text.length > 500) {
      return 'A descrição pode ter no máximo 500 caracteres.';
    }
    return null;
  }

  /// Imagem obrigatória no cadastro; na edição a já salva vale.
  bool _validateImage() {
    final bool missing = _imagePath == null || _imagePath!.isEmpty;
    setState(() {
      _imageError = missing ? 'Selecione uma imagem.' : null;
    });
    return !missing;
  }

  /// Valida, copia a imagem se for nova, e grava no SQLite.
  Future<void> _submit() async {
    final bool formOk = _formKey.currentState?.validate() ?? false;
    final bool imageOk = _validateImage();
    if (!formOk || !imageOk) {
      return;
    }
    setState(() => _saving = true);
    try {
      String persistedImagePath = _imagePath!;

      // Path da galeria é temporário. Copia para a pasta privada do app.
      final String? originalPath = widget.item?.imagePath;
      final bool imageChanged = persistedImagePath != originalPath;
      if (imageChanged) {
        persistedImagePath = await _repository.copyImageToAppDir(
          persistedImagePath,
        );
        if (originalPath != null) {
          await _repository.deleteImageFile(originalPath);
        }
      }

      if (_isEditing) {
        final Item updated = widget.item!.copyWith(
          name: _nameController.text.trim(),
          category: _category,
          description: _descriptionController.text.trim(),
          imagePath: persistedImagePath,
        );
        await _repository.update(updated);
      } else {
        final Item created = Item(
          name: _nameController.text.trim(),
          category: _category!,
          description: _descriptionController.text.trim(),
          imagePath: persistedImagePath,
        );
        await _repository.insert(created);
      }

      if (!mounted) {
        return;
      }
      // `true` avisa a tela anterior para recarregar a lista/detalhe.
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível salvar: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    logLifecycle(lifecycleName, 'build');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar item' : 'Novo item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            AppTextFormField(
              label: 'Nome',
              hint: 'Ex.: Caderno universitário',
              controller: _nameController,
              validator: _validateName,
              maxLength: 80,
            ),
            const SizedBox(height: 16.0),
            CategoryDropdown(
              value: _category,
              onChanged: (String? value) {
                setState(() => _category = value);
              },
              validator: _validateCategory,
            ),
            const SizedBox(height: 16.0),
            AppTextFormField(
              label: 'Descrição',
              hint: 'Detalhes que ajudem a identificar o item',
              controller: _descriptionController,
              validator: _validateDescription,
              maxLines: 4,
              maxLength: 500,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 16.0),
            ImagePickerField(
              initialPath: _imagePath,
              errorText: _imageError,
              onChanged: (String? path) {
                setState(() {
                  _imagePath = path;
                  _imageError = null;
                });
              },
            ),
            const SizedBox(height: 24.0),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Salvando...' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

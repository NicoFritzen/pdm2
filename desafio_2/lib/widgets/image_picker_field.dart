import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'item_image.dart';
import 'lifecycle_logger.dart';

/// Campo de imagem (galeria + preview). Guarda o path em [_path].
class ImagePickerField extends StatefulWidget {
  /// Caminho já persistido (edição) ou nulo (cadastro).
  final String? initialPath;

  /// Avisa a [ItemFormScreen] sempre que a pessoa escolhe outra foto.
  final ValueChanged<String?> onChanged;

  /// Mensagem de erro vinda da tela (imagem obrigatória no cadastro).
  final String? errorText;

  const ImagePickerField({
    super.key,
    this.initialPath,
    required this.onChanged,
    this.errorText,
  });

  @override
  State<ImagePickerField> createState() {
    logLifecycle('ImagePickerField', 'createState');
    return _ImagePickerFieldState();
  }
}

class _ImagePickerFieldState extends State<ImagePickerField>
    with LifecycleLogger<ImagePickerField> {
  @override
  String get lifecycleName => 'ImagePickerField';

  /// Caminho exibido agora (galeria temporária ou arquivo já salvo).
  late String? _path;

  /// Cliente do plugin. Não precisa de dispose.
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Parte do estado inicial vem do widget (editar já tem foto).
    _path = widget.initialPath;
  }

  /// Abre a galeria do aparelho.
  Future<void> _pickFromGallery() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) {
      // Usuário cancelou: mantém a foto anterior.
      return;
    }
    setState(() => _path = file.path);
    widget.onChanged(_path);
  }

  @override
  Widget build(BuildContext context) {
    logLifecycle(lifecycleName, 'build');

    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool hasImage = _path != null && _path!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Imagem',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8.0),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Material(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.0),
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? ItemImage(imagePath: _path!, fit: BoxFit.cover)
                : Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 48.0,
                      color: colors.outline,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8.0),
        OutlinedButton.icon(
          onPressed: _pickFromGallery,
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(hasImage ? 'Trocar imagem' : 'Escolher da galeria'),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8.0),
          Text(
            widget.errorText!,
            style: TextStyle(
              color: colors.error,
              fontSize: 12.0,
            ),
          ),
        ],
      ],
    );
  }
}

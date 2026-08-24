import 'dart:io';

import 'package:flutter/material.dart';

/// Miniatura ou foto lida de [imagePath]. Fallback se o arquivo sumir.
class ItemImage extends StatelessWidget {
  /// Caminho absoluto copiado pelo [ItemRepository.copyImageToAppDir].
  final String imagePath;

  /// Largura da caixa. Nula = ocupar o máximo que o pai permitir.
  final double? width;

  /// Altura da caixa. Nula = ocupar o máximo que o pai permitir.
  final double? height;

  /// Como a foto se encaixa na caixa (`cover` nas miniaturas).
  final BoxFit fit;

  /// Cantos arredondados (cards vs. detalhe em tela cheia).
  final BorderRadius? borderRadius;

  const ItemImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.file(
      File(imagePath),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        // Arquivo apagado na mão, permissão, caminho velho, etc.
        return _ImageFallback(width: width, height: height);
      },
    );

    if (borderRadius == null) {
      return image;
    }

    return ClipRRect(
      borderRadius: borderRadius!,
      child: image,
    );
  }
}

/// Placeholder visual quando [Image.file] falha.
class _ImageFallback extends StatelessWidget {
  /// Mesmas dimensões da foto que falhou, para o layout não pular.
  final double? width;
  final double? height;

  const _ImageFallback({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

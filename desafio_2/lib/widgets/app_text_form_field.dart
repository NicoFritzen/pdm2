import 'package:flutter/material.dart';

/// [TextFormField] com borda, label e validador padronizados.
class AppTextFormField extends StatelessWidget {
  /// Texto acima do campo (ex.: `Nome`).
  final String label;

  /// Dica cinza dentro do campo vazio.
  final String? hint;

  /// Quem guarda o que a pessoa digitou (ciclo: initState → dispose).
  final TextEditingController controller;

  /// Regras de validação; devolve a mensagem de erro ou `null`.
  final String? Function(String?)? validator;

  /// Teclado sugerido (texto, multilinha, etc.).
  final TextInputType? keyboardType;

  /// Quantidade máxima de linhas visíveis (descrição usa 4).
  final int maxLines;

  /// Teto de caracteres; o validador reforça o mesmo número.
  final int? maxLength;

  /// Ação do botão Enter no teclado (próximo campo vs. pronto).
  final TextInputAction textInputAction;

  const AppTextFormField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

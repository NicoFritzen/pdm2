import 'package:flutter/material.dart';

/// Diálogo de confirmação antes de excluir.
class ConfirmDeleteDialog extends StatelessWidget {
  /// Nome do item, só para a pessoa reconhecer o que vai apagar.
  final String itemName;

  const ConfirmDeleteDialog({
    super.key,
    required this.itemName,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Excluir item'),
      content: Text(
        'Tem certeza que deseja excluir "$itemName"? '
        'Essa ação não pode ser desfeita.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Excluir'),
        ),
      ],
    );
  }
}

/// Abre o diálogo e devolve `true` só se a pessoa confirmar.
Future<bool> showConfirmDeleteDialog({
  required BuildContext context,
  required String itemName,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return ConfirmDeleteDialog(itemName: itemName);
    },
  );
  return confirmed ?? false;
}

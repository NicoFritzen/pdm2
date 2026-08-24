import 'package:flutter/material.dart';

/// Placeholder da lista vazia (mensagem + botão opcional).
class EmptyState extends StatelessWidget {
  /// Frase principal (ex.: `Nenhum item cadastrado`).
  final String message;

  /// Texto de apoio, um pouco mais discreto.
  final String? subtitle;

  /// Rótulo do botão opcional.
  final String? actionLabel;

  /// Ação do botão (em geral: ir para o cadastro).
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.message,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 72.0,
              color: colors.outline,
            ),
            const SizedBox(height: 16.0),
            Text(
              message,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8.0),
              Text(
                subtitle!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24.0),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

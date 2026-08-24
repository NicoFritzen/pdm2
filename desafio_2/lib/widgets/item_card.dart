import 'package:flutter/material.dart';

import '../models/item.dart';
import 'item_image.dart';

/// Card da lista: miniatura, nome e categoria.
class ItemCard extends StatelessWidget {
  /// Item a desenhar (nome, categoria e miniatura).
  final Item item;

  /// Abre o detalhe. A navegação fica na tela, não neste widget.
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ItemImage(
                imagePath: item.imagePath,
                width: 72.0,
                height: 72.0,
                borderRadius: BorderRadius.circular(12.0),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      item.category,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

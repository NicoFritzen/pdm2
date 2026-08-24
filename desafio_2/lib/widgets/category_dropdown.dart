import 'package:flutter/material.dart';

import '../data/categories.dart';

/// Dropdown de categoria ligado ao [Form].
class CategoryDropdown extends StatelessWidget {
  /// Categoria atual (`null` = nada escolhido ainda).
  final String? value;

  /// Atualiza o estado da tela quando a pessoa muda a opção.
  final ValueChanged<String?> onChanged;

  /// Garante que uma opção foi escolhida.
  final String? Function(String?)? validator;

  const CategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      // Flutter 3.33+ deprecou `value` neste FormField. `initialValue`
      // define a opção inicial (cadastro = null, edição = categoria
      // já salva). Depois disso o próprio FormField guarda a escolha.
      initialValue: value,
      validator: validator,
      decoration: const InputDecoration(
        labelText: 'Categoria',
        border: OutlineInputBorder(),
      ),
      items: itemCategories
          .map(
            (String category) => DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

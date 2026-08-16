/// Modelo imutável de um produto da lista.
///
/// Separar dados em uma classe facilita:
/// - tipagem ao filtrar e ao passar parâmetros na navegação;
/// - evolução futura (ex.: adicionar imagem ou descrição).
class Product {
  final int id;
  final String title;
  final double price;

  const Product({
    required this.id,
    required this.title,
    required this.price,
  });
}

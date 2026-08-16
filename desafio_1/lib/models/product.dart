/// Modelo imutável de um produto da lista.
///
/// Separar dados em uma classe facilita tipagem no filtro e na passagem
/// de parâmetros para a tela de detalhe.
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

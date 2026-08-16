/// Modelo de uma imagem da galeria.
///
/// [imageUrl] neste projeto é uma URL HTTP (web).
///
/// # Como seria com assets (arquivos locais)
///
/// 1. Coloque as fotos em `assets/images/` (ex.: `floresta.jpg`).
/// 2. Declare no `pubspec.yaml`:
///    ```yaml
///    flutter:
///      assets:
///        - assets/images/
///    ```
/// 3. Guarde o caminho no campo, ex.: `assets/images/floresta.jpg`.
/// 4. Na UI, troque [Image.network] por [Image.asset] com o mesmo caminho.
///
/// Assets não precisam de internet; URLs precisam de permissão de rede.
class GalleryImage {
  final int id;
  final String title;
  final String description;
  final String author;
  final String category;

  /// URL remota (este app) ou caminho de asset (alternativa documentada).
  final String imageUrl;

  const GalleryImage({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.category,
    required this.imageUrl,
  });
}

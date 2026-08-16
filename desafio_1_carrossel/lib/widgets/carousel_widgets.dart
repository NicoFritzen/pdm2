import 'package:flutter/material.dart';
import '../models/gallery_image.dart';
import '../screens/image_detail_screen.dart';

/// Indicadores (bolinhas) do carrossel.
///
/// Reforçam visualmente qual imagem está ativa, junto com o texto
/// "Imagem X de Y" e a escala maior do card central.
class CarouselIndicators extends StatelessWidget {
  final int count;
  final int currentIndex;

  const CarouselIndicators({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          // Bolinha ativa mais larga = feedback claro do índice atual.
          width: isActive ? 18.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(8.0),
          ),
        );
      }),
    );
  }
}

/// Seta de navegação do carrossel (esquerda ou direita).
///
/// Posicionada pelo [Stack] da tela pai na altura média, nos cantos.
/// A visibilidade (mostrar/ocultar) é decidida na [GalleryCarouselScreen]
/// conforme o [_currentIndex] (primeira / última).
class CarouselNavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const CarouselNavArrow({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        iconSize: 28.0,
      ),
    );
  }
}

/// Card de uma página do carrossel: imagem + toque para abrir o detalhe.
///
/// # Escala
///
/// [scale] vem de [_scaleForIndex] na tela pai. [Transform.scale] deixa a
/// página central maior que as laterais.
///
/// # Empilhamento (push) + passagem de parâmetros
///
/// O [InkWell] chama [Navigator.push] com [ImageDetailScreen(image: image)],
/// empilhando o detalhe sem destruir o carrossel (estado preservado ao voltar).
///
/// # Imagem da web vs assets
///
/// Usamos [Image.network]. Para assets locais:
/// 1) declare no `pubspec.yaml`; 2) use caminho em [GalleryImage.imageUrl];
/// 3) troque por `Image.asset(image.imageUrl, fit: BoxFit.cover)`.
class CarouselPage extends StatelessWidget {
  final GalleryImage image;

  /// Escala visual: 1.0 no centro, menor nas laterais.
  final double scale;

  const CarouselPage({
    super.key,
    required this.image,
    this.scale = 1.0,
  });

  static const BorderRadius _radius = BorderRadius.all(Radius.circular(16.0));

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      // Alteração de escala da imagem principal / laterais.
      scale: scale,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Material(
          // Fundo preto evita "cantinhos" cinzas no anti-alias do canto.
          color: Colors.black,
          elevation: 6,
          shadowColor: Colors.black54,
          borderRadius: _radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              // EMPILHAMENTO: carrossel fica na pilha; detalhe sobe por cima.
              // Parâmetro: objeto GalleryImage inteiro no construtor.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageDetailScreen(image: image),
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  // Alternativa com assets: Image.asset(image.imageUrl, ...)
                  image.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.medium,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    }
                    return const ColoredBox(
                      color: Colors.black,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white70,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const ColoredBox(
                      color: Colors.black87,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: Colors.white54,
                        ),
                      ),
                    );
                  },
                ),
                // Gradiente + título sobre a foto (legenda do card).
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          image.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          image.category,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

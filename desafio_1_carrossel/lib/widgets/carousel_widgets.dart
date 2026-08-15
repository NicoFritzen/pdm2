import 'package:flutter/material.dart';
import '../models/gallery_image.dart';
import '../screens/image_detail_screen.dart';

/// Indicadores (bolinhas) do carrossel.
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

/// Card de uma página do carrossel: imagem + toque para abrir o detalhe.
class CarouselPage extends StatelessWidget {
  final GalleryImage image;

  const CarouselPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageDetailScreen(image: image),
              ),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 12.0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    image.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) {
                        return child;
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return ColoredBox(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined, size: 48),
                        ),
                      );
                    },
                  ),
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
      ),
    );
  }
}

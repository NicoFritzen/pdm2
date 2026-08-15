import 'package:flutter/material.dart';
import '../data/gallery_data.dart';
import '../widgets/carousel_widgets.dart';

/// Tela principal: carrossel de imagens com indicador de posição.
///
/// O estado local [_currentIndex] guarda qual página está visível.
/// Isso é gerenciamento básico de estado com [setState].
class GalleryCarouselScreen extends StatefulWidget {
  const GalleryCarouselScreen({super.key});

  @override
  State<GalleryCarouselScreen> createState() => _GalleryCarouselScreenState();
}

class _GalleryCarouselScreenState extends State<GalleryCarouselScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = galleryImages.length;
    final current = galleryImages[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeria Inteligente'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8.0),
            Text(
              'Imagem ${_currentIndex + 1} de $total',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4.0),
            Text(
              current.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: total,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return CarouselPage(image: galleryImages[index]);
                },
              ),
            ),
            const SizedBox(height: 16.0),
            CarouselIndicators(
              count: total,
              currentIndex: _currentIndex,
            ),
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Deslize para navegar. Toque na imagem para ver os detalhes.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}

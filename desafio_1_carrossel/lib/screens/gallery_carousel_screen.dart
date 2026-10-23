import 'package:flutter/material.dart';
import '../data/gallery_data.dart';
import '../widgets/carousel_widgets.dart';

/// Tela principal: carrossel de imagens com indicador de posição.
///
/// # Estado básico ([setState] + [_currentIndex])
///
/// [_currentIndex] guarda qual página está ativa. Sempre que o usuário
/// termina um swipe (`onPageChanged`) ou as setas mudam a página, chamamos
/// [setState] para redesenhar:
/// - texto "Imagem X de Y";
/// - título da imagem atual;
/// - bolinhas;
/// - visibilidade das setas (primeira/última).
///
/// # Escala da imagem principal
///
/// [_scaleForIndex] usa a posição contínua do [PageController.page].
/// Quanto mais perto do centro, maior a escala (até 1.0). Laterais ~0.86.
/// [AnimatedBuilder] escuta o controller durante o gesto para animar suave.
///
/// # Setas
///
/// Ficam no [Stack], na altura média, nos cantos. Esquerda some no índice 0;
/// direita some no último. Chamam [previousPage] / [nextPage].
///
/// # Preservação de estado ao abrir o detalhe
///
/// O toque no card (em [CarouselPage]) faz [Navigator.push] (empilha).
/// Esta tela permanece na pilha → ao [pop], o índice do carrossel continua.
class GalleryCarouselScreen extends StatefulWidget {
  const GalleryCarouselScreen({super.key});

  @override
  State<GalleryCarouselScreen> createState() => _GalleryCarouselScreenState();
}

class _GalleryCarouselScreenState extends State<GalleryCarouselScreen> {
  late final PageController _pageController;

  /// Índice da página atualmente “ativa” (após o snap do PageView).
  int _currentIndex = 0;

  static const Duration _pageAnimationDuration = Duration(milliseconds: 320);
  static const Curve _pageAnimationCurve = Curves.easeOutCubic;

  /// Calcula a escala da página [index] com base na posição do carrossel.
  ///
  /// - Distância 0 (central) → escala 1.0 (maior).
  /// - Distância 1 (vizinha) → escala ~0.86 (menor).
  ///
  /// Usamos `page` (double) e não só [_currentIndex], para a escala mudar
  /// *durante* o swipe, não só no final.
  double _scaleForIndex(int index) {
    if (!_pageController.hasClients ||
        !_pageController.position.haveDimensions) {
      // Antes do primeiro layout: fallback discreto.
      return index == _currentIndex ? 1.0 : 0.86;
    }

    final page = _pageController.page ?? _currentIndex.toDouble();
    final distance = (page - index).abs();
    return (1.0 - (distance * 0.14)).clamp(0.86, 1.0);
  }

  /// Seta esquerda → página anterior (com animação).
  Future<void> _goToPrevious() async {
    if (_currentIndex <= 0) {
      return;
    }
    await _pageController.previousPage(
      duration: _pageAnimationDuration,
      curve: _pageAnimationCurve,
    );
  }

  /// Seta direita → próxima página (com animação).
  Future<void> _goToNext() async {
    if (_currentIndex >= galleryImages.length - 1) {
      return;
    }
    await _pageController.nextPage(
      duration: _pageAnimationDuration,
      curve: _pageAnimationCurve,
    );
  }

  @override
  void initState() {
    super.initState();
    // viewportFraction < 1 mostra pedaços das páginas vizinhas (efeito carrossel).
    _pageController = PageController(viewportFraction: 0.78);
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

    // Regras das setas: não mostrar esquerda na primeira, nem direita na última.
    final showLeftArrow = _currentIndex > 0;
    final showRightArrow = _currentIndex < total - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeria Inteligente'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8.0),
            // Identifica qual imagem está sendo exibida (requisito do PDF).
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
              // Stack: PageView embaixo + setas por cima (cantos, meio da altura).
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: total,
                    onPageChanged: (index) {
                      // setState do currentIndex: atualiza contador, bolinhas e setas.
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      // AnimatedBuilder por página: redesenha a escala a cada
                      // frame do swipe, sem recriar o PageView inteiro.
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          return CarouselPage(
                            image: galleryImages[index],
                            scale: _scaleForIndex(index),
                          );
                        },
                      );
                    },
                  ),
                  // ----- Setas condicionais -----
                  if (showLeftArrow)
                    Positioned(
                      left: 4.0,
                      child: CarouselNavArrow(
                        icon: Icons.chevron_left,
                        tooltip: 'Imagem anterior',
                        onPressed: _goToPrevious,
                      ),
                    ),
                  if (showRightArrow)
                    Positioned(
                      right: 4.0,
                      child: CarouselNavArrow(
                        icon: Icons.chevron_right,
                        tooltip: 'Próxima imagem',
                        onPressed: _goToNext,
                      ),
                    ),
                ],
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
                'Deslize ou use as setas. Toque na imagem para ver os detalhes.',
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

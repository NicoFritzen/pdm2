import 'package:flutter/material.dart';
import '../models/gallery_image.dart';

/// Segunda tela: recebe a imagem selecionada por parâmetro no construtor.
///
/// # Passagem de parâmetros
///
/// [image] veio do [Navigator.push] feito no card do carrossel:
/// `ImageDetailScreen(image: image)`. Todo o objeto [GalleryImage] chega
/// tipado (não precisamos buscar de novo na lista).
///
/// # Desempilhamento (pop)
///
/// O [AppBar] adiciona o voltar automaticamente e chama [Navigator.pop].
/// A rota do carrossel, que estava por baixo na pilha, volta a aparecer
/// com o mesmo [_currentIndex] (preservação de estado da tela anterior).
///
/// # Imagem da web vs assets
///
/// Aqui usamos [Image.network]. Com assets, seria:
/// `Image.asset(image.imageUrl, fit: BoxFit.cover)` após declarar no pubspec.
class ImageDetailScreen extends StatelessWidget {
  final GalleryImage image;

  const ImageDetailScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(image.title),
        centerTitle: true,
        // Voltar padrão = Navigator.pop (desempilha esta rota).
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 3 / 2,
                child: Material(
                  // Fundo preto evita cantinhos cinzas no canto arredondado.
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16.0),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    // Troque por Image.asset(image.imageUrl) se usar assets.
                    image.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
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
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                image.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  Chip(
                    avatar: const Icon(Icons.category_outlined, size: 18),
                    label: Text(image.category),
                  ),
                  Chip(
                    avatar: const Icon(Icons.person_outline, size: 18),
                    label: Text(image.author),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                'Sobre a imagem',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8.0),
              Text(
                image.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 24.0),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.tag),
                title: const Text('Identificador'),
                subtitle: Text('#${image.id}'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.link),
                title: const Text('Origem da imagem'),
                subtitle: Text(
                  image.imageUrl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

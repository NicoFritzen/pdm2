import 'package:flutter/material.dart';
import '../models/gallery_image.dart';

/// Segunda tela: recebe a imagem selecionada por parâmetro no construtor.
class ImageDetailScreen extends StatelessWidget {
  final GalleryImage image;

  const ImageDetailScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(image.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: Image.network(
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

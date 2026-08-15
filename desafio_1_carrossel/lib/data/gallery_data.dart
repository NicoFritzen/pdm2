import '../models/gallery_image.dart';

/// Coleção mockada da galeria.
///
/// As URLs apontam para [picsum.photos](https://picsum.photos), com IDs
/// fixos para que a mesma foto apareça sempre (útil em demonstrações).
const List<GalleryImage> galleryImages = [
  GalleryImage(
    id: 1,
    title: 'Floresta ao amanhecer',
    description:
        'Luz suave atravessando as árvores no início do dia. '
        'Um clássico da fotografia de paisagem natural.',
    author: 'Ana Souza',
    category: 'Natureza',
    imageUrl: 'https://picsum.photos/id/1015/1200/800',
  ),
  GalleryImage(
    id: 2,
    title: 'Cidade sob a chuva',
    description:
        'Reflexos no asfalto molhado e luzes urbanas. '
        'A atmosfera noturna destaca o contraste das cores.',
    author: 'Bruno Lima',
    category: 'Urbano',
    imageUrl: 'https://picsum.photos/id/1018/1200/800',
  ),
  GalleryImage(
    id: 3,
    title: 'Montanhas nevadas',
    description:
        'Picos cobertos de neve sob céu limpo. '
        'Ideal para estudar composição em camadas.',
    author: 'Carla Mendes',
    category: 'Paisagem',
    imageUrl: 'https://picsum.photos/id/1036/1200/800',
  ),
  GalleryImage(
    id: 4,
    title: 'Café e leitura',
    description:
        'Cena íntima de mesa com livro e xícara. '
        'Bom exemplo de fotografia de still life.',
    author: 'Diego Rocha',
    category: 'Lifestyle',
    imageUrl: 'https://picsum.photos/id/1060/1200/800',
  ),
  GalleryImage(
    id: 5,
    title: 'Ondas no entardecer',
    description:
        'Mar em movimento com tons quentes do pôr do sol. '
        'Explora velocidade do obturador e textura da água.',
    author: 'Elena Prado',
    category: 'Natureza',
    imageUrl: 'https://picsum.photos/id/1016/1200/800',
  ),
  GalleryImage(
    id: 6,
    title: 'Arquitetura moderna',
    description:
        'Linhas geométricas e concreto aparente. '
        'Fotografia arquitetônica com ênfase em perspectiva.',
    author: 'Felipe Nunes',
    category: 'Arquitetura',
    imageUrl: 'https://picsum.photos/id/1019/1200/800',
  ),
  GalleryImage(
    id: 7,
    title: 'Trilha na serra',
    description:
        'Caminho entre vegetação densa e névoa leve. '
        'Convite à exploração e ao silêncio da montanha.',
    author: 'Gabriela Torres',
    category: 'Aventura',
    imageUrl: 'https://picsum.photos/id/1043/1200/800',
  ),
  GalleryImage(
    id: 8,
    title: 'Retrato em luz natural',
    description:
        'Pessoa fotografada perto de uma janela. '
        'Estudo de luz suave e profundidade de campo.',
    author: 'Hugo Martins',
    category: 'Retrato',
    imageUrl: 'https://picsum.photos/id/64/1200/800',
  ),
];

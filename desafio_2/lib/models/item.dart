/// Um item cadastrado. [id] nulo = ainda não gravado no SQLite.
class Item {
  final int? id;
  final String name;
  final String category;
  final String description;

  /// Path absoluto da cópia em `{documentos}/item_images/`.
  /// No SQLite isso vira a coluna `image_path` (`TEXT`), não os bytes da foto.
  final String imagePath;

  const Item({
    this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imagePath,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      imagePath: map['image_path'] as String,
    );
  }

  /// Chaves = colunas SQL. `image_path` é o **caminho** (String), não o JPEG.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'description': description,
      'image_path': imagePath,
    };
  }

  Item copyWith({
    int? id,
    String? name,
    String? category,
    String? description,
    String? imagePath,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

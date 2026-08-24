import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/item.dart';
import 'app_database.dart';

/// CRUD no SQLite e cópia/remoção dos arquivos de imagem.
///
/// Telas falam só com esta classe, não com `sqflite`. A foto fica em
/// disco; a tabela guarda apenas [Item.imagePath].
class ItemRepository {
  /// Permite injetar outro banco em testes; no app usa o singleton.
  ItemRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  /// Pasta, dentro dos documentos do app, onde as fotos copiadas ficam.
  static const String imagesFolderName = 'item_images';

  /// Atalho: conexão já aberta pelo singleton.
  Future<Database> get _db async => _database.database;

  /// Consulta todos os itens, mais recentes primeiro.
  Future<List<Item>> getAll() async {
    final Database db = await _db;
    final List<Map<String, dynamic>> rows = await db.query(
      AppDatabase.itemsTable,
      orderBy: 'id DESC',
    );
    return rows.map(Item.fromMap).toList();
  }

  /// Consulta um item pela chave primária. Nulo se alguém apagou no meio.
  Future<Item?> getById(int id) async {
    final Database db = await _db;
    final List<Map<String, dynamic>> rows = await db.query(
      AppDatabase.itemsTable,
      where: 'id = ?',
      whereArgs: <Object>[id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Item.fromMap(rows.first);
  }

  /// Cadastra um item. Devolve o [id] gerado pelo AUTOINCREMENT.
  /// [item.toMap] vira as colunas do INSERT; sem `where` porque é linha nova.
  Future<int> insert(Item item) async {
    final Database db = await _db;
    return db.insert(AppDatabase.itemsTable, item.toMap());
  }

  /// Altera o registro. Devolve 0 ou 1 linha afetada.
  ///
  /// [item.toMap] = valores novos (SET). [where] + [whereArgs] = qual linha.
  /// O `?` é preenchido por `item.id` (já persistido; o `!` afirma que não é nulo).
  Future<int> update(Item item) async {
    final Database db = await _db;
    return db.update(
      AppDatabase.itemsTable,
      item.toMap(),
      where: 'id = ?',
      whereArgs: <Object>[item.id!],
    );
  }

  /// Exclui o item **e** o arquivo de imagem correspondente.
  /// Mesmo [where]/[whereArgs] do [update]: apaga só a linha daquele [id].
  Future<void> delete(Item item) async {
    final Database db = await _db;
    await db.delete(
      AppDatabase.itemsTable,
      where: 'id = ?',
      whereArgs: <Object>[item.id!],
    );
    await deleteImageFile(item.imagePath);
  }

  /// Copia a foto da galeria para a pasta **privada** do app.
  ///
  /// 1. `getApplicationDocumentsDirectory()` = sandbox do app (não é a
  ///    Galeria). No Android: `.../data/data/<pacote>/app_flutter/`.
  /// 2. Garante a subpasta `item_images/`.
  /// 3. Nome único (`timestamp` + extensão) para não sobrescrever.
  /// 4. `File.copy` — a original na galeria permanece.
  ///
  /// O path da galeria é temporário. Sem esta cópia a foto some ao
  /// fechar o app. A cópia **não** aparece na Galeria nem no app Arquivos;
  /// só este app lê (via [Item.imagePath]). Desinstalar apaga a pasta.
  Future<String> copyImageToAppDir(String sourcePath) async {
    final Directory documents = await getApplicationDocumentsDirectory();
    final Directory imagesDir = Directory(
      _join(documents.path, imagesFolderName),
    );
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final String extension = _fileExtension(sourcePath);
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}$extension';
    final String destinationPath = _join(imagesDir.path, fileName);

    await File(sourcePath).copy(destinationPath);
    return destinationPath;
  }

  /// Junta pasta e arquivo com `/` (Android/iOS).
  String _join(String directory, String name) => '$directory/$name';

  /// Extensão com ponto (`foto.jpg` → `.jpg`), ou vazio.
  String _fileExtension(String filePath) {
    final int slash = filePath.lastIndexOf('/');
    final String name =
        slash >= 0 ? filePath.substring(slash + 1) : filePath;
    final int dot = name.lastIndexOf('.');
    if (dot <= 0) {
      return '';
    }
    return name.substring(dot);
  }

  /// Remove o arquivo da foto. Silencioso se o arquivo já não existir.
  Future<void> deleteImageFile(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (error) {
      debugPrint('Não foi possível apagar a imagem $imagePath: $error');
    }
  }
}

# desafio_2 — CRUD de itens com SQLite

App Flutter do Desafio 2 (PDM2): cadastro de itens (nome, categoria, descrição
e imagem) com formulário, validação, `ListView`, navegação e persistência
local em SQLite.

Campos do desafio: **nome, categoria, descrição e imagem**.

## Executar

```bash
cd desafio_2
flutter pub get
flutter run
```

Rode em um **aparelho ou emulador** Android/iOS. Não há suporte a desktop.

## O que o app faz

- **Cadastrar** — `ItemFormScreen._submit` → `copyImageToAppDir` + `insert`
- **Consultar** — lista: `_loadItems` → `getAll`; um item: `_loadItem` → `getById`
- **Alterar** — `_submit` em edição → `update`
- **Excluir** — `_confirmAndDelete` → `delete` (linha + arquivo da foto)
- **Persistir** — `desafio2.db` (SQLite) + pasta privada `item_images/`

O SQLite **não** guarda a foto: a coluna `image_path` é `TEXT` (o caminho).
Os bytes JPEG/PNG ficam num arquivo na pasta privada do app. O app Arquivos
não vê essa pasta (sandbox do Android). Detalhe:

## Onde está cada parte

| Tema do desafio | Classe / método | Arquivo |
|-----------------|-----------------|--------|
| Entrada e `Navigator` | `main()`, `ItemCrudApp` | [lib/main.dart](lib/main.dart) |
| Modelo persistido | `Item`, `fromMap`, `toMap` | [lib/models/item.dart](lib/models/item.dart) |
| Banco SQLite | `AppDatabase`, `_open`, `_onCreate` | [lib/data/app_database.dart](lib/data/app_database.dart) |
| CRUD + cópia da foto | `ItemRepository` | [lib/data/item_repository.dart](lib/data/item_repository.dart) |
| ListView | `ItemListScreen`, `_loadItems` | [lib/screens/item_list_screen.dart](lib/screens/item_list_screen.dart) |
| Detalhe / excluir | `ItemDetailScreen` | [lib/screens/item_detail_screen.dart](lib/screens/item_detail_screen.dart) |
| Formulário | `ItemFormScreen`, `_submit` | [lib/screens/item_form_screen.dart](lib/screens/item_form_screen.dart) |
| Widgets | `ItemCard`, `ImagePickerField`, … | [lib/widgets/](lib/widgets/) |

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000');

class Book {
  const Book(this.id, this.title, this.price, this.author, this.age);
  final String id, title, author;
  final double price;
  final int age;
  factory Book.fromJson(Map<String, dynamic> j) => Book(
    j['id'] as String, j['title'] as String, (j['price'] as num).toDouble(),
    (j['author'] as Map<String, dynamic>)['name'] as String,
    (j['author'] as Map<String, dynamic>)['age'] as int,
  );
}

class BooksApi {
  final _client = http.Client();
  Uri _url(String path, [Map<String, String>? query]) => Uri.parse('$apiBaseUrl$path').replace(queryParameters: query);
  void _check(http.Response r) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      final body = jsonDecode(r.body);
      throw Exception(body is Map ? body['error'] : 'Falha ao acessar API');
    }
  }
  Future<List<Book>> list(String author) async {
    final r = await _client.get(_url('/books', author.isEmpty ? null : {'author': author}));
    _check(r);
    return (jsonDecode(r.body) as List).map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<Book?> cheapest() async {
    final r = await _client.get(_url('/books/cheapest'));
    _check(r);
    return r.body == 'null' ? null : Book.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }
  Future<Book> save({String? id, required String title, required double price, required String author, required int age}) async {
    final payload = jsonEncode({'title': title, 'price': price, 'author': {'name': author, 'age': age}});
    final uri = _url(id == null ? '/books' : '/books/$id');
    final headers = {'Content-Type': 'application/json'};
    final r = id == null ? await _client.post(uri, headers: headers, body: payload) : await _client.put(uri, headers: headers, body: payload);
    _check(r);
    return Book.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }
  Future<void> delete(String id) async { final r = await _client.delete(_url('/books/$id')); _check(r); }
}

class BooksApp extends StatelessWidget {
  const BooksApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: 'Catálogo de livros', theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)), home: const BooksPage());
}

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});
  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final _api = BooksApi();
  final _filter = TextEditingController();
  List<Book> _books = [];
  bool _loading = true;
  String? _error;
  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _filter.dispose(); super.dispose(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try { final list = await _api.list(_filter.text.trim()); if (mounted) setState(() { _books = list; _loading = false; }); }
    catch (e) { if (mounted) setState(() { _error = e.toString(); _loading = false; }); }
  }
  void _notify(Object e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
  Future<void> _form([Book? book]) async {
    final saved = await showDialog<bool>(context: context, builder: (_) => BookForm(api: _api, book: book));
    if (saved == true) _load();
  }
  Future<void> _cheapest() async {
    try {
      final b = await _api.cheapest();
      if (!mounted) return;
      showDialog<void>(context: context, builder: (ctx) => AlertDialog(title: const Text('Livro mais barato'), content: Text(b == null ? 'Nenhum livro cadastrado.' : '${b.title}\n${b.author}\nR\$ ${b.price.toStringAsFixed(2)}'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar'))]));
    } catch (e) { _notify(e); }
  }
  Future<void> _delete(Book b) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Excluir livro?'), content: Text('Deseja excluir “${b.title}”?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir'))]));
    if (yes != true) return;
    try { await _api.delete(b.id); _load(); } catch (e) { _notify(e); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Catálogo de livros'), actions: [IconButton(tooltip: 'Livro mais barato', onPressed: _cheapest, icon: const Icon(Icons.price_check)), IconButton(tooltip: 'Atualizar', onPressed: _load, icon: const Icon(Icons.refresh))]),
    body: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: TextField(controller: _filter, onSubmitted: (_) => _load(), decoration: InputDecoration(labelText: 'Filtrar por autor', border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(onPressed: _load, icon: const Icon(Icons.arrow_forward))))),
      Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Não foi possível carregar os livros.\n$_error', textAlign: TextAlign.center))) : _books.isEmpty ? const Center(child: Text('Nenhum livro encontrado. Toque em + para incluir.')) : ListView.builder(itemCount: _books.length, itemBuilder: (_, i) { final b = _books[i]; return ListTile(leading: const Icon(Icons.menu_book), title: Text(b.title), subtitle: Text('${b.author} · ${b.age} anos'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text('R\$ ${b.price.toStringAsFixed(2)}'), IconButton(tooltip: 'Editar', onPressed: () => _form(b), icon: const Icon(Icons.edit_outlined)), IconButton(tooltip: 'Excluir', onPressed: () => _delete(b), icon: const Icon(Icons.delete_outline))])); })),
    ]),
    floatingActionButton: FloatingActionButton(onPressed: () => _form(), tooltip: 'Adicionar livro', child: const Icon(Icons.add)),
  );
}

class BookForm extends StatefulWidget {
  const BookForm({super.key, required this.api, this.book});
  final BooksApi api;
  final Book? book;
  @override
  State<BookForm> createState() => _BookFormState();
}
class _BookFormState extends State<BookForm> {
  final _key = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.book?.title ?? '');
  late final _price = TextEditingController(text: widget.book?.price.toString() ?? '');
  late final _author = TextEditingController(text: widget.book?.author ?? '');
  late final _age = TextEditingController(text: widget.book?.age.toString() ?? '');
  bool _saving = false;
  @override
  void dispose() { _title.dispose(); _price.dispose(); _author.dispose(); _age.dispose(); super.dispose(); }
  String? _required(String? v) => v == null || v.trim().isEmpty ? 'Campo obrigatório' : null;
  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      // POST returns the Mongo-generated ID; PUT edits the same document by ID.
      await widget.api.save(id: widget.book?.id, title: _title.text.trim(), price: double.parse(_price.text.replaceAll(',', '.')), author: _author.text.trim(), age: int.parse(_age.text));
      if (mounted) Navigator.pop(context, true);
    } catch (e) { if (mounted) { setState(() => _saving = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); } }
  }
  @override
  Widget build(BuildContext context) => AlertDialog(title: Text(widget.book == null ? 'Incluir livro' : 'Editar livro'), content: Form(key: _key, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
    TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Nome do livro'), validator: _required),
    TextFormField(controller: _price, decoration: const InputDecoration(labelText: 'Preço (R\$)'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) { if (_required(v) != null) return 'Campo obrigatório'; final n = double.tryParse(v!.replaceAll(',', '.')); return n == null || n < 0 ? 'Preço inválido' : null; }),
    TextFormField(controller: _author, decoration: const InputDecoration(labelText: 'Nome do autor'), validator: _required),
    TextFormField(controller: _age, decoration: const InputDecoration(labelText: 'Idade do autor'), keyboardType: TextInputType.number, validator: (v) { if (_required(v) != null) return 'Campo obrigatório'; final n = int.tryParse(v!); return n == null || n < 0 || n > 150 ? 'Idade inválida' : null; }),
  ]))), actions: [TextButton(onPressed: _saving ? null : () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: _saving ? null : _save, child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salvar'))]);
}

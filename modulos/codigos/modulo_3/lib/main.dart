import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meus livros',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const LivrosPage(),
    );
  }
}

class LivrosPage extends StatefulWidget {
  const LivrosPage({super.key});

  @override
  State<LivrosPage> createState() => _LivrosPageState();
}

class _LivrosPageState extends State<LivrosPage> {
  int livroSelecionado = 0;
  int secaoSelecionada = 0;

  final livros = const [
    {'titulo': 'Dear Mr. Henshaw', 'autor': 'Beverly Cleary'},
    {'titulo': 'A interpretação dos sonhos', 'autor': 'Sigmund Freud'},
    {'titulo': 'Great Expectations', 'autor': 'Charles Dickens'},
    {'titulo': 'Não começou com você', 'autor': 'Mark Wolynn'},
  ];

  @override
  Widget build(BuildContext context) {
    final modoLargo = MediaQuery.sizeOf(context).width >= 700;

    return Scaffold(
      appBar: AppBar(title: const Text('Meus livros')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 700) {
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: secaoSelecionada,
                  onDestinationSelected: (index) {
                    setState(() {
                      secaoSelecionada = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.book_outlined),
                      selectedIcon: Icon(Icons.book),
                      label: Text('Livros'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_outline),
                      selectedIcon: Icon(Icons.people),
                      label: Text('Autores'),
                    ),
                  ],
                ),
                Expanded(
                  child: _buildSecaoLarga(context),
                ),
              ],
            );
          }

          return _buildSecaoCompacta(context);
        },
      ),
      bottomNavigationBar: modoLargo
          ? null
          : NavigationBar(
              selectedIndex: secaoSelecionada,
              onDestinationSelected: (index) {
                setState(() {
                  secaoSelecionada = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.book_outlined),
                  selectedIcon: Icon(Icons.book),
                  label: 'Livros',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: 'Autores',
                ),
              ],
            ),
    );
  }

  Widget _buildSecaoCompacta(BuildContext context) {
    if (secaoSelecionada == 1) {
      return _buildAutores();
    }

    return _buildLista(context);
  }

  Widget _buildSecaoLarga(BuildContext context) {
    if (secaoSelecionada == 1) {
      return _buildAutores();
    }

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildLista(context, modoLargo: true),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      livros[livroSelecionado]['titulo']!,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text('Autor: ${livros[livroSelecionado]['autor']}'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAutores() {
    return ListView(
      children: livros.map((livro) {
        return ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(livro['autor']!),
        );
      }).toList(),
    );
  }

  Widget _buildLista(BuildContext context, {bool modoLargo = false}) {
    return ListView(
      children: livros.asMap().entries.map((entry) {
        final index = entry.key;
        final livro = entry.value;

        return ListTile(
          title: Text(livro['titulo']!),
          subtitle: Text(livro['autor']!),
          trailing: const Icon(Icons.chevron_right),
          selected: modoLargo && index == livroSelecionado,
          onTap: () {
            if (modoLargo) {
              setState(() {
                livroSelecionado = index;
              });
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalhesPage(
                  titulo: livro['titulo']!,
                  autor: livro['autor']!,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class DetalhesPage extends StatelessWidget {
  const DetalhesPage({super.key, required this.titulo, required this.autor});

  final String titulo;
  final String autor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do livro')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text('Autor: $autor'),
          ],
        ),
      ),
    );
  }
}

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

class _LivrosPageState extends State<LivrosPage>
    with SingleTickerProviderStateMixin {
  int livroSelecionado = 0;
  int secaoSelecionada = 0;
  bool carregando = true;

  late final AnimationController _controller;
  late final Animation<double> escala;

  final livros = const [
    {
      'titulo': 'Dear Mr. Henshaw',
      'autor': 'Beverly Cleary',
      'preco': 39.90,
      'idadeAutor': 84,
    },
    {
      'titulo': 'A interpretação dos sonhos',
      'autor': 'Sigmund Freud',
      'preco': 54.90,
      'idadeAutor': 76,
    },
    {
      'titulo': 'Great Expectations',
      'autor': 'Charles Dickens',
      'preco': 44.50,
      'idadeAutor': 58,
    },
    {
      'titulo': 'Não começou com você',
      'autor': 'Mark Wolynn',
      'preco': 49.90,
      'idadeAutor': 52,
    },
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    escala = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(_controller);

    _controller.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      _controller.reset();
      setState(() {
        carregando = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _recarregar() {
    // Impede carregamentos simultâneos.
    if (carregando) {
      return;
    }

    setState(() {
      carregando = true;
    });

    _controller.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      _controller.reset();
      setState(() {
        carregando = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final modoLargo = MediaQuery.sizeOf(context).width >= 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus livros'),
        actions: [
          IconButton(
            onPressed: _recarregar,
            tooltip: 'Recarregar livros',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: carregando
          ? _buildIndicadorCarregamento()
          : LayoutBuilder(
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
      bottomNavigationBar: carregando
          ? null
          : modoLargo
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

  Widget _buildIndicadorCarregamento() {
    return Center(
      child: ScaleTransition(
        scale: escala,
        child: const Icon(Icons.menu_book, size: 48),
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
                      livros[livroSelecionado]['titulo']!.toString(),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text('Autor: ${livros[livroSelecionado]['autor']}'),
                    const SizedBox(height: 8),
                    Text('Idade fictícia do autor: ${livros[livroSelecionado]['idadeAutor']} anos'),
                    const SizedBox(height: 8),
                    Text('Preço fictício: R\$ ${(livros[livroSelecionado]['preco'] as double).toStringAsFixed(2)}'),
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
          title: Text(livro['autor']!.toString()),
          subtitle: Text('Idade fictícia: ${livro['idadeAutor']} anos'),
        );
      }).toList(),
    );
  }

  Widget _buildLista(BuildContext context, {bool modoLargo = false}) {
    return ListView(
      children: livros.asMap().entries.map((entry) {
        final index = entry.key;
        final livro = entry.value;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          color: livroSelecionado == index ? Colors.blue : Colors.white,
          child: ListTile(
            title: Text(livro['titulo']!.toString()),
            subtitle: Text('${livro['autor']} · R\$ ${(livro['preco'] as double).toStringAsFixed(2)}'),
            trailing: const Icon(Icons.chevron_right),
            selected: modoLargo && index == livroSelecionado,
            onTap: () {
              setState(() {
                livroSelecionado = index;
              });

              if (modoLargo) {
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalhesPage(
                    titulo: livro['titulo']!.toString(),
                    autor: livro['autor']!.toString(),
                    preco: livro['preco'] as double,
                    idadeAutor: livro['idadeAutor'] as int,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

class DetalhesPage extends StatelessWidget {
  const DetalhesPage({
    super.key,
    required this.titulo,
    required this.autor,
    required this.preco,
    required this.idadeAutor,
  });

  final String titulo;
  final String autor;
  final double preco;
  final int idadeAutor;

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
            const SizedBox(height: 8),
            Text('Idade fictícia do autor: $idadeAutor anos'),
            const SizedBox(height: 8),
            Text('Preço fictício: R\$ ${preco.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

# Desafio 1 — Preservação do Estado durante a Navegação

Este documento é um guia educativo completo do Desafio 1 (PDM2). Ao final, você deve conseguir:

1. entender **por que** o estado da tela se perde;
2. **recriar** o aplicativo do zero (lista, busca, scroll e detalhe);
3. reproduzir o **problema** (`desafio1-raw`);
4. aplicar a **solução** (`desafio1-solved`);
5. explicar as cinco perguntas pedidas no PDF do desafio.

---

## Branches deste repositório

| Branch | Objetivo |
|--------|----------|
| `desafio1-raw` | Demonstra a **perda** de estado ao navegar |
| `desafio1-solved` | Demonstra a **preservação** de estado ao navegar |

```bash
# Ver o problema
git checkout desafio1-raw
cd desafio_1 && flutter run

# Ver a solução
git checkout desafio1-solved
cd desafio_1 && flutter run
```

---

## 1. Qual era o problema de navegação identificado?

O usuário interage com a tela principal (rola a lista até o produto 72, digita algo na busca) e abre o detalhe de um produto. Ao voltar, a lista **não** continua de onde parou: a rolagem volta ao topo e o texto da busca some.

Isso quebra a expectativa de continuidade: a pessoa precisa reencontrar o item e redigitar o filtro.

No exemplo do PDF: chegar ao produto 72, abrir o detalhe e, ao retornar, ver a lista começando de novo no produto 1.

---

## 2. Por que o estado da tela poderia ser perdido?

No Flutter, o estado de uma tela `StatefulWidget` vive no objeto `State` (controllers, variáveis, posição do scroll, etc.). Esse `State` só permanece enquanto a rota correspondente continuar na **pilha de navegação** do `Navigator`.

### O que acontecia em `desafio1-raw`

A ida para o detalhe usava `Navigator.pushReplacement`:

```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => ProductDetailScreen(product: product),
  ),
);
```

`pushReplacement` **substitui** a rota atual. A `ProductListScreen` sai da pilha e o Flutter chama `dispose()` no `State` dela. Com isso:

- o `ScrollController` é descartado (posição da rolagem some);
- o `TextEditingController` é descartado (texto da busca some);
- `_filteredProducts` e `_hasText` deixam de existir.

Ao voltar, o detalhe cria uma **nova** `ProductListScreen` (de novo com `pushReplacement`). É outra instância, com estado inicial: scroll no topo e busca vazia.

### O que NÃO fazer para “simular” o problema

Não use `scrollController.jumpTo(0)` ao voltar. Isso **força** o reset mesmo quando o Flutter já teria preservado o estado (`push` + `pop`). O problema real é descartar a rota (e o `State`), não “zerar o scroll na mão”.

---

## 3. Qual estratégia foi utilizada para preservar esse estado?

Manter a tela da lista **viva na pilha** com `Navigator.push` e voltar com `Navigator.pop`.

### Em `desafio1-solved`

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProductDetailScreen(product: product),
  ),
);
```

Fluxo da pilha:

1. `[ProductListScreen]`
2. após `push`: `[ProductListScreen, ProductDetailScreen]`
3. após `pop` (botão voltar padrão): `[ProductListScreen]`

A lista nunca foi removida; o `State` não passou por `dispose`. Controllers e offset do scroll continuam válidos.

Na tela de detalhe, **não** há `leading` customizado que recria a lista: o `AppBar` usa o voltar automático do Flutter, que chama `pop`.

### Outras estratégias (para estudo)

| Estratégia | Ideia | Quando faz sentido |
|------------|--------|--------------------|
| `push` / `pop` (usada aqui) | Mantém o `State` montado | Navegação linear lista → detalhe |
| `PageStorageKey` | Guarda o offset do scroll no `PageStorage` | A rota é recriada, mas você quer só a rolagem |
| Estado externo (Provider, Riverpod, etc.) | Estado fora da rota | Estado compartilhado entre várias telas |
| `AutomaticKeepAliveClientMixin` | Mantém filhos vivos em abas/`PageView` | Bottom navigation, tabs |

Para este desafio, `push`/`pop` é a solução mais direta e idiomática.

---

## 4. Quais elementos da interface tiveram seu estado preservado?

| Elemento | Onde vive o estado | Preservado em `solved`? |
|----------|--------------------|-------------------------|
| Posição da rolagem da lista | `ScrollController` + `ListView` | Sim |
| Texto digitado na busca | `TextEditingController` | Sim |
| Lista filtrada | `_filteredProducts` no `State` | Sim |
| Ícone de limpar (X) da busca | `_hasText` no `State` | Sim |
| Produto aberto no detalhe | argumento `product` da rota | N/A (tela nova) |

---

## 5. Vantagens e limitações da solução adotada

### Vantagens

- Simples: quase nenhum código extra.
- Idiomática no Flutter para “ir e voltar”.
- Preserva **todo** o `State` (não só o scroll).
- Boa performance: não recria lista nem controllers à toa.
- Experiência natural para o usuário.

### Limitações

- Só funciona se a rota anterior **permanecer** na pilha. `pushReplacement`, `pushAndRemoveUntil` ou recriar a lista no voltar descartam o estado de novo.
- Telas no meio da pilha continuam na memória. Pilhas muito profundas podem custar mais RAM.
- Não cobre process killed / app morto pelo SO (aí seria persistência em disco).
- Não ajuda sozinha em abas ou shells que destroem filhos ao trocar de aba (aí entram `KeepAlive`, `PageStorage` ou estado global).

---

## Recriando o app do zero (passo a passo)

Estrutura mínima:

```text
desafio_1/lib/
├── main.dart
├── models/
│   └── product.dart
└── screens/
    ├── product_list_screen.dart
    └── product_detail_screen.dart
```

### Passo A — Modelo

```dart
// lib/models/product.dart
class Product {
  final int id;
  final String title;
  final double price;

  const Product({
    required this.id,
    required this.title,
    required this.price,
  });
}
```

### Passo B — `main.dart`

```dart
import 'package:flutter/material.dart';
import 'screens/product_list_screen.dart';

void main() {
  runApp(const SuperApp());
}

class SuperApp extends StatelessWidget {
  const SuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SuperApp',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const ProductListScreen(),
    );
  }
}
```

### Passo C — Lista com 100 itens mockados

Gere os produtos assim:

```dart
final List<Product> _allProducts = List.generate(
  100,
  (index) => Product(
    id: index + 1,
    title: 'Produto ${index + 1}',
    price: (index + 1) * 10.0,
  ),
);
```

### Passo D — Barra de busca

1. Crie um `TextEditingController`.
2. No `initState`, adicione um `listener` que filtra `_allProducts` pelo `title`.
3. Use um `TextField` com ícone de lupa e um `suffixIcon` de limpar quando houver texto.
4. No `dispose`, chame `_searchController.dispose()`.

Trecho essencial do filtro:

```dart
_searchController.addListener(() {
  final query = _searchController.text.toLowerCase();
  setState(() {
    _hasText = _searchController.text.isNotEmpty;
    _filteredProducts = _allProducts
        .where((p) => p.title.toLowerCase().contains(query))
        .toList();
  });
});
```

### Passo E — Lista com scroll visível

1. Crie um `ScrollController` e faça `dispose` dele.
2. Envolva o `ListView.builder` em um `RawScrollbar` com o mesmo controller.
3. Use `itemExtent: 48.0` para altura fixa (rolagem previsível).
4. Em cada item, um `InkWell` / `ListTile` abre o detalhe.

```dart
RawScrollbar(
  controller: _scrollController,
  thumbVisibility: true,
  child: ListView.builder(
    controller: _scrollController,
    itemCount: _filteredProducts.length,
    itemExtent: 48.0,
    itemBuilder: (context, index) {
      final product = _filteredProducts[index];
      return InkWell(
        onTap: () { /* navegação — ver versões raw/solved */ },
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(product.title),
        ),
      );
    },
  ),
);
```

### Passo F — Tela de detalhe

Mostre título, id e preço. O que muda entre as branches é **só a navegação**.

---

## Versão com o problema (`desafio1-raw`)

### Ideia

Descartar a lista ao sair e recriá-la ao voltar — **sem** `jumpTo`.

### Lista → detalhe

```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => ProductDetailScreen(product: product),
  ),
);
```

### Detalhe → lista

Como a lista foi removida da pilha, o voltar automático não basta. Recrie a lista:

```dart
void _voltarSemPreservarEstado(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const ProductListScreen(),
    ),
  );
}
```

Use isso no `IconButton` do `AppBar` e no `PopScope` (botão voltar do sistema), para o comportamento ser o mesmo nos dois caminhos.

### Como testar o problema

1. Rode o app na branch `desafio1-raw`.
2. Digite `Produto 7` na busca (ou role até o produto 72).
3. Abra um produto.
4. Volte.
5. Observe: busca vazia e lista no início.

---

## Versão com a solução (`desafio1-solved`)

### Ideia

Empilhar o detalhe e dar `pop` ao voltar, mantendo a lista montada.

### Lista → detalhe

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProductDetailScreen(product: product),
  ),
);
```

### Detalhe → lista

Não customize o `leading`. Deixe o `AppBar` chamar `Navigator.pop`.

### Como testar a solução

1. Rode o app na branch `desafio1-solved`.
2. Role até o produto 72 (e/ou filtre pela busca).
3. Abra o produto.
4. Volte.
5. Observe: mesma posição de scroll e mesmo texto na busca.

---

## Diff conceitual entre as branches

| Ponto | `desafio1-raw` | `desafio1-solved` |
|-------|----------------|-------------------|
| Ir ao detalhe | `pushReplacement` | `push` |
| Voltar | `pushReplacement` para nova lista | `pop` (voltar padrão) |
| `State` da lista | `dispose` ao sair | permanece vivo |
| Scroll / busca | perdidos | preservados |

A interface (100 produtos, busca, scrollbar, detalhe) é a mesma. Muda o **ciclo de vida da rota**.

---

## Mapa rápido do código

### `Product` (`lib/models/product.dart`)

Dados imutáveis do item: `id`, `title`, `price`.

### `SuperApp` (`lib/main.dart`)

`MaterialApp` com tema Material 3 e `home: ProductListScreen()`.

### `ProductListScreen`

- `StatefulWidget` porque guarda controllers e lista filtrada.
- `_allProducts`: 100 itens mockados.
- `_searchController` + listener: filtra em tempo real.
- `_scrollController`: posição da `ListView` / `RawScrollbar`.
- Navegação: o único ponto que muda entre raw e solved.

### `ProductDetailScreen`

- `StatelessWidget`: só exibe o `product` recebido.
- Raw: volta recriando a lista.
- Solved: volta com `pop`.

---

## Respostas curtas às 5 perguntas do PDF

1. **Problema:** ao voltar do detalhe, a lista não mantinha rolagem nem busca.
2. **Por quê:** a rota da lista era substituída (`pushReplacement`), o `State` ia para `dispose` e, ao voltar, uma tela nova nascia do zero.
3. **Estratégia:** `Navigator.push` + `Navigator.pop`, mantendo a lista na pilha.
4. **Elementos preservados:** offset do scroll, texto da busca, filtro da lista e ícone de limpar.
5. **Prós / contras:** simples e idiomática; depende de não destruir a rota e não persiste se o processo do app morrer.

---

## Comandos úteis

```bash
cd desafio_1
flutter pub get
flutter analyze
flutter run
```

Trocar de branch:

```bash
git checkout desafio1-raw     # problema
git checkout desafio1-solved  # solução
```

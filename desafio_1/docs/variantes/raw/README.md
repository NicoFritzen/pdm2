# Variante raw: demonstração da perda de estado

Os quatro arquivos Dart nesta pasta preservam a versão da branch `desafio1-raw`, que usa `Navigator.pushReplacement` para descartar a lista ao abrir os detalhes e recriá-la ao voltar. A implementação principal em `desafio_1/lib/` é a versão resolvida, que usa `push`/`pop` para manter o estado de rolagem e busca. Os demais arquivos do app (dados, widgets e configuração Flutter) são compartilhados com o projeto principal.

Para comparar o comportamento, substitua temporariamente os arquivos correspondentes da pasta `lib/` pelos desta variante.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:modulo_4/main.dart';

void main() {
  testWidgets('mostra os livros e abre os detalhes no modo compacto',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(600, 800));
    await tester.pumpWidget(const MyApp());

    expect(find.text('Dear Mr. Henshaw'), findsOneWidget);
    expect(find.text('Beverly Cleary'), findsOneWidget);
    expect(find.text('A interpretação dos sonhos'), findsOneWidget);
    expect(find.text('Great Expectations'), findsOneWidget);
    expect(find.text('Não começou com você'), findsOneWidget);

    await tester.tap(find.text('Autores'));
    await tester.pump();

    expect(find.text('Beverly Cleary'), findsOneWidget);
    expect(find.text('Dear Mr. Henshaw'), findsNothing);

    await tester.tap(find.text('Livros'));
    await tester.pump();

    await tester.tap(find.text('Dear Mr. Henshaw'));
    await tester.pumpAndSettle();

    expect(find.text('Detalhes do livro'), findsOneWidget);
    expect(find.text('Autor: Beverly Cleary'), findsOneWidget);
  });

  testWidgets('atualiza o painel no modo largo', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 800));
    await tester.pumpWidget(const MyApp());

    expect(find.text('Dear Mr. Henshaw'), findsOneWidget);
    expect(find.text('Autor: Beverly Cleary'), findsOneWidget);

    await tester.tap(find.text('Autores'));
    await tester.pump();

    expect(find.text('Dear Mr. Henshaw'), findsNothing);
    expect(find.text('Autor: Charles Dickens'), findsOneWidget);

    await tester.tap(find.text('Livros'));
    await tester.pump();

    await tester.tap(find.text('Great Expectations'));
    await tester.pump();

    expect(find.text('Charles Dickens'), findsOneWidget);
  });
}

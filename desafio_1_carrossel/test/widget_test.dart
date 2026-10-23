import 'package:flutter_test/flutter_test.dart';
import 'package:desafio_1_carrossel/main.dart';

void main() {
  testWidgets('exibe a galeria com título e indicador de posição', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GalleryApp());

    expect(find.text('Galeria Inteligente'), findsOneWidget);
    expect(find.text('Imagem 1 de 8'), findsOneWidget);
    expect(find.text('Floresta ao amanhecer'), findsWidgets);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readl/widgets/primary_button.dart';

void main() {
  testWidgets('affiche le texte et déclenche onPressed', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'Se connecter',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.text('Se connecter'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('affiche un indicateur de chargement et se désactive',
      (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'Se connecter',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Se connecter'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(tapped, isFalse);
  });
}

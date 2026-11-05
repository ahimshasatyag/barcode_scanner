import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barcode/core/transitions/smooth_page_transition.dart';

void main() {
  testWidgets('SmoothPageRoute animates transition properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  context.pushSmooth(
                    const Scaffold(
                      body: Text('Halaman Target'),
                    ),
                  );
                },
                child: const Text('Buka'),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Buka'), findsOneWidget);
    await tester.tap(find.text('Buka'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150)); // mid-transition
    await tester.pumpAndSettle(); // finish transition

    expect(find.text('Halaman Target'), findsOneWidget);
  });
}


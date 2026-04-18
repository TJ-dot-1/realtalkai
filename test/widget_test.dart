import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtalk_ai/app.dart';

void main() {
  testWidgets('App loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RealTalkApp(),
      ),
    );

    // Verify the login screen renders
    expect(find.text('RealTalk AI'), findsOneWidget);
    expect(find.text('Master Real Conversations'), findsOneWidget);
  });
}

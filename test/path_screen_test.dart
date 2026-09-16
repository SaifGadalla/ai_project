import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:ai_project/presentation/screens/path/path_screen.dart';
import 'package:ai_project/presentation/components/day_plan_tile.dart';
import 'package:ai_project/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('PathScreen Widget Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    final String testUserId = 'test_user_id';
    final String testPathId = 'test_path_id';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      final mockUser = MockUser(uid: testUserId);
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    });

    Widget createWidgetUnderTest() {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Text('Home'))),
          GoRoute(
            path: '/path',
            builder: (context, state) => PathScreen(
              pathId: testPathId,
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        ],
      );

      return MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('ar', ''),
        ],
      );
    }

    testWidgets('Opening a path renders UI correctly with mocked data', (WidgetTester tester) async {
      // 1. Arrange: populate FakeFirestore with a path
      await fakeFirestore
          .collection('users')
          .doc(testUserId)
          .collection('paths')
          .doc(testPathId)
          .set({
        'title': 'Learn Flutter',
        'description': 'A 30-day journey to learn Flutter',
        'days': [
          {
            'dayNumber': 1,
            'title': 'Introduction to Dart',
            'tasks': [
              {'title': 'Read variables', 'description': 'Variables in Dart', 'isCompleted': false}
            ]
          }
        ]
      });

      // 2. Act: Pump the widget and navigate to the path
      await tester.pumpWidget(createWidgetUnderTest());
      final BuildContext context = tester.element(find.byType(Scaffold).first);
      context.push('/path');
      await tester.pumpAndSettle();

      // 3. Assert: Check if title and description are rendered
      expect(find.text('Learn Flutter'), findsOneWidget);
      expect(find.text('A 30-day journey to learn Flutter'), findsOneWidget);
      
      // Assert: Check if DayPlanTile is rendered
      expect(find.byType(DayPlanTile), findsOneWidget);
    });

    testWidgets('Deleting a path triggers confirmation dialog and deletes document', (WidgetTester tester) async {
      // 1. Arrange
      await fakeFirestore
          .collection('users')
          .doc(testUserId)
          .collection('paths')
          .doc(testPathId)
          .set({
        'title': 'Learn Flutter to Delete',
        'description': 'This will be deleted',
        'days': []
      });

      await tester.pumpWidget(createWidgetUnderTest());
      final BuildContext context = tester.element(find.byType(Scaffold).first);
      context.push('/path');
      await tester.pumpAndSettle();

      // Ensure it exists in firestore initially
      var doc = await fakeFirestore.collection('users').doc(testUserId).collection('paths').doc(testPathId).get();
      expect(doc.exists, true);

      // 2. Act: Tap delete icon
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // 3. Assert: Dialog appears
      expect(find.text('Delete Path'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this learning path?'), findsOneWidget);

      // 4. Act: Tap "Delete" button in dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // 5. Assert: Document is deleted from firestore
      var deletedDoc = await fakeFirestore.collection('users').doc(testUserId).collection('paths').doc(testPathId).get();
      expect(deletedDoc.exists, false);
    });
  });
}

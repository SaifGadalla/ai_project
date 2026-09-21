import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_project/presentation/screens/path/path_screen.dart';
import 'package:ai_project/presentation/controller/path/path_cubit.dart';
import 'package:ai_project/data/models/learning_path.dart';
import 'package:ai_project/presentation/components/day_plan_tile.dart';
import 'package:ai_project/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockPathCubit extends MockCubit<PathState> implements PathCubit {}

void main() {
  group('PathScreen Widget Tests', () {
    late MockPathCubit mockPathCubit;
    final String testPathId = 'test_path_id';

    setUp(() {
      mockPathCubit = MockPathCubit();
    });

    Widget createWidgetUnderTest() {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Text('Home'))),
          GoRoute(
            path: '/path',
            builder: (context, state) => BlocProvider<PathCubit>.value(
              value: mockPathCubit,
              child: PathScreen(
                pathId: testPathId,
              ),
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
      // 1. Arrange: populate MockCubit with a path
      final fakePath = LearningPath(
        id: testPathId,
        title: 'Learn Flutter',
        description: 'A 30-day journey to learn Flutter',
        days: [
          DayPlan(
            dayNumber: 1,
            title: 'Introduction to Dart',
            tasks: [
              Task(title: 'Read variables', isCompleted: false),
            ],
          ),
        ],
        createdAt: DateTime.now(),
      );
      
      when(() => mockPathCubit.state).thenReturn(PathLoaded(fakePath));

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
      final fakePath = LearningPath(
        id: testPathId,
        title: 'Learn Flutter to Delete',
        description: 'This will be deleted',
        days: [],
        createdAt: DateTime.now(),
      );
      
      when(() => mockPathCubit.state).thenReturn(PathLoaded(fakePath));
      when(() => mockPathCubit.deletePath()).thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());
      final BuildContext context = tester.element(find.byType(Scaffold).first);
      context.push('/path');
      await tester.pumpAndSettle();

      // 2. Act: Tap delete icon
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // 3. Assert: Dialog appears
      expect(find.text('Delete Path'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this learning path?'), findsOneWidget);

      // 4. Act: Tap "Delete" button in dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // 5. Assert: Cubit delete is called
      verify(() => mockPathCubit.deletePath()).called(1);
    });
  });
}

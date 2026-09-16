import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:ai_project/presentation/controller/prompt/bloc.dart';
import 'package:ai_project/l10n/app_localizations.dart';
import 'package:ai_project/domain/repository/ai_repository.dart';

// --- Mocks ---
class MockAiRepository extends Mock implements AiRepository {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

class MockUser extends Mock implements User {}

void main() {
  group('CreationBloc Tests', () {
    late CreationBloc creationBloc;
    late MockAiRepository mockAi;
    late FakeFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    late MockAppLocalizations mockLocalizations;
    late MockUser mockUser;

    setUp(() {
      mockAi = MockAiRepository();
      mockFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockLocalizations = MockAppLocalizations();
      mockUser = MockUser();

      when(() => mockLocalizations.promptInitialMessage).thenReturn('Hello');
      when(() => mockLocalizations.promptErrorNoResponse).thenReturn('Error');
      when(
        () => mockLocalizations.promptErrorGeneric,
      ).thenReturn('Generic Error');
      when(
        () => mockLocalizations.promptErrorUnauthenticated,
      ).thenReturn('Unauthenticated');

      creationBloc = CreationBloc(
        localizations: mockLocalizations,
        aiRepository: mockAi,
        firestore: mockFirestore,
        auth: mockAuth,
      );
    });

    tearDown(() {
      creationBloc.close();
    });

    test('initial state has the initial AI message', () {
      final state = creationBloc.state as CreationChatActive;
      expect(state.messages.length, 1);
      expect(state.messages.first.text, 'Hello');
      expect(state.messages.first.isUser, false);
      expect(state.canGenerate, false);
    });

    blocTest<CreationBloc, CreationState>(
      'SendMessage adds user message and AI response',
      build: () {
        when(
          () => mockAi.sendMessage(any()),
        ).thenAnswer((_) async => 'AI reply');
        return creationBloc;
      },
      act: (bloc) => bloc.add(SendMessage('I want to learn Flutter')),
      expect: () => [
        isA<CreationChatActive>()
            .having((s) => s.isTyping, 'isTyping', true)
            .having((s) => s.messages.length, 'length', 2),
        isA<CreationChatActive>()
            .having((s) => s.isTyping, 'isTyping', false)
            .having((s) => s.messages.length, 'length', 3)
            .having((s) => s.canGenerate, 'canGenerate', true),
      ],
    );

    blocTest<CreationBloc, CreationState>(
      'FinalizePath creates JSON and saves to Firestore',
      build: () {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('test_uid');

        when(() => mockAi.generatePathJson(any())).thenAnswer(
          (_) async =>
              '{"title": "Test Path", "description": "Desc", "days": []}',
        );

        // Setup initial user message so validation passes
        creationBloc.add(SendMessage('Hello'));

        return creationBloc;
      },
      act: (bloc) async {
        // Wait for the SendMessage to finish
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(FinalizePath());
      },
      skip: 2, // Skip the SendMessage states
      expect: () => [
        isA<CreationLoading>(),
        isA<CreationSuccess>().having((s) => s.pathId, 'pathId', isNotEmpty),
      ],
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_project/presentation/controller/prompt/bloc.dart';
import 'package:ai_project/domain/usecases/auth/get_auth_state_usecase.dart';
import 'package:ai_project/domain/usecases/path/save_generated_path_usecase.dart';
import 'package:ai_project/l10n/app_localizations.dart';
import 'package:ai_project/domain/repository/ai_repository.dart';

// --- Mocks ---
class MockAiRepository extends Mock implements AiRepository {}

class MockGetAuthStateUseCase extends Mock implements GetAuthStateUseCase {}
class MockSaveGeneratedPathUseCase extends Mock implements SaveGeneratedPathUseCase {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

class MockUser extends Mock implements User {}

void main() {
  group('CreationBloc Tests', () {
    late CreationBloc creationBloc;
    late MockAiRepository mockAi;
    late MockGetAuthStateUseCase mockGetAuthStateUseCase;
    late MockSaveGeneratedPathUseCase mockSaveGeneratedPathUseCase;
    late MockAppLocalizations mockLocalizations;
    late MockUser mockUser;

    setUp(() {
      mockAi = MockAiRepository();
      mockGetAuthStateUseCase = MockGetAuthStateUseCase();
      mockSaveGeneratedPathUseCase = MockSaveGeneratedPathUseCase();
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
        getAuthStateUseCase: mockGetAuthStateUseCase,
        saveGeneratedPathUseCase: mockSaveGeneratedPathUseCase,
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
        when(() => mockGetAuthStateUseCase.currentUser).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn('test_uid');

        when(() => mockAi.generatePathJson(any())).thenAnswer(
          (_) async =>
              '{"title": "Test Path", "description": "Desc", "days": []}',
        );
        
        when(() => mockSaveGeneratedPathUseCase(
          userId: any(named: 'userId'),
          pathData: any(named: 'pathData'),
          originalPrompt: any(named: 'originalPrompt'),
        )).thenAnswer((_) async => 'mocked_doc_id');

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

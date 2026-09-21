import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';

import 'package:ai_project/domain/usecases/auth/login_usecase.dart';
import 'package:ai_project/domain/usecases/auth/signup_usecase.dart';
import 'package:ai_project/presentation/controller/auth/login_cubit.dart';
import 'package:ai_project/presentation/controller/auth/signup_cubit.dart';
import 'package:ai_project/presentation/controller/theme/theme_cubit.dart';
import 'package:ai_project/presentation/controller/locale/locale_cubit.dart';
class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockSignupUseCase extends Mock implements SignupUseCase {}

void main() {
  group('ThemeCubit Tests', () {
    late ThemeCubit themeCubit;

    setUp(() {
      themeCubit = ThemeCubit();
    });

    tearDown(() {
      themeCubit.close();
    });

    test('initial state is ThemeMode.system', () {
      expect(themeCubit.state, ThemeMode.system);
    });

    blocTest<ThemeCubit, ThemeMode>(
      'emits [ThemeMode.dark] when toggleTheme is called from system',
      build: () => themeCubit,
      act: (cubit) => cubit.toggleTheme(),
      expect: () => [ThemeMode.dark],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'emits [ThemeMode.light] when toggleTheme is called from dark',
      build: () => themeCubit..setTheme(ThemeMode.dark),
      act: (cubit) => cubit.toggleTheme(),
      expect: () => [ThemeMode.light],
    );
  });

  group('LocaleCubit Tests', () {
    late LocaleCubit localeCubit;

    setUp(() {
      localeCubit = LocaleCubit();
    });

    tearDown(() {
      localeCubit.close();
    });

    test('initial state is Locale("ar")', () {
      expect(localeCubit.state, const Locale('ar'));
    });

    blocTest<LocaleCubit, Locale>(
      'emits [Locale("en")] when toggleLanguage is called from "ar"',
      build: () => localeCubit,
      act: (cubit) => cubit.toggleLanguage(),
      expect: () => [const Locale('en')],
    );
  });

  group('LoginCubit Tests', () {
    late LoginCubit loginCubit;
    late MockLoginUseCase mockLoginUseCase;

    setUp(() {
      mockLoginUseCase = MockLoginUseCase();
      loginCubit = LoginCubit(mockLoginUseCase);
    });

    tearDown(() {
      loginCubit.close();
    });

    test('initial state is LoginStatus.initial', () {
      expect(loginCubit.state.status, LoginStatus.initial);
    });

    blocTest<LoginCubit, LoginState>(
      'emits [submitting, success] when login is successful',
      build: () {
        when(
          () => mockLoginUseCase(
            email: 'test@test.com',
            password: 'password',
          ),
        ).thenAnswer((_) async {
          return null;
        });
        return loginCubit;
      },
      act: (cubit) => cubit.loginWithCredentials(
        email: 'test@test.com',
        password: 'password',
      ),
      expect: () => const [
        LoginState(status: LoginStatus.submitting),
        LoginState(status: LoginStatus.success),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [submitting, error] when login fails',
      build: () {
        when(
          () => mockLoginUseCase(
            email: 'test@test.com',
            password: 'password',
          ),
        ).thenThrow(Exception('Login Failed'));
        return loginCubit;
      },
      act: (cubit) => cubit.loginWithCredentials(
        email: 'test@test.com',
        password: 'password',
      ),
      expect: () => const [
        LoginState(status: LoginStatus.submitting),
        LoginState(
          status: LoginStatus.error,
          errorMessage: 'Exception: Login Failed',
        ),
      ],
    );
  });

  group('SignupCubit Tests', () {
    late SignupCubit signupCubit;
    late MockSignupUseCase mockSignupUseCase;

    setUp(() {
      mockSignupUseCase = MockSignupUseCase();
      signupCubit = SignupCubit(mockSignupUseCase);
    });

    tearDown(() {
      signupCubit.close();
    });

    test('initial state is SignupStatus.initial', () {
      expect(signupCubit.state.status, SignupStatus.initial);
    });

    blocTest<SignupCubit, SignupState>(
      'emits [submitting, success] when signup is successful',
      build: () {
        when(
          () => mockSignupUseCase(
            email: 'test@test.com',
            password: 'password',
            name: 'Test',
          ),
        ).thenAnswer((_) async {
          return null;
        });
        return signupCubit;
      },
      act: (cubit) => cubit.signupWithCredentials(
        email: 'test@test.com',
        password: 'password',
        name: 'Test',
      ),
      expect: () => const [
        SignupState(status: SignupStatus.submitting),
        SignupState(status: SignupStatus.success),
      ],
    );
  });
}

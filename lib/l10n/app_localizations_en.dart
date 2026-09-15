// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI Learning Path';

  @override
  String get authWelcomeBack => 'Welcome Back';

  @override
  String get authSignInSubtitle => 'Sign in to continue your learning journey';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authSignInButton => 'Sign In';

  @override
  String get authSignUpPrompt => 'Don\'t have an account? Sign Up';

  @override
  String get signupCreateAccountTitle => 'Create Account';

  @override
  String get signupJoinUs => 'Join Us';

  @override
  String get signupSubtitle => 'Start generating AI learning paths today';

  @override
  String get signupNameLabel => 'Name';

  @override
  String get signupButton => 'Sign Up';

  @override
  String get drawerAppTitle => 'AI Learning Paths';

  @override
  String get drawerHome => 'Home';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get drawerYourPaths => 'Your Paths';

  @override
  String get drawerNoPaths => 'No learning paths yet.';

  @override
  String get homeNoPathsCreateOne => 'No learning paths yet. Create one!';

  @override
  String get errorNotAuthenticated => 'User not authenticated';

  @override
  String get pathScreenTitle => 'Learning Path';

  @override
  String get errorPathNotFound => 'Path not found';

  @override
  String get errorTitle => 'Error';

  @override
  String get dayDetailsTitle => 'Day Details';

  @override
  String get dayPrefix => 'Day';

  @override
  String get dayTasksSubtitle => 'Tasks for the day';

  @override
  String get dayNoTasks => 'No tasks for this day.';

  @override
  String get settingsDarkTheme => 'Dark Theme';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageCurrent => 'English (Default)';

  @override
  String get settingsLanguageSoon => 'Language selection coming soon';

  @override
  String get settingsSignOut => 'Sign Out';

  @override
  String get promptInitialMessage => 'Hi! What do you want to learn today?';

  @override
  String get promptErrorSafety =>
      'I cannot fulfill this request. It either violates safety guidelines or hit a system limit.';

  @override
  String get promptErrorGeneric => 'Error: Something went wrong.';

  @override
  String get promptErrorUnauthenticated => 'User not authenticated.';

  @override
  String get promptErrorNoResponse => 'I am not sure how to respond to that.';

  @override
  String get promptPlanYourPath => 'Plan Your Path';

  @override
  String get promptBuildPath => 'Build Path';

  @override
  String get promptTypeResponse => 'Type your response...';

  @override
  String get promptGeneratingPath => 'Generating structured path...';
}

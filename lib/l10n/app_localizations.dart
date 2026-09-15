import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Learning Path'**
  String get appTitle;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get authWelcomeBack;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your learning journey'**
  String get authSignInSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignInButton;

  /// No description provided for @authSignUpPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get authSignUpPrompt;

  /// No description provided for @signupCreateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signupCreateAccountTitle;

  /// No description provided for @signupJoinUs.
  ///
  /// In en, this message translates to:
  /// **'Join Us'**
  String get signupJoinUs;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start generating AI learning paths today'**
  String get signupSubtitle;

  /// No description provided for @signupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get signupNameLabel;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signupButton;

  /// No description provided for @drawerAppTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Learning Paths'**
  String get drawerAppTitle;

  /// No description provided for @drawerHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get drawerHome;

  /// No description provided for @drawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettings;

  /// No description provided for @drawerYourPaths.
  ///
  /// In en, this message translates to:
  /// **'Your Paths'**
  String get drawerYourPaths;

  /// No description provided for @drawerNoPaths.
  ///
  /// In en, this message translates to:
  /// **'No learning paths yet.'**
  String get drawerNoPaths;

  /// No description provided for @homeNoPathsCreateOne.
  ///
  /// In en, this message translates to:
  /// **'No learning paths yet. Create one!'**
  String get homeNoPathsCreateOne;

  /// No description provided for @errorNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get errorNotAuthenticated;

  /// No description provided for @pathScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Path'**
  String get pathScreenTitle;

  /// No description provided for @errorPathNotFound.
  ///
  /// In en, this message translates to:
  /// **'Path not found'**
  String get errorPathNotFound;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @dayDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Day Details'**
  String get dayDetailsTitle;

  /// No description provided for @dayPrefix.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayPrefix;

  /// No description provided for @dayTasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks for the day'**
  String get dayTasksSubtitle;

  /// No description provided for @dayNoTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks for this day.'**
  String get dayNoTasks;

  /// No description provided for @settingsDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get settingsDarkTheme;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageCurrent.
  ///
  /// In en, this message translates to:
  /// **'English (Default)'**
  String get settingsLanguageCurrent;

  /// No description provided for @settingsLanguageSoon.
  ///
  /// In en, this message translates to:
  /// **'Language selection coming soon'**
  String get settingsLanguageSoon;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsSignOut;

  /// No description provided for @promptInitialMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi! What do you want to learn today?'**
  String get promptInitialMessage;

  /// No description provided for @promptErrorSafety.
  ///
  /// In en, this message translates to:
  /// **'I cannot fulfill this request. It either violates safety guidelines or hit a system limit.'**
  String get promptErrorSafety;

  /// No description provided for @promptErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: Something went wrong.'**
  String get promptErrorGeneric;

  /// No description provided for @promptErrorUnauthenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated.'**
  String get promptErrorUnauthenticated;

  /// No description provided for @promptErrorNoResponse.
  ///
  /// In en, this message translates to:
  /// **'I am not sure how to respond to that.'**
  String get promptErrorNoResponse;

  /// No description provided for @promptPlanYourPath.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Path'**
  String get promptPlanYourPath;

  /// No description provided for @promptBuildPath.
  ///
  /// In en, this message translates to:
  /// **'Build Path'**
  String get promptBuildPath;

  /// No description provided for @promptTypeResponse.
  ///
  /// In en, this message translates to:
  /// **'Type your response...'**
  String get promptTypeResponse;

  /// No description provided for @promptGeneratingPath.
  ///
  /// In en, this message translates to:
  /// **'Generating structured path...'**
  String get promptGeneratingPath;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

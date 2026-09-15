// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مسار تعلم الذكاء الاصطناعي';

  @override
  String get authWelcomeBack => 'مرحبًا بعودتك';

  @override
  String get authSignInSubtitle => 'سجل الدخول لمتابعة رحلة التعلم الخاصة بك';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authSignInButton => 'تسجيل الدخول';

  @override
  String get authSignUpPrompt => 'ليس لديك حساب؟ إنشاء حساب';

  @override
  String get signupCreateAccountTitle => 'إنشاء حساب';

  @override
  String get signupJoinUs => 'انضم إلينا';

  @override
  String get signupSubtitle => 'ابدأ بإنشاء مسارات تعلم الذكاء الاصطناعي اليوم';

  @override
  String get signupNameLabel => 'الاسم';

  @override
  String get signupButton => 'إنشاء حساب';

  @override
  String get drawerAppTitle => 'مسارات تعلم الذكاء الاصطناعي';

  @override
  String get drawerHome => 'الرئيسية';

  @override
  String get drawerSettings => 'الإعدادات';

  @override
  String get drawerYourPaths => 'مساراتك';

  @override
  String get drawerNoPaths => 'لا توجد مسارات تعلم بعد.';

  @override
  String get homeNoPathsCreateOne => 'لا توجد مسارات تعلم بعد. أنشئ واحدًا!';

  @override
  String get errorNotAuthenticated => 'المستخدم غير مصادق عليه';

  @override
  String get pathScreenTitle => 'مسار التعلم';

  @override
  String get errorPathNotFound => 'لم يتم العثور على المسار';

  @override
  String get errorTitle => 'خطأ';

  @override
  String get dayDetailsTitle => 'تفاصيل اليوم';

  @override
  String get dayPrefix => 'اليوم';

  @override
  String get dayTasksSubtitle => 'مهام اليوم';

  @override
  String get dayNoTasks => 'لا توجد مهام لهذا اليوم.';

  @override
  String get settingsDarkTheme => 'الوضع الداكن';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageCurrent => 'الإنجليزية (الافتراضي)';

  @override
  String get settingsLanguageSoon => 'اختيار اللغة قريباً';

  @override
  String get settingsSignOut => 'تسجيل الخروج';

  @override
  String get promptInitialMessage => 'مرحباً! ماذا تريد أن تتعلم اليوم؟';

  @override
  String get promptErrorSafety =>
      'لا يمكنني تلبية هذا الطلب. إما أنه ينتهك إرشادات السلامة أو وصل إلى حد النظام.';

  @override
  String get promptErrorGeneric => 'خطأ: حدث خطأ ما.';

  @override
  String get promptErrorUnauthenticated => 'المستخدم غير مصادق عليه.';

  @override
  String get promptErrorNoResponse => 'لست متأكداً من كيفية الرد على ذلك.';

  @override
  String get promptPlanYourPath => 'خطط مسارك';

  @override
  String get promptBuildPath => 'بناء المسار';

  @override
  String get promptTypeResponse => 'اكتب ردك...';

  @override
  String get promptGeneratingPath => 'جاري إنشاء المسار المهيكل...';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'AppTrial';

  @override
  String get appTagline => 'اربط مطوري أندرويد بمختبرين موثوقين.';

  @override
  String get preparingApp => 'جارٍ تجهيز AppTrial…';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get saving => 'جارٍ الحفظ…';

  @override
  String get create => 'إنشاء';

  @override
  String get register => 'تسجيل';

  @override
  String get back => 'رجوع';

  @override
  String get errorGeneric => 'حدث خطأ ما';

  @override
  String get errorSomethingWentWrong => 'حدث خطأ ما';

  @override
  String errorWithDetails(String details) {
    return 'خطأ: $details';
  }

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navExplore => 'استكشاف';

  @override
  String get navCampaigns => 'الحملات';

  @override
  String get navMissions => 'المهام';

  @override
  String get navWallet => 'المحفظة';

  @override
  String get navProfile => 'الملف';

  @override
  String get loginTitle => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle =>
      'سجّل الدخول لإدارة الحملات أو الانضمام للاختبار.';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get invalidEmail => 'بريد إلكتروني غير صالح';

  @override
  String get passwordMinLength => '8 أحرف على الأقل';

  @override
  String get loginErrorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get loginErrorEmailTaken => 'هذا البريد مسجّل بالفعل.';

  @override
  String get loginErrorBadRequest => 'راجع البيانات وحاول مرة أخرى.';

  @override
  String get loginErrorNoConnection => 'تعذر الاتصال بالخادم.';

  @override
  String get loginErrorGeneric => 'تعذر إكمال العملية.';

  @override
  String get language => 'اللغة';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageArabic => 'العربية';

  @override
  String get currentLanguage => 'اللغة الحالية';

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get registerSubtitle =>
      'ابدأ بنشر الحملات أو اختبار التطبيقات خلال دقائق.';

  @override
  String get displayName => 'الاسم';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get roleDeveloperTitle => 'أنا مطور';

  @override
  String get roleDeveloperSubtitle => 'أنشر التطبيقات وحملات الاختبار';

  @override
  String get roleTesterTitle => 'أريد أن أكون مختبرًا';

  @override
  String get roleTesterSubtitle => 'أنضم للحملات وأكسب TestCredits';

  @override
  String get selectAtLeastOneRole => 'اختر دورًا واحدًا على الأقل';

  @override
  String get signUp => 'إنشاء الحساب';

  @override
  String get alreadyHaveAccount => 'لدي حساب بالفعل';

  @override
  String get greetingMorning => 'صباح الخير';

  @override
  String get greetingAfternoon => 'مساء الخير';

  @override
  String get greetingEvening => 'مساء الخير';

  @override
  String get quickActions => 'اختصارات سريعة';

  @override
  String get quickActionsSubtitle => 'ما تستخدمه أكثر بنقرة واحدة';

  @override
  String get apps => 'التطبيقات';

  @override
  String get groups => 'المجموعات';

  @override
  String get analytics => 'التحليلات';

  @override
  String get feedback => 'الملاحظات';

  @override
  String get alerts => 'التنبيهات';

  @override
  String get admin => 'الإدارة';

  @override
  String get openCampaigns => 'حملات مفتوحة';

  @override
  String get yourCampaigns => 'حملاتك';

  @override
  String get openCampaignsSubtitle => 'انضم وابدأ الاختبار';

  @override
  String get yourCampaignsSubtitle => 'حالة التوظيف والتقدم';

  @override
  String get nothingToExplore => 'لا يوجد ما يُستكشف';

  @override
  String get noCampaignsYet => 'لا توجد حملات بعد';

  @override
  String get nothingToExploreMessage => 'عند توفر حملات للتوظيف ستظهر هنا.';

  @override
  String get noCampaignsYetMessage => 'أنشئ حملتك الأولى من تبويب الحملات.';

  @override
  String get buyCredits => 'شراء أرصدة';

  @override
  String get testCredits => 'TestCredits';

  @override
  String reservedCredits(int count) {
    return 'محجوز: $count TC';
  }

  @override
  String get walletCouldNotLoad => 'تعذر تحميل المحفظة';

  @override
  String get exploreTitle => 'استكشاف';

  @override
  String get exploreSubtitle => 'حملات مفتوحة جاهزة للانضمام';

  @override
  String get searchCampaignsHint => 'ابحث بالاسم أو التطبيق';

  @override
  String get noResults => 'لا نتائج';

  @override
  String get noResultsMessage => 'لا توجد حملات توظيف بهذا المعيار.';

  @override
  String get refresh => 'تحديث';

  @override
  String get join => 'انضمام';

  @override
  String joinedGroup(String name, int occupied, int target) {
    return 'انضممت إلى $name ($occupied/$target)';
  }

  @override
  String couldNotJoin(String details) {
    return 'تعذر الانضمام: $details';
  }

  @override
  String daysCount(int count) {
    return '$count يومًا';
  }

  @override
  String seatsCount(int count) {
    return '$count مقعدًا';
  }

  @override
  String testersCount(int count) {
    return '$count مختبرًا';
  }

  @override
  String tcPerSeat(int count) {
    return '$count TC/مقعد';
  }

  @override
  String tcAmount(int count) {
    return '$count TC';
  }

  @override
  String get myCampaignsTitle => 'حملاتي';

  @override
  String get myCampaignsSubtitle => 'مسودات وتوظيف ومتابعة';

  @override
  String get newCampaign => 'حملة جديدة';

  @override
  String get stillNoCampaigns => 'لا توجد لديك حملات بعد';

  @override
  String get stillNoCampaignsMessage => 'أنشئ مسودة وانشرها لبدء التوظيف.';

  @override
  String get groupsTooltip => 'المجموعات';

  @override
  String get aiInsightsTooltip => 'رؤى الذكاء الاصطناعي';

  @override
  String get sseTooltip => 'SSE';

  @override
  String get publishTooltip => 'نشر';

  @override
  String get cancelTooltip => 'إلغاء';

  @override
  String publishFailed(String details) {
    return 'فشل النشر: $details';
  }

  @override
  String get registerAppFirst => 'سجّل تطبيقًا أولاً';

  @override
  String get newCampaignDialogTitle => 'حملة جديدة';

  @override
  String get application => 'التطبيق';

  @override
  String get name => 'الاسم';

  @override
  String get required => 'مطلوب';

  @override
  String get description => 'الوصف';

  @override
  String get duration => 'المدة';

  @override
  String get duration7 => '7 أيام (12 TC/مختبر)';

  @override
  String get duration14 => '14 يومًا (20 TC/مختبر)';

  @override
  String get duration30 => '30 يومًا (30 TC/مختبر)';

  @override
  String get targetTestersLabel =>
      'عدد المختبرين (الحد الأدنى 12، الافتراضي 15)';

  @override
  String get minimum12 => 'الحد الأدنى 12';

  @override
  String get createDraft => 'إنشاء مسودة';

  @override
  String couldNotCreate(String details) {
    return 'تعذر الإنشاء: $details';
  }

  @override
  String get myApplications => 'تطبيقاتي';

  @override
  String get noAppsYet => 'لا تطبيقات بعد';

  @override
  String get noAppsYetMessage => 'سجّل أول تطبيق أندرويد لإنشاء الحملات.';

  @override
  String get archive => 'أرشفة';

  @override
  String get registerApplication => 'تسجيل تطبيق';

  @override
  String get registerApplicationSubtitle =>
      'أضف تطبيق أندرويد الذي تريد اختباره مع مستخدمين حقيقيين.';

  @override
  String get sectionBasicInfo => 'معلومات أساسية';

  @override
  String get sectionBasicInfoHint => 'كيف يظهر التطبيق للمختبرين';

  @override
  String get sectionTechnical => 'تفاصيل تقنية';

  @override
  String get sectionTechnicalHint => 'اسم الحزمة والإصدار في Play';

  @override
  String get packageName => 'Package name';

  @override
  String get invalidPackage => 'اسم حزمة غير صالح';

  @override
  String get version => 'الإصدار';

  @override
  String couldNotCreateApp(String details) {
    return 'تعذر الإنشاء: $details';
  }

  @override
  String get preferences => 'التفضيلات';

  @override
  String get preferencesSubtitle => 'اللغة والإشعارات وأدوات المطور';

  @override
  String get languageSection => 'اللغة';

  @override
  String get languageSectionSubtitle => 'يُطبَّق فورًا على التطبيق بالكامل';

  @override
  String get notificationsSection => 'إشعارات الدفع';

  @override
  String get notificationsSectionSubtitle => 'اختر الأحداث التي تريد استلامها';

  @override
  String get developerTools => 'أدوات المطور';

  @override
  String get registerMockFcm => 'تسجيل رمز FCM تجريبي';

  @override
  String get registerMockFcmSubtitle => 'يحفظ رمز تطوير في الخادم (وضع MOCK).';

  @override
  String tokenRegistered(String token) {
    return 'تم تسجيل الرمز: $token';
  }

  @override
  String get preferencesSaved => 'تم حفظ التفضيلات';

  @override
  String get prefAll => 'كل الإشعارات';

  @override
  String get prefAllSubtitle => 'المفتاح الرئيسي لتنبيهات الدفع';

  @override
  String get prefCampaignPublished => 'نشر الحملة';

  @override
  String get prefCampaignPublishedSubtitle => 'عند بدء توظيف حملتك';

  @override
  String get prefCampaignJoined => 'انضمام مختبر';

  @override
  String get prefCampaignJoinedSubtitle => 'عند انضمام شخص إلى حملة';

  @override
  String get prefGroupReady => 'المجموعة جاهزة';

  @override
  String get prefGroupReadySubtitle => 'عند اكتمال مجموعة المختبرين';

  @override
  String get prefMissionApproved => 'مهمة معتمدة';

  @override
  String get prefMissionApprovedSubtitle => 'عند اعتماد إرسال';

  @override
  String get prefCreditsChanged => 'تغيّر الرصيد';

  @override
  String get prefCreditsChangedSubtitle => 'تحديثات رصيد المحفظة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get emailVerified => 'البريد مُتحقق منه';

  @override
  String get yes => 'نعم';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get country => 'البلد';

  @override
  String get localeLabel => 'اللغة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get devices => 'الأجهزة';

  @override
  String get notificationPreferences => 'تفضيلات الإشعارات';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get walletTitle => 'المحفظة';

  @override
  String get walletSubtitle => 'رصيد TestCredits والسجل';

  @override
  String get history => 'السجل';

  @override
  String get historySubtitle => 'كل حركة تُسجَّل في الدفتر';

  @override
  String get noMovements => 'لا حركات';

  @override
  String get noMovementsMessage => 'عند الحجز أو الإنفاق أو الشراء ستظهر هنا.';

  @override
  String get creditsDisclaimer =>
      'الأرصدة غير قابلة للسحب أو التحويل إلى مال حقيقي. الشراء عبر Google Play Billing فقط.';

  @override
  String get buyCreditsTitle => 'شراء أرصدة';

  @override
  String get billingDisclaimer =>
      'المدفوعات الرقمية عبر Google Play Billing فقط. يتحقق الخادم من الرمز قبل إضافة TC.';

  @override
  String get packages => 'الباقات';

  @override
  String get packagesSubtitle => 'مثالية للحملات الفردية';

  @override
  String get subscriptions => 'الاشتراكات';

  @override
  String get subscriptionsSubtitle => 'خطط Free → Studio عبر Play';

  @override
  String get recommended => 'موصى به';

  @override
  String get simulatePlayPurchase => 'محاكاة شراء Play';

  @override
  String purchaseVerified(String status, Object credited) {
    return 'تم التحقق ($status): +$credited TC';
  }

  @override
  String purchaseFailed(String details) {
    return 'فشل الشراء: $details';
  }

  @override
  String get missionsTitle => 'المهام';

  @override
  String get missionsSubtitle => 'أنشطة الحملات وإرسالاتك';

  @override
  String get campaignsSection => 'الحملات';

  @override
  String get noCampaignsAvailable => 'لا حملات';

  @override
  String get noCampaignsAvailableMessage => 'عند وجود حملات ستظهر مهامها هنا.';

  @override
  String get openMissions => 'فتح المهام';

  @override
  String get mySubmissions => 'إرسالاتي';

  @override
  String get noSubmissions => 'لا إرسالات';

  @override
  String get noSubmissionsMessage => 'أكمل مهمة لرؤية حالة المراجعة هنا.';

  @override
  String get missionSubmission => 'إرسال مهمة';

  @override
  String evidenceCount(int count) {
    return 'الأدلة: $count';
  }

  @override
  String get myGroups => 'مجموعاتي';

  @override
  String get notInGroupYet => 'لست في مجموعة بعد';

  @override
  String get notInGroupYetMessage => 'استكشف الحملات المفتوحة وانضم للبدء.';

  @override
  String groupProgress(int occupied, int target, String status) {
    return '$occupied/$target مقعدًا · حالتك: $status';
  }

  @override
  String get confirm => 'تأكيد';

  @override
  String get leave => 'مغادرة';

  @override
  String get markActive => 'تعيين كنشط';

  @override
  String couldNotUpdate(String details) {
    return 'تعذر التحديث: $details';
  }

  @override
  String get notifications => 'الإشعارات';

  @override
  String get markAll => 'تحديد الكل';

  @override
  String get inboxEmpty => 'صندوق فارغ';

  @override
  String get inboxEmptyMessage =>
      'عند وجود تحديثات للحملات أو الأرصدة ستظهر هنا.';

  @override
  String get analyticsTitle => 'التحليلات';

  @override
  String get mySummary => 'ملخصي';

  @override
  String get mySummarySubtitle => 'نشاط تطبيقاتك وحملاتك';

  @override
  String get activeCampaigns => 'حملات نشطة';

  @override
  String get seats => 'المقاعد';

  @override
  String get approved => 'معتمد';

  @override
  String get credits => 'الأرصدة';

  @override
  String get platform => 'المنصة';

  @override
  String get platformSubtitle => 'عرض المسؤول';

  @override
  String get users => 'المستخدمون';

  @override
  String get developers => 'المطورون';

  @override
  String get testers => 'المختبرون';

  @override
  String get applicationLabel => 'التطبيق';

  @override
  String get mission => 'مهمة';

  @override
  String get noMissionsCreateFirst => 'لا مهام. أنشئ الأولى.';

  @override
  String get submit => 'إرسال';

  @override
  String get review => 'مراجعة';

  @override
  String get newMission => 'مهمة جديدة';

  @override
  String get missionSubmitted => 'تم إرسال المهمة مع الدليل';

  @override
  String get noSubmissionsToReview => 'لا إرسالات للمراجعة';

  @override
  String approvedWithReward(String id, Object reward) {
    return 'تمت الموافقة على $id (+$reward TC)';
  }

  @override
  String get noUsers => 'لا مستخدمين.';

  @override
  String get noFraudSignals => 'لا إشارات احتيال.';

  @override
  String get noAudit => 'لا سجلات تدقيق.';

  @override
  String get noClusters => 'لا مجموعات';

  @override
  String get noVisibleMembers => 'لا أعضاء ظاهرين';

  @override
  String get aiInsights => 'رؤى الذكاء الاصطناعي';

  @override
  String get campaignEvents => 'أحداث مباشرة';

  @override
  String get devicesTitle => 'الأجهزة';

  @override
  String get registerDevice => 'تسجيل جهاز';

  @override
  String get feedbackTitle => 'الملاحظات';

  @override
  String get newFeedback => 'ملاحظة جديدة';

  @override
  String get adminTitle => 'الإدارة';

  @override
  String get usersTab => 'المستخدمون';

  @override
  String get fraudTab => 'الاحتيال';

  @override
  String get auditTab => 'التدقيق';

  @override
  String get noGroupsForCampaign => 'هذه الحملة لا تحتوي على مجموعات بعد.';

  @override
  String get noFeedbackYet => 'لم ترسل ملاحظات بعد.';

  @override
  String get noDevicesYet => 'لا توجد أجهزة مسجّلة بعد.';

  @override
  String get fingerprint => 'Fingerprint';

  @override
  String get model => 'الطراز';

  @override
  String get manufacturer => 'الشركة المصنعة';

  @override
  String get androidVersion => 'Android';

  @override
  String get suspend => 'تعليق';

  @override
  String get activate => 'تفعيل';

  @override
  String get adjustCreditsPlus10 => 'تعديل +10 TC';

  @override
  String modeLabel(String mode) {
    return 'الوضع: $mode';
  }

  @override
  String get summary => 'الملخص';

  @override
  String get clusters => 'المجموعات';

  @override
  String get suggestedImprovements => 'تحسينات مقترحة';

  @override
  String get reconnect => 'إعادة الاتصال';

  @override
  String get connectedLiveEvents => 'متصل بالأحداث المباشرة';

  @override
  String get connecting => 'جارٍ الاتصال…';

  @override
  String get waitingForEvents => 'بانتظار الأحداث…';

  @override
  String get missionTitle => 'العنوان';
}

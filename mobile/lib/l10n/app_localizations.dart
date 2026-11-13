import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AppTrial'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Connect Android developers with trusted testers.'**
  String get appTagline;

  /// No description provided for @preparingApp.
  ///
  /// In en, this message translates to:
  /// **'Preparing AppTrial…'**
  String get preparingApp;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @errorSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorSomethingWentWrong;

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {details}'**
  String errorWithDetails(String details);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Campaigns'**
  String get navCampaigns;

  /// No description provided for @navMissions.
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get navMissions;

  /// No description provided for @navWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get navWallet;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage campaigns or join testing.'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @loginErrorEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'That email is already registered.'**
  String get loginErrorEmailTaken;

  /// No description provided for @loginErrorBadRequest.
  ///
  /// In en, this message translates to:
  /// **'Check your details and try again.'**
  String get loginErrorBadRequest;

  /// No description provided for @loginErrorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the server.'**
  String get loginErrorNoConnection;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the operation.'**
  String get loginErrorGeneric;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current language'**
  String get currentLanguage;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start publishing campaigns or testing apps in minutes.'**
  String get registerSubtitle;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get displayName;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @roleDeveloperTitle.
  ///
  /// In en, this message translates to:
  /// **'I am a developer'**
  String get roleDeveloperTitle;

  /// No description provided for @roleDeveloperSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I publish apps and testing campaigns'**
  String get roleDeveloperSubtitle;

  /// No description provided for @roleTesterTitle.
  ///
  /// In en, this message translates to:
  /// **'I want to be a tester'**
  String get roleTesterTitle;

  /// No description provided for @roleTesterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I join campaigns and earn TestCredits'**
  String get roleTesterSubtitle;

  /// No description provided for @selectAtLeastOneRole.
  ///
  /// In en, this message translates to:
  /// **'Select at least one role'**
  String get selectAtLeastOneRole;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @quickActionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What you use most, one tap away'**
  String get quickActionsSubtitle;

  /// No description provided for @apps.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get apps;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @openCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Open campaigns'**
  String get openCampaigns;

  /// No description provided for @yourCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Your campaigns'**
  String get yourCampaigns;

  /// No description provided for @openCampaignsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join and start testing'**
  String get openCampaignsSubtitle;

  /// No description provided for @yourCampaignsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recruiting status and progress'**
  String get yourCampaignsSubtitle;

  /// No description provided for @nothingToExplore.
  ///
  /// In en, this message translates to:
  /// **'Nothing to explore'**
  String get nothingToExplore;

  /// No description provided for @noCampaignsYet.
  ///
  /// In en, this message translates to:
  /// **'No campaigns yet'**
  String get noCampaignsYet;

  /// No description provided for @nothingToExploreMessage.
  ///
  /// In en, this message translates to:
  /// **'When campaigns are recruiting, they will appear here.'**
  String get nothingToExploreMessage;

  /// No description provided for @noCampaignsYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Create your first campaign from the Campaigns tab.'**
  String get noCampaignsYetMessage;

  /// No description provided for @buyCredits.
  ///
  /// In en, this message translates to:
  /// **'Buy credits'**
  String get buyCredits;

  /// No description provided for @testCredits.
  ///
  /// In en, this message translates to:
  /// **'TestCredits'**
  String get testCredits;

  /// No description provided for @reservedCredits.
  ///
  /// In en, this message translates to:
  /// **'Reserved: {count} TC'**
  String reservedCredits(int count);

  /// No description provided for @walletCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load wallet'**
  String get walletCouldNotLoad;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @exploreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open campaigns ready to join'**
  String get exploreSubtitle;

  /// No description provided for @searchCampaignsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or app'**
  String get searchCampaignsHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @noResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'No recruiting campaigns match that filter.'**
  String get noResultsMessage;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @joinedGroup.
  ///
  /// In en, this message translates to:
  /// **'Joined {name} ({occupied}/{target})'**
  String joinedGroup(String name, int occupied, int target);

  /// No description provided for @couldNotJoin.
  ///
  /// In en, this message translates to:
  /// **'Could not join: {details}'**
  String couldNotJoin(String details);

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// No description provided for @seatsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} seats'**
  String seatsCount(int count);

  /// No description provided for @testersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} testers'**
  String testersCount(int count);

  /// No description provided for @tcPerSeat.
  ///
  /// In en, this message translates to:
  /// **'{count} TC/seat'**
  String tcPerSeat(int count);

  /// No description provided for @tcAmount.
  ///
  /// In en, this message translates to:
  /// **'{count} TC'**
  String tcAmount(int count);

  /// No description provided for @myCampaignsTitle.
  ///
  /// In en, this message translates to:
  /// **'My campaigns'**
  String get myCampaignsTitle;

  /// No description provided for @myCampaignsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drafts, recruiting and tracking'**
  String get myCampaignsSubtitle;

  /// No description provided for @newCampaign.
  ///
  /// In en, this message translates to:
  /// **'New campaign'**
  String get newCampaign;

  /// No description provided for @stillNoCampaigns.
  ///
  /// In en, this message translates to:
  /// **'You still have no campaigns'**
  String get stillNoCampaigns;

  /// No description provided for @stillNoCampaignsMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a draft and publish it to start recruiting.'**
  String get stillNoCampaignsMessage;

  /// No description provided for @groupsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupsTooltip;

  /// No description provided for @aiInsightsTooltip.
  ///
  /// In en, this message translates to:
  /// **'AI insights'**
  String get aiInsightsTooltip;

  /// No description provided for @sseTooltip.
  ///
  /// In en, this message translates to:
  /// **'SSE'**
  String get sseTooltip;

  /// No description provided for @publishTooltip.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishTooltip;

  /// No description provided for @cancelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelTooltip;

  /// No description provided for @publishFailed.
  ///
  /// In en, this message translates to:
  /// **'Publish failed: {details}'**
  String publishFailed(String details);

  /// No description provided for @registerAppFirst.
  ///
  /// In en, this message translates to:
  /// **'Register an application first'**
  String get registerAppFirst;

  /// No description provided for @newCampaignDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New campaign'**
  String get newCampaignDialogTitle;

  /// No description provided for @application.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get application;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @duration7.
  ///
  /// In en, this message translates to:
  /// **'7 days (12 TC/tester)'**
  String get duration7;

  /// No description provided for @duration14.
  ///
  /// In en, this message translates to:
  /// **'14 days (20 TC/tester)'**
  String get duration14;

  /// No description provided for @duration30.
  ///
  /// In en, this message translates to:
  /// **'30 days (30 TC/tester)'**
  String get duration30;

  /// No description provided for @targetTestersLabel.
  ///
  /// In en, this message translates to:
  /// **'Target testers (min. 12, default 15)'**
  String get targetTestersLabel;

  /// No description provided for @minimum12.
  ///
  /// In en, this message translates to:
  /// **'Minimum 12'**
  String get minimum12;

  /// No description provided for @createDraft.
  ///
  /// In en, this message translates to:
  /// **'Create draft'**
  String get createDraft;

  /// No description provided for @couldNotCreate.
  ///
  /// In en, this message translates to:
  /// **'Could not create: {details}'**
  String couldNotCreate(String details);

  /// No description provided for @myApplications.
  ///
  /// In en, this message translates to:
  /// **'My applications'**
  String get myApplications;

  /// No description provided for @noAppsYet.
  ///
  /// In en, this message translates to:
  /// **'No apps yet'**
  String get noAppsYet;

  /// No description provided for @noAppsYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Register your first Android app to create campaigns.'**
  String get noAppsYetMessage;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @registerApplication.
  ///
  /// In en, this message translates to:
  /// **'Register application'**
  String get registerApplication;

  /// No description provided for @registerApplicationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add the Android app you want to test with real users.'**
  String get registerApplicationSubtitle;

  /// No description provided for @sectionBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get sectionBasicInfo;

  /// No description provided for @sectionBasicInfoHint.
  ///
  /// In en, this message translates to:
  /// **'How the app appears to testers'**
  String get sectionBasicInfoHint;

  /// No description provided for @sectionTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical details'**
  String get sectionTechnical;

  /// No description provided for @sectionTechnicalHint.
  ///
  /// In en, this message translates to:
  /// **'Package and version used in Play'**
  String get sectionTechnicalHint;

  /// No description provided for @packageName.
  ///
  /// In en, this message translates to:
  /// **'Package name'**
  String get packageName;

  /// No description provided for @invalidPackage.
  ///
  /// In en, this message translates to:
  /// **'Invalid package'**
  String get invalidPackage;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @couldNotCreateApp.
  ///
  /// In en, this message translates to:
  /// **'Could not create: {details}'**
  String couldNotCreateApp(String details);

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @preferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Language, notifications and developer tools'**
  String get preferencesSubtitle;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// No description provided for @languageSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Applies immediately across the app'**
  String get languageSectionSubtitle;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get notificationsSection;

  /// No description provided for @notificationsSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose which events you want to receive'**
  String get notificationsSectionSubtitle;

  /// No description provided for @developerTools.
  ///
  /// In en, this message translates to:
  /// **'Developer tools'**
  String get developerTools;

  /// No description provided for @registerMockFcm.
  ///
  /// In en, this message translates to:
  /// **'Register mock FCM token'**
  String get registerMockFcm;

  /// No description provided for @registerMockFcmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stores a development token in the backend (MOCK mode).'**
  String get registerMockFcmSubtitle;

  /// No description provided for @tokenRegistered.
  ///
  /// In en, this message translates to:
  /// **'Token registered: {token}'**
  String tokenRegistered(String token);

  /// No description provided for @preferencesSaved.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved'**
  String get preferencesSaved;

  /// No description provided for @prefAll.
  ///
  /// In en, this message translates to:
  /// **'All notifications'**
  String get prefAll;

  /// No description provided for @prefAllSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Master switch for push alerts'**
  String get prefAllSubtitle;

  /// No description provided for @prefCampaignPublished.
  ///
  /// In en, this message translates to:
  /// **'Campaign published'**
  String get prefCampaignPublished;

  /// No description provided for @prefCampaignPublishedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When your campaign starts recruiting'**
  String get prefCampaignPublishedSubtitle;

  /// No description provided for @prefCampaignJoined.
  ///
  /// In en, this message translates to:
  /// **'Tester joined'**
  String get prefCampaignJoined;

  /// No description provided for @prefCampaignJoinedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When someone joins a campaign'**
  String get prefCampaignJoinedSubtitle;

  /// No description provided for @prefGroupReady.
  ///
  /// In en, this message translates to:
  /// **'Group ready'**
  String get prefGroupReady;

  /// No description provided for @prefGroupReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'When a tester group is full'**
  String get prefGroupReadySubtitle;

  /// No description provided for @prefMissionApproved.
  ///
  /// In en, this message translates to:
  /// **'Mission approved'**
  String get prefMissionApproved;

  /// No description provided for @prefMissionApprovedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When a submission is approved'**
  String get prefMissionApprovedSubtitle;

  /// No description provided for @prefCreditsChanged.
  ///
  /// In en, this message translates to:
  /// **'Credits changed'**
  String get prefCreditsChanged;

  /// No description provided for @prefCreditsChangedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet balance updates'**
  String get prefCreditsChangedSubtitle;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get emailVerified;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @localeLabel.
  ///
  /// In en, this message translates to:
  /// **'Locale'**
  String get localeLabel;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences'**
  String get notificationPreferences;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletTitle;

  /// No description provided for @walletSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your TestCredits balance and history'**
  String get walletSubtitle;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every movement stays in the ledger'**
  String get historySubtitle;

  /// No description provided for @noMovements.
  ///
  /// In en, this message translates to:
  /// **'No movements'**
  String get noMovements;

  /// No description provided for @noMovementsMessage.
  ///
  /// In en, this message translates to:
  /// **'When you reserve, spend or buy credits they will appear here.'**
  String get noMovementsMessage;

  /// No description provided for @creditsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Credits are non-withdrawable and not convertible to real money. Purchases only via Google Play Billing.'**
  String get creditsDisclaimer;

  /// No description provided for @buyCreditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy credits'**
  String get buyCreditsTitle;

  /// No description provided for @billingDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Digital payments only through Google Play Billing. The backend verifies the token before crediting TC.'**
  String get billingDisclaimer;

  /// No description provided for @packages.
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get packages;

  /// No description provided for @packagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ideal for one-off campaigns'**
  String get packagesSubtitle;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @subscriptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free → Studio plans via Play'**
  String get subscriptionsSubtitle;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @simulatePlayPurchase.
  ///
  /// In en, this message translates to:
  /// **'Simulate Play purchase'**
  String get simulatePlayPurchase;

  /// No description provided for @purchaseVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified ({status}): +{credited} TC'**
  String purchaseVerified(String status, Object credited);

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed: {details}'**
  String purchaseFailed(String details);

  /// No description provided for @missionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get missionsTitle;

  /// No description provided for @missionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Activities by campaign and your submissions'**
  String get missionsSubtitle;

  /// No description provided for @campaignsSection.
  ///
  /// In en, this message translates to:
  /// **'Campaigns'**
  String get campaignsSection;

  /// No description provided for @noCampaignsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No campaigns'**
  String get noCampaignsAvailable;

  /// No description provided for @noCampaignsAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'When you have campaigns, their missions will show here.'**
  String get noCampaignsAvailableMessage;

  /// No description provided for @openMissions.
  ///
  /// In en, this message translates to:
  /// **'Open missions'**
  String get openMissions;

  /// No description provided for @mySubmissions.
  ///
  /// In en, this message translates to:
  /// **'My submissions'**
  String get mySubmissions;

  /// No description provided for @noSubmissions.
  ///
  /// In en, this message translates to:
  /// **'No submissions'**
  String get noSubmissions;

  /// No description provided for @noSubmissionsMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete a mission to see review status here.'**
  String get noSubmissionsMessage;

  /// No description provided for @missionSubmission.
  ///
  /// In en, this message translates to:
  /// **'Mission submission'**
  String get missionSubmission;

  /// No description provided for @evidenceCount.
  ///
  /// In en, this message translates to:
  /// **'Evidence: {count}'**
  String evidenceCount(int count);

  /// No description provided for @myGroups.
  ///
  /// In en, this message translates to:
  /// **'My groups'**
  String get myGroups;

  /// No description provided for @notInGroupYet.
  ///
  /// In en, this message translates to:
  /// **'You are not in a group yet'**
  String get notInGroupYet;

  /// No description provided for @notInGroupYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Explore open campaigns and join to get started.'**
  String get notInGroupYetMessage;

  /// No description provided for @groupProgress.
  ///
  /// In en, this message translates to:
  /// **'{occupied}/{target} seats · Your status: {status}'**
  String groupProgress(int occupied, int target, String status);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @markActive.
  ///
  /// In en, this message translates to:
  /// **'Mark active'**
  String get markActive;

  /// No description provided for @couldNotUpdate.
  ///
  /// In en, this message translates to:
  /// **'Could not update: {details}'**
  String couldNotUpdate(String details);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAll.
  ///
  /// In en, this message translates to:
  /// **'Mark all'**
  String get markAll;

  /// No description provided for @inboxEmpty.
  ///
  /// In en, this message translates to:
  /// **'Inbox empty'**
  String get inboxEmpty;

  /// No description provided for @inboxEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'When there are campaign or credit updates, you will see them here.'**
  String get inboxEmptyMessage;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @mySummary.
  ///
  /// In en, this message translates to:
  /// **'My summary'**
  String get mySummary;

  /// No description provided for @mySummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Activity from your apps and campaigns'**
  String get mySummarySubtitle;

  /// No description provided for @activeCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Active campaigns'**
  String get activeCampaigns;

  /// No description provided for @seats.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get seats;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @platform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// No description provided for @platformSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Admin view'**
  String get platformSubtitle;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @developers.
  ///
  /// In en, this message translates to:
  /// **'Developers'**
  String get developers;

  /// No description provided for @testers.
  ///
  /// In en, this message translates to:
  /// **'Testers'**
  String get testers;

  /// No description provided for @applicationLabel.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get applicationLabel;

  /// No description provided for @mission.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get mission;

  /// No description provided for @noMissionsCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'No missions. Create the first one.'**
  String get noMissionsCreateFirst;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @newMission.
  ///
  /// In en, this message translates to:
  /// **'New mission'**
  String get newMission;

  /// No description provided for @missionSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Mission submitted with evidence'**
  String get missionSubmitted;

  /// No description provided for @noSubmissionsToReview.
  ///
  /// In en, this message translates to:
  /// **'No submissions to review'**
  String get noSubmissionsToReview;

  /// No description provided for @approvedWithReward.
  ///
  /// In en, this message translates to:
  /// **'Approved {id} (+{reward} TC)'**
  String approvedWithReward(String id, Object reward);

  /// No description provided for @noUsers.
  ///
  /// In en, this message translates to:
  /// **'No users.'**
  String get noUsers;

  /// No description provided for @noFraudSignals.
  ///
  /// In en, this message translates to:
  /// **'No fraud signals.'**
  String get noFraudSignals;

  /// No description provided for @noAudit.
  ///
  /// In en, this message translates to:
  /// **'No audit entries.'**
  String get noAudit;

  /// No description provided for @noClusters.
  ///
  /// In en, this message translates to:
  /// **'No clusters'**
  String get noClusters;

  /// No description provided for @noVisibleMembers.
  ///
  /// In en, this message translates to:
  /// **'No visible members'**
  String get noVisibleMembers;

  /// No description provided for @aiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI insights'**
  String get aiInsights;

  /// No description provided for @campaignEvents.
  ///
  /// In en, this message translates to:
  /// **'Live events'**
  String get campaignEvents;

  /// No description provided for @devicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devicesTitle;

  /// No description provided for @registerDevice.
  ///
  /// In en, this message translates to:
  /// **'Register device'**
  String get registerDevice;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackTitle;

  /// No description provided for @newFeedback.
  ///
  /// In en, this message translates to:
  /// **'New feedback'**
  String get newFeedback;

  /// No description provided for @adminTitle.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get adminTitle;

  /// No description provided for @usersTab.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersTab;

  /// No description provided for @fraudTab.
  ///
  /// In en, this message translates to:
  /// **'Fraud'**
  String get fraudTab;

  /// No description provided for @auditTab.
  ///
  /// In en, this message translates to:
  /// **'Audit'**
  String get auditTab;

  /// No description provided for @noGroupsForCampaign.
  ///
  /// In en, this message translates to:
  /// **'This campaign has no groups yet.'**
  String get noGroupsForCampaign;

  /// No description provided for @noFeedbackYet.
  ///
  /// In en, this message translates to:
  /// **'You have not sent feedback yet.'**
  String get noFeedbackYet;

  /// No description provided for @noDevicesYet.
  ///
  /// In en, this message translates to:
  /// **'No devices registered yet.'**
  String get noDevicesYet;

  /// No description provided for @fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get fingerprint;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @manufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get manufacturer;

  /// No description provided for @androidVersion.
  ///
  /// In en, this message translates to:
  /// **'Android'**
  String get androidVersion;

  /// No description provided for @suspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get suspend;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @adjustCreditsPlus10.
  ///
  /// In en, this message translates to:
  /// **'Adjust +10 TC'**
  String get adjustCreditsPlus10;

  /// No description provided for @modeLabel.
  ///
  /// In en, this message translates to:
  /// **'Mode: {mode}'**
  String modeLabel(String mode);

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @clusters.
  ///
  /// In en, this message translates to:
  /// **'Clusters'**
  String get clusters;

  /// No description provided for @suggestedImprovements.
  ///
  /// In en, this message translates to:
  /// **'Suggested improvements'**
  String get suggestedImprovements;

  /// No description provided for @reconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get reconnect;

  /// No description provided for @connectedLiveEvents.
  ///
  /// In en, this message translates to:
  /// **'Connected to live events'**
  String get connectedLiveEvents;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// No description provided for @waitingForEvents.
  ///
  /// In en, this message translates to:
  /// **'Waiting for events…'**
  String get waitingForEvents;

  /// No description provided for @missionTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get missionTitle;
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
      <String>['ar', 'en', 'es'].contains(locale.languageCode);

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
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

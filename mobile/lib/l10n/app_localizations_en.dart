// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AppTrial';

  @override
  String get appTagline => 'Connect Android developers with trusted testers.';

  @override
  String get preparingApp => 'Preparing AppTrial…';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving…';

  @override
  String get create => 'Create';

  @override
  String get register => 'Register';

  @override
  String get back => 'Back';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorSomethingWentWrong => 'Something went wrong';

  @override
  String errorWithDetails(String details) {
    return 'Error: $details';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navExplore => 'Explore';

  @override
  String get navCampaigns => 'Campaigns';

  @override
  String get navMissions => 'Missions';

  @override
  String get navWallet => 'Wallet';

  @override
  String get navProfile => 'Profile';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to manage campaigns or join testing.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get passwordMinLength => 'At least 8 characters';

  @override
  String get loginErrorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get loginErrorEmailTaken => 'That email is already registered.';

  @override
  String get loginErrorBadRequest => 'Check your details and try again.';

  @override
  String get loginErrorNoConnection => 'Cannot reach the server.';

  @override
  String get loginErrorGeneric => 'Could not complete the operation.';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageArabic => 'العربية';

  @override
  String get currentLanguage => 'Current language';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle =>
      'Start publishing campaigns or testing apps in minutes.';

  @override
  String get displayName => 'Name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get roleDeveloperTitle => 'I am a developer';

  @override
  String get roleDeveloperSubtitle => 'I publish apps and testing campaigns';

  @override
  String get roleTesterTitle => 'I want to be a tester';

  @override
  String get roleTesterSubtitle => 'I join campaigns and earn TestCredits';

  @override
  String get selectAtLeastOneRole => 'Select at least one role';

  @override
  String get signUp => 'Sign up';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get quickActionsSubtitle => 'What you use most, one tap away';

  @override
  String get apps => 'Apps';

  @override
  String get groups => 'Groups';

  @override
  String get analytics => 'Analytics';

  @override
  String get feedback => 'Feedback';

  @override
  String get alerts => 'Alerts';

  @override
  String get admin => 'Admin';

  @override
  String get openCampaigns => 'Open campaigns';

  @override
  String get yourCampaigns => 'Your campaigns';

  @override
  String get openCampaignsSubtitle => 'Join and start testing';

  @override
  String get yourCampaignsSubtitle => 'Recruiting status and progress';

  @override
  String get nothingToExplore => 'Nothing to explore';

  @override
  String get noCampaignsYet => 'No campaigns yet';

  @override
  String get nothingToExploreMessage =>
      'When campaigns are recruiting, they will appear here.';

  @override
  String get noCampaignsYetMessage =>
      'Create your first campaign from the Campaigns tab.';

  @override
  String get buyCredits => 'Buy credits';

  @override
  String get testCredits => 'TestCredits';

  @override
  String reservedCredits(int count) {
    return 'Reserved: $count TC';
  }

  @override
  String get walletCouldNotLoad => 'Could not load wallet';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get exploreSubtitle => 'Open campaigns ready to join';

  @override
  String get searchCampaignsHint => 'Search by name or app';

  @override
  String get noResults => 'No results';

  @override
  String get noResultsMessage => 'No recruiting campaigns match that filter.';

  @override
  String get refresh => 'Refresh';

  @override
  String get join => 'Join';

  @override
  String joinedGroup(String name, int occupied, int target) {
    return 'Joined $name ($occupied/$target)';
  }

  @override
  String couldNotJoin(String details) {
    return 'Could not join: $details';
  }

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String seatsCount(int count) {
    return '$count seats';
  }

  @override
  String testersCount(int count) {
    return '$count testers';
  }

  @override
  String tcPerSeat(int count) {
    return '$count TC/seat';
  }

  @override
  String tcAmount(int count) {
    return '$count TC';
  }

  @override
  String get myCampaignsTitle => 'My campaigns';

  @override
  String get myCampaignsSubtitle => 'Drafts, recruiting and tracking';

  @override
  String get newCampaign => 'New campaign';

  @override
  String get stillNoCampaigns => 'You still have no campaigns';

  @override
  String get stillNoCampaignsMessage =>
      'Create a draft and publish it to start recruiting.';

  @override
  String get groupsTooltip => 'Groups';

  @override
  String get aiInsightsTooltip => 'AI insights';

  @override
  String get sseTooltip => 'SSE';

  @override
  String get publishTooltip => 'Publish';

  @override
  String get cancelTooltip => 'Cancel';

  @override
  String publishFailed(String details) {
    return 'Publish failed: $details';
  }

  @override
  String get registerAppFirst => 'Register an application first';

  @override
  String get newCampaignDialogTitle => 'New campaign';

  @override
  String get application => 'Application';

  @override
  String get name => 'Name';

  @override
  String get required => 'Required';

  @override
  String get description => 'Description';

  @override
  String get duration => 'Duration';

  @override
  String get duration7 => '7 days (12 TC/tester)';

  @override
  String get duration14 => '14 days (20 TC/tester)';

  @override
  String get duration30 => '30 days (30 TC/tester)';

  @override
  String get targetTestersLabel => 'Target testers (min. 12, default 15)';

  @override
  String get minimum12 => 'Minimum 12';

  @override
  String get createDraft => 'Create draft';

  @override
  String couldNotCreate(String details) {
    return 'Could not create: $details';
  }

  @override
  String get myApplications => 'My applications';

  @override
  String get noAppsYet => 'No apps yet';

  @override
  String get noAppsYetMessage =>
      'Register your first Android app to create campaigns.';

  @override
  String get archive => 'Archive';

  @override
  String get registerApplication => 'Register application';

  @override
  String get registerApplicationSubtitle =>
      'Add the Android app you want to test with real users.';

  @override
  String get sectionBasicInfo => 'Basic information';

  @override
  String get sectionBasicInfoHint => 'How the app appears to testers';

  @override
  String get sectionTechnical => 'Technical details';

  @override
  String get sectionTechnicalHint => 'Package and version used in Play';

  @override
  String get packageName => 'Package name';

  @override
  String get invalidPackage => 'Invalid package';

  @override
  String get version => 'Version';

  @override
  String couldNotCreateApp(String details) {
    return 'Could not create: $details';
  }

  @override
  String get preferences => 'Preferences';

  @override
  String get preferencesSubtitle =>
      'Language, notifications and developer tools';

  @override
  String get languageSection => 'Language';

  @override
  String get languageSectionSubtitle => 'Applies immediately across the app';

  @override
  String get notificationsSection => 'Push notifications';

  @override
  String get notificationsSectionSubtitle =>
      'Choose which events you want to receive';

  @override
  String get developerTools => 'Developer tools';

  @override
  String get registerMockFcm => 'Register mock FCM token';

  @override
  String get registerMockFcmSubtitle =>
      'Stores a development token in the backend (MOCK mode).';

  @override
  String tokenRegistered(String token) {
    return 'Token registered: $token';
  }

  @override
  String get preferencesSaved => 'Preferences saved';

  @override
  String get prefAll => 'All notifications';

  @override
  String get prefAllSubtitle => 'Master switch for push alerts';

  @override
  String get prefCampaignPublished => 'Campaign published';

  @override
  String get prefCampaignPublishedSubtitle =>
      'When your campaign starts recruiting';

  @override
  String get prefCampaignJoined => 'Tester joined';

  @override
  String get prefCampaignJoinedSubtitle => 'When someone joins a campaign';

  @override
  String get prefGroupReady => 'Group ready';

  @override
  String get prefGroupReadySubtitle => 'When a tester group is full';

  @override
  String get prefMissionApproved => 'Mission approved';

  @override
  String get prefMissionApprovedSubtitle => 'When a submission is approved';

  @override
  String get prefCreditsChanged => 'Credits changed';

  @override
  String get prefCreditsChangedSubtitle => 'Wallet balance updates';

  @override
  String get profile => 'Profile';

  @override
  String get emailVerified => 'Email verified';

  @override
  String get yes => 'Yes';

  @override
  String get pending => 'Pending';

  @override
  String get country => 'Country';

  @override
  String get localeLabel => 'Locale';

  @override
  String get settings => 'Settings';

  @override
  String get devices => 'Devices';

  @override
  String get notificationPreferences => 'Notification preferences';

  @override
  String get signOut => 'Sign out';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get walletSubtitle => 'Your TestCredits balance and history';

  @override
  String get history => 'History';

  @override
  String get historySubtitle => 'Every movement stays in the ledger';

  @override
  String get noMovements => 'No movements';

  @override
  String get noMovementsMessage =>
      'When you reserve, spend or buy credits they will appear here.';

  @override
  String get creditsDisclaimer =>
      'Credits are non-withdrawable and not convertible to real money. Purchases only via Google Play Billing.';

  @override
  String get buyCreditsTitle => 'Buy credits';

  @override
  String get billingDisclaimer =>
      'Digital payments only through Google Play Billing. The backend verifies the token before crediting TC.';

  @override
  String get packages => 'Packages';

  @override
  String get packagesSubtitle => 'Ideal for one-off campaigns';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get subscriptionsSubtitle => 'Free → Studio plans via Play';

  @override
  String get recommended => 'Recommended';

  @override
  String get simulatePlayPurchase => 'Simulate Play purchase';

  @override
  String purchaseVerified(String status, Object credited) {
    return 'Verified ($status): +$credited TC';
  }

  @override
  String purchaseFailed(String details) {
    return 'Purchase failed: $details';
  }

  @override
  String get missionsTitle => 'Missions';

  @override
  String get missionsSubtitle => 'Activities by campaign and your submissions';

  @override
  String get campaignsSection => 'Campaigns';

  @override
  String get noCampaignsAvailable => 'No campaigns';

  @override
  String get noCampaignsAvailableMessage =>
      'When you have campaigns, their missions will show here.';

  @override
  String get openMissions => 'Open missions';

  @override
  String get mySubmissions => 'My submissions';

  @override
  String get noSubmissions => 'No submissions';

  @override
  String get noSubmissionsMessage =>
      'Complete a mission to see review status here.';

  @override
  String get missionSubmission => 'Mission submission';

  @override
  String evidenceCount(int count) {
    return 'Evidence: $count';
  }

  @override
  String get myGroups => 'My groups';

  @override
  String get notInGroupYet => 'You are not in a group yet';

  @override
  String get notInGroupYetMessage =>
      'Explore open campaigns and join to get started.';

  @override
  String groupProgress(int occupied, int target, String status) {
    return '$occupied/$target seats · Your status: $status';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get leave => 'Leave';

  @override
  String get markActive => 'Mark active';

  @override
  String couldNotUpdate(String details) {
    return 'Could not update: $details';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get markAll => 'Mark all';

  @override
  String get inboxEmpty => 'Inbox empty';

  @override
  String get inboxEmptyMessage =>
      'When there are campaign or credit updates, you will see them here.';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get mySummary => 'My summary';

  @override
  String get mySummarySubtitle => 'Activity from your apps and campaigns';

  @override
  String get activeCampaigns => 'Active campaigns';

  @override
  String get seats => 'Seats';

  @override
  String get approved => 'Approved';

  @override
  String get credits => 'Credits';

  @override
  String get platform => 'Platform';

  @override
  String get platformSubtitle => 'Admin view';

  @override
  String get users => 'Users';

  @override
  String get developers => 'Developers';

  @override
  String get testers => 'Testers';

  @override
  String get applicationLabel => 'App';

  @override
  String get mission => 'Mission';

  @override
  String get noMissionsCreateFirst => 'No missions. Create the first one.';

  @override
  String get submit => 'Submit';

  @override
  String get review => 'Review';

  @override
  String get newMission => 'New mission';

  @override
  String get missionSubmitted => 'Mission submitted with evidence';

  @override
  String get noSubmissionsToReview => 'No submissions to review';

  @override
  String approvedWithReward(String id, Object reward) {
    return 'Approved $id (+$reward TC)';
  }

  @override
  String get noUsers => 'No users.';

  @override
  String get noFraudSignals => 'No fraud signals.';

  @override
  String get noAudit => 'No audit entries.';

  @override
  String get noClusters => 'No clusters';

  @override
  String get noVisibleMembers => 'No visible members';

  @override
  String get aiInsights => 'AI insights';

  @override
  String get campaignEvents => 'Live events';

  @override
  String get devicesTitle => 'Devices';

  @override
  String get registerDevice => 'Register device';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get newFeedback => 'New feedback';

  @override
  String get adminTitle => 'Administration';

  @override
  String get usersTab => 'Users';

  @override
  String get fraudTab => 'Fraud';

  @override
  String get auditTab => 'Audit';

  @override
  String get noGroupsForCampaign => 'This campaign has no groups yet.';

  @override
  String get noFeedbackYet => 'You have not sent feedback yet.';

  @override
  String get noDevicesYet => 'No devices registered yet.';

  @override
  String get fingerprint => 'Fingerprint';

  @override
  String get model => 'Model';

  @override
  String get manufacturer => 'Manufacturer';

  @override
  String get androidVersion => 'Android';

  @override
  String get suspend => 'Suspend';

  @override
  String get activate => 'Activate';

  @override
  String get adjustCreditsPlus10 => 'Adjust +10 TC';

  @override
  String modeLabel(String mode) {
    return 'Mode: $mode';
  }

  @override
  String get summary => 'Summary';

  @override
  String get clusters => 'Clusters';

  @override
  String get suggestedImprovements => 'Suggested improvements';

  @override
  String get reconnect => 'Reconnect';

  @override
  String get connectedLiveEvents => 'Connected to live events';

  @override
  String get connecting => 'Connecting…';

  @override
  String get waitingForEvents => 'Waiting for events…';

  @override
  String get missionTitle => 'Title';
}

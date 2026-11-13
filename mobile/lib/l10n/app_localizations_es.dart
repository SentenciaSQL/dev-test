// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'AppTrial';

  @override
  String get appTagline =>
      'Conecta desarrolladores Android con testers de confianza.';

  @override
  String get preparingApp => 'Preparando AppTrial…';

  @override
  String get loading => 'Cargando…';

  @override
  String get retry => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get saving => 'Guardando…';

  @override
  String get create => 'Crear';

  @override
  String get register => 'Registrar';

  @override
  String get back => 'Atrás';

  @override
  String get errorGeneric => 'Algo salió mal';

  @override
  String get errorSomethingWentWrong => 'Algo salió mal';

  @override
  String errorWithDetails(String details) {
    return 'Error: $details';
  }

  @override
  String get navHome => 'Inicio';

  @override
  String get navExplore => 'Explorar';

  @override
  String get navCampaigns => 'Campañas';

  @override
  String get navMissions => 'Misiones';

  @override
  String get navWallet => 'Wallet';

  @override
  String get navProfile => 'Perfil';

  @override
  String get loginTitle => 'Bienvenido de nuevo';

  @override
  String get loginSubtitle =>
      'Inicia sesión para gestionar campañas o unirte a pruebas.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get invalidEmail => 'Email inválido';

  @override
  String get passwordMinLength => 'Mínimo 8 caracteres';

  @override
  String get loginErrorInvalidCredentials => 'Email o contraseña incorrectos.';

  @override
  String get loginErrorEmailTaken => 'Ese email ya está registrado.';

  @override
  String get loginErrorBadRequest => 'Revisa los datos e inténtalo de nuevo.';

  @override
  String get loginErrorNoConnection => 'No hay conexión con el servidor.';

  @override
  String get loginErrorGeneric => 'No se pudo completar la operación.';

  @override
  String get language => 'Idioma';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageArabic => 'العربية';

  @override
  String get currentLanguage => 'Idioma actual';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get registerSubtitle =>
      'Empieza a publicar campañas o a probar apps en minutos.';

  @override
  String get displayName => 'Nombre';

  @override
  String get nameRequired => 'Nombre requerido';

  @override
  String get roleDeveloperTitle => 'Soy desarrollador';

  @override
  String get roleDeveloperSubtitle => 'Publico apps y campañas de testing';

  @override
  String get roleTesterTitle => 'Quiero ser tester';

  @override
  String get roleTesterSubtitle => 'Me uno a campañas y gano TestCredits';

  @override
  String get selectAtLeastOneRole => 'Selecciona al menos un rol';

  @override
  String get signUp => 'Registrarme';

  @override
  String get alreadyHaveAccount => 'Ya tengo cuenta';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String get quickActions => 'Accesos rápidos';

  @override
  String get quickActionsSubtitle => 'Lo que más usas, a un toque';

  @override
  String get apps => 'Apps';

  @override
  String get groups => 'Grupos';

  @override
  String get analytics => 'Analíticas';

  @override
  String get feedback => 'Feedback';

  @override
  String get alerts => 'Avisos';

  @override
  String get admin => 'Admin';

  @override
  String get openCampaigns => 'Campañas abiertas';

  @override
  String get yourCampaigns => 'Tus campañas';

  @override
  String get openCampaignsSubtitle => 'Únete y empieza a probar';

  @override
  String get yourCampaignsSubtitle => 'Estado de reclutamiento y progreso';

  @override
  String get nothingToExplore => 'Nada por explorar';

  @override
  String get noCampaignsYet => 'Sin campañas aún';

  @override
  String get nothingToExploreMessage =>
      'Cuando haya campañas en reclutamiento aparecerán aquí.';

  @override
  String get noCampaignsYetMessage =>
      'Crea tu primera campaña desde la pestaña Campañas.';

  @override
  String get buyCredits => 'Comprar créditos';

  @override
  String get testCredits => 'TestCredits';

  @override
  String reservedCredits(int count) {
    return 'Reservados: $count TC';
  }

  @override
  String get walletCouldNotLoad => 'No se pudo cargar el wallet';

  @override
  String get exploreTitle => 'Explorar';

  @override
  String get exploreSubtitle => 'Campañas abiertas listas para unirte';

  @override
  String get searchCampaignsHint => 'Buscar por nombre o app';

  @override
  String get noResults => 'Sin resultados';

  @override
  String get noResultsMessage =>
      'No hay campañas en reclutamiento con ese criterio.';

  @override
  String get refresh => 'Actualizar';

  @override
  String get join => 'Unirme';

  @override
  String joinedGroup(String name, int occupied, int target) {
    return 'Unido a $name ($occupied/$target)';
  }

  @override
  String couldNotJoin(String details) {
    return 'No se pudo unir: $details';
  }

  @override
  String daysCount(int count) {
    return '$count días';
  }

  @override
  String seatsCount(int count) {
    return '$count plazas';
  }

  @override
  String testersCount(int count) {
    return '$count testers';
  }

  @override
  String tcPerSeat(int count) {
    return '$count TC/plaza';
  }

  @override
  String tcAmount(int count) {
    return '$count TC';
  }

  @override
  String get myCampaignsTitle => 'Mis campañas';

  @override
  String get myCampaignsSubtitle => 'Borradores, reclutamiento y seguimiento';

  @override
  String get newCampaign => 'Nueva campaña';

  @override
  String get stillNoCampaigns => 'Aún no tienes campañas';

  @override
  String get stillNoCampaignsMessage =>
      'Crea un borrador y publícalo para empezar a reclutar.';

  @override
  String get groupsTooltip => 'Grupos';

  @override
  String get aiInsightsTooltip => 'AI insights';

  @override
  String get sseTooltip => 'SSE';

  @override
  String get publishTooltip => 'Publicar';

  @override
  String get cancelTooltip => 'Cancelar';

  @override
  String publishFailed(String details) {
    return 'Publicar falló: $details';
  }

  @override
  String get registerAppFirst => 'Registra una aplicación primero';

  @override
  String get newCampaignDialogTitle => 'Nueva campaña';

  @override
  String get application => 'Aplicación';

  @override
  String get name => 'Nombre';

  @override
  String get required => 'Requerido';

  @override
  String get description => 'Descripción';

  @override
  String get duration => 'Duración';

  @override
  String get duration7 => '7 días (12 TC/tester)';

  @override
  String get duration14 => '14 días (20 TC/tester)';

  @override
  String get duration30 => '30 días (30 TC/tester)';

  @override
  String get targetTestersLabel => 'Testers objetivo (mín. 12, default 15)';

  @override
  String get minimum12 => 'Mínimo 12';

  @override
  String get createDraft => 'Crear borrador';

  @override
  String couldNotCreate(String details) {
    return 'No se pudo crear: $details';
  }

  @override
  String get myApplications => 'Mis aplicaciones';

  @override
  String get noAppsYet => 'Sin apps todavía';

  @override
  String get noAppsYetMessage =>
      'Registra tu primera app Android para crear campañas.';

  @override
  String get archive => 'Archivar';

  @override
  String get registerApplication => 'Registrar aplicación';

  @override
  String get registerApplicationSubtitle =>
      'Añade la app Android que quieres probar con usuarios reales.';

  @override
  String get sectionBasicInfo => 'Información básica';

  @override
  String get sectionBasicInfoHint => 'Cómo verán la app los testers';

  @override
  String get sectionTechnical => 'Detalles técnicos';

  @override
  String get sectionTechnicalHint => 'Package y versión usados en Play';

  @override
  String get packageName => 'Package name';

  @override
  String get invalidPackage => 'Package inválido';

  @override
  String get version => 'Versión';

  @override
  String couldNotCreateApp(String details) {
    return 'No se pudo crear: $details';
  }

  @override
  String get preferences => 'Preferencias';

  @override
  String get preferencesSubtitle => 'Idioma, notificaciones y herramientas';

  @override
  String get languageSection => 'Idioma';

  @override
  String get languageSectionSubtitle => 'Se aplica de inmediato en toda la app';

  @override
  String get notificationsSection => 'Notificaciones push';

  @override
  String get notificationsSectionSubtitle =>
      'Elige qué eventos quieres recibir';

  @override
  String get developerTools => 'Herramientas de desarrollo';

  @override
  String get registerMockFcm => 'Registrar token mock FCM';

  @override
  String get registerMockFcmSubtitle =>
      'Guarda un token de desarrollo en el backend (modo MOCK).';

  @override
  String tokenRegistered(String token) {
    return 'Token registrado: $token';
  }

  @override
  String get preferencesSaved => 'Preferencias guardadas';

  @override
  String get prefAll => 'Todas las notificaciones';

  @override
  String get prefAllSubtitle => 'Interruptor general de alertas push';

  @override
  String get prefCampaignPublished => 'Campaña publicada';

  @override
  String get prefCampaignPublishedSubtitle =>
      'Cuando tu campaña empieza a reclutar';

  @override
  String get prefCampaignJoined => 'Tester unido';

  @override
  String get prefCampaignJoinedSubtitle =>
      'Cuando alguien se une a una campaña';

  @override
  String get prefGroupReady => 'Grupo listo';

  @override
  String get prefGroupReadySubtitle => 'Cuando un grupo de testers se completa';

  @override
  String get prefMissionApproved => 'Misión aprobada';

  @override
  String get prefMissionApprovedSubtitle => 'Cuando se aprueba un envío';

  @override
  String get prefCreditsChanged => 'Créditos actualizados';

  @override
  String get prefCreditsChangedSubtitle => 'Cambios en el saldo del wallet';

  @override
  String get profile => 'Perfil';

  @override
  String get emailVerified => 'Email verificado';

  @override
  String get yes => 'Sí';

  @override
  String get pending => 'Pendiente';

  @override
  String get country => 'País';

  @override
  String get localeLabel => 'Idioma';

  @override
  String get settings => 'Configuración';

  @override
  String get devices => 'Dispositivos';

  @override
  String get notificationPreferences => 'Preferencias de notificación';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get walletSubtitle => 'Tu saldo de TestCredits y movimientos';

  @override
  String get history => 'Historial';

  @override
  String get historySubtitle => 'Cada movimiento queda en el ledger';

  @override
  String get noMovements => 'Sin movimientos';

  @override
  String get noMovementsMessage =>
      'Cuando reserves, gastes o compres créditos aparecerán aquí.';

  @override
  String get creditsDisclaimer =>
      'Los créditos no son retirables ni convertibles a dinero real. Compras solo vía Google Play Billing.';

  @override
  String get buyCreditsTitle => 'Comprar créditos';

  @override
  String get billingDisclaimer =>
      'Pagos digitales solo con Google Play Billing. El backend verifica el token antes de acreditar TC.';

  @override
  String get packages => 'Paquetes';

  @override
  String get packagesSubtitle => 'Ideal para campañas puntuales';

  @override
  String get subscriptions => 'Suscripciones';

  @override
  String get subscriptionsSubtitle => 'Planes Free → Studio vía Play';

  @override
  String get recommended => 'Recomendado';

  @override
  String get simulatePlayPurchase => 'Simular compra Play';

  @override
  String purchaseVerified(String status, Object credited) {
    return 'Verificado ($status): +$credited TC';
  }

  @override
  String purchaseFailed(String details) {
    return 'Compra falló: $details';
  }

  @override
  String get missionsTitle => 'Misiones';

  @override
  String get missionsSubtitle => 'Actividades por campaña y tus envíos';

  @override
  String get campaignsSection => 'Campañas';

  @override
  String get noCampaignsAvailable => 'Sin campañas';

  @override
  String get noCampaignsAvailableMessage =>
      'Cuando tengas campañas verás sus misiones aquí.';

  @override
  String get openMissions => 'Abrir misiones';

  @override
  String get mySubmissions => 'Mis envíos';

  @override
  String get noSubmissions => 'Sin envíos';

  @override
  String get noSubmissionsMessage =>
      'Completa una misión para ver el estado de revisión aquí.';

  @override
  String get missionSubmission => 'Envío de misión';

  @override
  String evidenceCount(int count) {
    return 'Evidencias: $count';
  }

  @override
  String get myGroups => 'Mis grupos';

  @override
  String get notInGroupYet => 'Todavía no estás en un grupo';

  @override
  String get notInGroupYetMessage =>
      'Explora campañas abiertas y únete para empezar.';

  @override
  String groupProgress(int occupied, int target, String status) {
    return '$occupied/$target plazas · Tu estado: $status';
  }

  @override
  String get confirm => 'Confirmar';

  @override
  String get leave => 'Abandonar';

  @override
  String get markActive => 'Marcar activo';

  @override
  String couldNotUpdate(String details) {
    return 'No se pudo actualizar: $details';
  }

  @override
  String get notifications => 'Notificaciones';

  @override
  String get markAll => 'Marcar todas';

  @override
  String get inboxEmpty => 'Bandeja vacía';

  @override
  String get inboxEmptyMessage =>
      'Cuando haya novedades de campañas o créditos, las verás aquí.';

  @override
  String get analyticsTitle => 'Analíticas';

  @override
  String get mySummary => 'Mi resumen';

  @override
  String get mySummarySubtitle => 'Actividad de tus apps y campañas';

  @override
  String get activeCampaigns => 'Campañas activas';

  @override
  String get seats => 'Plazas';

  @override
  String get approved => 'Aprobados';

  @override
  String get credits => 'Créditos';

  @override
  String get platform => 'Plataforma';

  @override
  String get platformSubtitle => 'Vista admin';

  @override
  String get users => 'Usuarios';

  @override
  String get developers => 'Developers';

  @override
  String get testers => 'Testers';

  @override
  String get applicationLabel => 'App';

  @override
  String get mission => 'Misión';

  @override
  String get noMissionsCreateFirst => 'Sin misiones. Crea la primera.';

  @override
  String get submit => 'Enviar';

  @override
  String get review => 'Revisar';

  @override
  String get newMission => 'Nueva misión';

  @override
  String get missionSubmitted => 'Misión enviada con evidencia';

  @override
  String get noSubmissionsToReview => 'Sin envíos para revisar';

  @override
  String approvedWithReward(String id, Object reward) {
    return 'Aprobado $id (+$reward TC)';
  }

  @override
  String get noUsers => 'Sin usuarios.';

  @override
  String get noFraudSignals => 'Sin señales de fraude.';

  @override
  String get noAudit => 'Sin auditoría.';

  @override
  String get noClusters => 'Sin clusters';

  @override
  String get noVisibleMembers => 'Sin miembros visibles';

  @override
  String get aiInsights => 'AI insights';

  @override
  String get campaignEvents => 'Eventos en vivo';

  @override
  String get devicesTitle => 'Dispositivos';

  @override
  String get registerDevice => 'Registrar dispositivo';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get newFeedback => 'Nuevo feedback';

  @override
  String get adminTitle => 'Administración';

  @override
  String get usersTab => 'Usuarios';

  @override
  String get fraudTab => 'Fraude';

  @override
  String get auditTab => 'Auditoría';

  @override
  String get noGroupsForCampaign => 'Esta campaña aún no tiene grupos.';

  @override
  String get noFeedbackYet => 'Aún no has enviado feedback.';

  @override
  String get noDevicesYet => 'Aún no hay dispositivos registrados.';

  @override
  String get fingerprint => 'Fingerprint';

  @override
  String get model => 'Modelo';

  @override
  String get manufacturer => 'Fabricante';

  @override
  String get androidVersion => 'Android';

  @override
  String get suspend => 'Suspender';

  @override
  String get activate => 'Activar';

  @override
  String get adjustCreditsPlus10 => 'Ajustar +10 TC';

  @override
  String modeLabel(String mode) {
    return 'Modo: $mode';
  }

  @override
  String get summary => 'Resumen';

  @override
  String get clusters => 'Clusters';

  @override
  String get suggestedImprovements => 'Mejoras sugeridas';

  @override
  String get reconnect => 'Reconectar';

  @override
  String get connectedLiveEvents => 'Conectado a eventos en vivo';

  @override
  String get connecting => 'Conectando…';

  @override
  String get waitingForEvents => 'Esperando eventos…';

  @override
  String get missionTitle => 'Título';
}

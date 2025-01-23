import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injector/injector.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:sona/ui/widgets/menstrual_cycle/menstrual_cycle.dart';

final injector = Injector.appInstance;
const credentialsKey = 'credentials';

Future<void> setupDependencies() async {
  //SECURITY
  final storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_CBC_PKCS7Padding,
    ),
  );
  var credentials = await storage.read(key: credentialsKey);
  final localeProvider = SystemLocaleProvider();
  localeProvider.locale = "es";
  final authProvider = KeycloakAuthProvider(
    storage: storage,
    credentialsKey: credentialsKey,
    credentials: credentials != null ? oauth2.Credentials.fromJson(credentials) : null,
  );

  injector.registerSingleton<FlutterSecureStorage>(() => storage);
  injector.registerSingleton<LocaleProvider>(() => localeProvider);
  injector.registerSingleton<AuthProvider>(() => authProvider);

  //Services
  final userService = ApiUserService(authProvider: authProvider, localeProvider: localeProvider);
  final notificationService = ApiNotificationService(authProvider: authProvider, localeProvider: localeProvider);
  if (await authProvider.isAuthenticated()) {
    await userService.refreshCurrentUser();
    await notificationService.suscribe();
  }
  authProvider.addLogoutListener(NotificationScheduler.clear);
  authProvider.addLogoutListener(notificationService.unsuscribe);
  authProvider.addLoginListener(notificationService.suscribe);

  injector.registerSingleton<UserService>(() => userService);
  injector.registerSingleton<NotificationService>(() => notificationService);
  injector.registerSingleton<MenstrualCycleService>(() => MenstrualCycleServiceImpl(authProvider: authProvider, localeProvider: localeProvider, userService: userService));
  injector.registerSingleton<ChatService>(() => ApiStompChatService(authProvider: authProvider, localeProvider: localeProvider, userService: userService));
  injector.registerSingleton<ChatBotService>(() => ApiChatBotService(authProvider: authProvider, localeProvider: localeProvider));
  injector.registerSingleton<TipService>(() => ApiTipService(authProvider: authProvider, localeProvider: localeProvider));
  injector.registerSingleton<PostService>(() => ApiPostService(authProvider: authProvider, localeProvider: localeProvider));
  injector.registerSingleton<DidacticContentService>(() => ApiDidacticContentService(authProvider: authProvider, localeProvider: localeProvider));
  injector.registerSingleton<AppointmentService>(() => ApiAppointmentService(authProvider: authProvider, localeProvider: localeProvider));
  injector.registerSingleton<ProfessionalScheduleService>(() => ApiProfessionalScheduleService(authProvider: authProvider, localeProvider: localeProvider));

  var authGuard = AuthGuard(authProvider: authProvider);
  injector.registerSingleton<AuthGuard>(() => authGuard);
  injector.registerSingleton<AppRouter>(() => AppRouter(guards: [authGuard]));
}

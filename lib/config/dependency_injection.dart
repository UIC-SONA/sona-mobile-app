import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injector/injector.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

final injector = Injector.appInstance;
const credentialsKey = 'credentials';

Future<void> setupDependencies() async {
  //SECURITY
  injector.registerSingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_CBC_PKCS7Padding,
      ),
    ),
  );

  final storage = injector.get<FlutterSecureStorage>();
  var credentials = await storage.read(key: credentialsKey);

  //Providers
  injector.registerSingleton<LocaleProvider>(() => SystemLocaleProvider());
  injector.registerSingleton<AuthProvider>(() => KeycloakAuthProvider(storage: storage, credentialsKey: credentialsKey, credentials: credentials != null ? oauth2.Credentials.fromJson(credentials) : null));

  final localeProvider = injector.get<LocaleProvider>();
  final authProvider = injector.get<AuthProvider>();

//Services
  injector.registerSingleton<UserService>(() => ApiUserService(authProvider: authProvider, localeProvider: localeProvider));
  final userService = injector.get<UserService>();

  if (await authProvider.isAuthenticated()) {
    await userService.refreshCurrentUser();
  }

  injector.registerSingleton<ChatService>(() => ApiStompChatService(authProvider: authProvider, localeProvider: localeProvider, userService: userService));
  injector.registerSingleton<ChatBotService>(() => ApiChatBotService(authProvider: authProvider, localeProvider: localeProvider));
  injector.registerSingleton<TipService>(() => ApiTipService(authProvider: authProvider, localeProvider: localeProvider));
  injector.registerSingleton<PostService>(() => ApiPostService(authProvider: authProvider, localeProvider: localeProvider));
  injector.registerSingleton<MenstrualCalendarService>(() => ApiMenstrualCalendarService(authProvider: authProvider, localeProvider: localeProvider));

//Router
  injector.registerSingleton<AuthGuard>(() => AuthGuard(authProvider: authProvider));
  injector.registerSingleton<AppRouter>(() => AppRouter(guards: [injector.get<AuthGuard>()]));
}

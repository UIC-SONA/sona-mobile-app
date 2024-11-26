import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injector/injector.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/ui/pages/routing/router.dart';

final injector = Injector.appInstance;

void setupDependencies() {
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

  //Providers
  injector.registerSingleton<AuthProvider>(() => KeycloakAuthProvider(storage: injector.get<FlutterSecureStorage>()));

  var authProvider = injector.get<AuthProvider>();

  //Services
  injector.registerSingleton<ChatService>(() => ApiChatService(authProvider: authProvider));
  injector.registerSingleton<ChatBotService>(() => ApiChatBotService(authProvider: authProvider));
  injector.registerSingleton<TipService>(() => ApiTipService(authProvider: authProvider));
  injector.registerSingleton<UserService>(() => ApiUserService(authProvider: authProvider));

  //Router
  injector.registerSingleton<AuthGuard>(() => AuthGuard(authProvider: authProvider));
  injector.registerSingleton<AppRouter>(() => AppRouter(guards: [injector.get<AuthGuard>()]));
}

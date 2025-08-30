import 'dart:ui';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/providers/locale.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:sona/ui/widgets/menstrual_cycle/menstrual_cycle.dart';

final injector = Injector.appInstance;
const credentialsKey = 'credentials';

Future<void> setupDependencies() async {
  injector.registerSingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
        storageCipherAlgorithm: StorageCipherAlgorithm.AES_CBC_PKCS7Padding,
      ),
    ),
  );

  injector.registerSingleton<LocaleProvider>(() {
    final localeProvider = SystemLocaleProvider();
    final locale = PlatformDispatcher.instance.locale;
    localeProvider.locale = locale.toString();
    return localeProvider;
  });
  injector.registerSingleton<AuthProvider>(() {
    final storage = injector.get<FlutterSecureStorage>();
    return KeycloakAuthProvider(
      saveCredentials: (credentials) async => await storage.write(
        key: credentialsKey,
        value: credentials.toJson(),
      ),
      deleteCredentials: () async => await storage.delete(key: credentialsKey),
    );
  });
  injector.registerSingleton<UserService>(
    () => ApiUserService(
      authProvider: injector.get<AuthProvider>(),
      localeProvider: injector.get<LocaleProvider>(),
    ),
  );
  injector.registerSingleton<NotificationService>(
    () => ApiNotificationService(
      authProvider: injector.get<AuthProvider>(),
      localeProvider: injector.get<LocaleProvider>(),
    ),
  );
  injector.registerSingleton<MenstrualCycleService>(
    () => MenstrualCycleServiceImpl(
      authProvider: injector.get<AuthProvider>(),
      localeProvider: injector.get<LocaleProvider>(),
      userService: injector.get<UserService>(),
    ),
  );
  injector.registerSingleton<ChatService>(
    () => ApiStompChatService(
      authProvider: injector.get<AuthProvider>(),
      localeProvider: injector.get<LocaleProvider>(),
      userService: injector.get<UserService>(),
    ),
  );
  injector.registerSingleton<ChatBotService>(
    () => ApiChatBotService(
      authProvider: injector.get<AuthProvider>(),
      localeProvider: injector.get<LocaleProvider>(),
    ),
  );
  injector.registerSingleton<TipService>(
    () => ApiTipService(
      authProvider: injector.get<AuthProvider>(),
      localeProvider: injector.get<LocaleProvider>(),
    ),
  );
  injector.registerSingleton<PostService>(
    () => ApiPostService(
      authProvider: injector.get<AuthProvider>(),
      localeProvider: injector.get<LocaleProvider>(),
    ),
  );
  injector.registerSingleton<DidacticContentService>(
    () => ApiDidacticContentService(
      authProvider: injector.get<AuthProvider>(),
      localeProvider: injector.get<LocaleProvider>(),
    ),
  );
  injector.registerSingleton<AppointmentService>(
    () => ApiAppointmentService(
      authProvider: injector.get<AuthProvider>(),
      localeProvider: injector.get<LocaleProvider>(),
    ),
  );
  injector.registerSingleton<ProfessionalScheduleService>(
    () => ApiProfessionalScheduleService(
      authProvider: injector.get<AuthProvider>(),
      localeProvider: injector.get<LocaleProvider>(),
    ),
  );

  injector.registerSingleton<AuthGuard>(
    () => AuthGuard(
      authProvider: injector.get<AuthProvider>(),
    ),
  );
  injector.registerSingleton<AppRouter>(
    () => AppRouter(
      guards: [injector.get<AuthGuard>()],
    ),
  );

  await _configure();
}

Future<void> _configure() async {
  final storage = injector.get<FlutterSecureStorage>();
  final credentials = await storage.read(key: credentialsKey);

  final authProvider = injector.get<AuthProvider>();

  if (credentials != null) {
    final oauth2Credentials = oauth2.Credentials.fromJson(credentials);
    await authProvider.useCredentials(oauth2Credentials);
  }

  final userService = injector.get<UserService>();
  final notificationService = injector.get<NotificationService>();

  if (await authProvider.isAuthenticated()) {
    await userService.refreshCurrentUser();
    await notificationService.suscribe();
  }
  authProvider.addLogoutListener(CalendarNotificationScheduler.clear);
  authProvider.addLogoutListener(notificationService.unsuscribe);
  authProvider.addLoginListener(notificationService.suscribe);
}

import 'dart:io';

import 'package:chatview/chatview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/config/json_codecs.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/firebase_options.dart';
import 'package:sona/local_notifications.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/theme/theme.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    print("App started in debug mode");
  }
  final bool connected = await hasInternetConnection();
  if (!connected) {
    if (kDebugMode) {
      print("No internet connection");
    }
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Text(
              'No hay conexión a internet.\nPor favor, verifica tu conexión e intenta de nuevo.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
    return;
  }
  await dotenv.load(fileName: ".env");
  await LocalNotifications.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  PackageStrings.addLocaleObject(
    'es',
    const ChatViewLocale(
      today: 'Hoy',
      yesterday: 'Ayer',
      repliedToYou: 'Te respondió',
      repliedBy: 'Respondido por',
      more: 'Más',
      unsend: 'Desenviar',
      reply: 'Responder',
      replyTo: 'Responder a',
      message: 'Mensaje',
      reactionPopupTitle: 'Mantén presionado para multiplicar tu reacción',
      photo: 'Foto',
      send: 'Enviar',
      you: 'Tú',
      report: 'Reportar',
      noMessage: 'No hay mensajes',
      somethingWentWrong: 'Algo salió mal',
      reload: 'Recargar',
    ),
  );
  PackageStrings.setLocale('es');

  tz.initializeTimeZones();
  setupJsonCodecs();
  //
  await setupDependencies();
  runApp(SonaApp());
}

Future<bool> hasInternetConnection() async {
  // Primero revisa si hay red activa (wifi/datos)
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult.contains(ConnectivityResult.none)) {
    return false;
  }

  // Luego valida conexión real con un lookup DNS
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
      return true;
    }
  } catch (_) {
    return false;
  }

  return false;
}

class SonaApp extends StatelessWidget {
  final appRouter = injector.get<AppRouter>();

  SonaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter.config(),
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          GlobalWidgetsLocalizations.delegate,
          FormBuilderLocalizations.delegate
        ],
        supportedLocales: const [
          Locale('es'),
          Locale('en')
        ],
        locale: const Locale('es'),
        title: 'SONA',
        theme: theme,
        builder: (context, child) => Initializer(child: child!)
    );
  }
}

class Initializer extends StatefulWidget {
  final Widget child;

  const Initializer({
    required this.child,
    super.key
  });

  @override
  State<Initializer> createState() => _InitializerState();
}

class _InitializerState extends State<Initializer> {
  final notificationService = injector.get<NotificationService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onAppReady();
    });
  }

  void _onAppReady() {
    notificationService.listen((message) {
      try {
        if (message == null) return;
        if (kDebugMode) {
          print("Notification receive: $message");
        }
      } catch (e) {
        showAlertErrorDialog(context, error: e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

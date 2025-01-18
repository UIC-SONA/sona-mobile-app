import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/config/json_codecs.dart';
import 'package:sona/domain/services/firebase_service.dart';
import 'package:sona/firebase_options.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/theme/theme.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupJsonCodecs();
  await setupDependencies();
  runApp(SonaApp());
}

class SonaApp extends StatelessWidget {
  final appRouter = injector.get<AppRouter>();

  SonaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter.config(),
      localizationsDelegates: const [
        ...GlobalMaterialLocalizations.delegates,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
      locale: const Locale('es'),
      title: 'SONA',
      theme: theme,
      builder: (context, child) => AppInitializer(child: child!),
    );
  }
}

class AppInitializer extends StatefulWidget {
  final Widget child;

  const AppInitializer({required this.child, super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  final firbaseService = injector.get<FirebaseService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onAppReady();
    });
  }

  void _onAppReady() {
    firbaseService.initPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/config/json_codecs.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/theme/theme.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  setupJsonCodecs();
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  MenstrualCycleWidget.init(secretKey: "ready", ivKey: "ready");
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await setupDependencies();
  runApp(SonaApp());
}

class SonaApp extends StatelessWidget {
  late final _appRouter = injector.get<AppRouter>();

  SonaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _appRouter.config(),
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
    );
  }
}

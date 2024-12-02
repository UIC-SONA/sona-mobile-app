import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/config/json_codecs.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/theme/theme.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  setupJsonCodecs();
  setupDependencies();
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(SonaApp());
}

class SonaApp extends StatelessWidget {
  late final _appRouter = injector.get<AppRouter>();

  SonaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _appRouter.config(),
      title: 'SONA',
      theme: theme,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sona/application/common/json/init.dart';
import 'package:sona/application/navigation/routing/routing.dart';
import 'package:sona/application/theme/theme.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  await registerJsonCodecs();
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const SonaApp());
}

class SonaApp extends StatelessWidget {
  const SonaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SONA',
      theme: theme,
      initialRoute: initialRoute,
      routes: routes,
    );
  }
}

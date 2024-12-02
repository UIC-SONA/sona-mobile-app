
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:logger/logger.dart';
import 'package:sona/ui/pages/routing/router.dart';

final _log = Logger();

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _log.t("Mounted splash screen");
    super.initState();
    _removeNativeSplash();
  }

  Future<void> _removeNativeSplash() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    _log.t("Removing native splash");
    AutoRouter.of(context).replace(const HomeRoute()); // Cambiado aquí
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

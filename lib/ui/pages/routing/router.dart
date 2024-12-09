import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/ui/pages/chat_room_screen.dart';
import 'package:sona/ui/pages/navigation/home_screen.dart';
import 'package:sona/ui/pages/navigation/login_screen.dart';
import 'package:sona/ui/pages/navigation/menu_options_screen.dart';
import 'package:sona/ui/pages/navigation/sign_up_screen.dart';
import 'package:sona/ui/pages/navigation/services_options_screen.dart';
import 'package:sona/ui/pages/navigation/splash_screen.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/ui/pages/chat_screen.dart';
import 'package:sona/ui/pages/chat_bot_screen.dart';
import 'package:sona/ui/pages/menstrual_calendar_screens.dart';
import 'package:sona/ui/pages/tips_screen.dart';

part 'router.gr.dart';


final _log = Logger();

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  //
  final List<AutoRouteGuard> _guards;

  AppRouter({
    List<AutoRouteGuard>? guards,
  }) : _guards = guards ?? [];

  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: "/", page: SplashRoute.page, initial: true),
        AutoRoute(path: "/login", page: LoginRoute.page),
        AutoRoute(path: "/home", page: HomeRoute.page),
        AutoRoute(path: "/register", page: SignUpRoute.page),
        AutoRoute(path: "/menstrual", page: MenstrualCalendarRoute.page),
        AutoRoute(path: "/options", page: MenuOptionsRoute.page),
        AutoRoute(path: "/services", page: ServicesOptionsRoute.page),
        AutoRoute(path: "/chatbot", page: ChatBotRoute.page),
        AutoRoute(path: "/tips", page: TipsRoute.page),
        AutoRoute(path: "/chat", page: ChatRoute.page),
        AutoRoute(path: "/chat-room", page: ChatRoomRoute.page),
      ];

  @override
  List<AutoRouteGuard> get guards => _guards;
}


final List<String> unauthenticatedRoutes = [LoginRoute.name, SignUpRoute.name];

class AuthGuard extends AutoRouteGuard {
  final AuthProvider authProvider;
  final Duration authCacheDuration; // Duración para el caché
  DateTime? _lastAuthCheckTime; // Última vez que se validó la autenticación
  bool? _cachedIsAuthenticated; // Estado autenticado en caché

  AuthGuard({
    required this.authProvider,
    this.authCacheDuration = const Duration(minutes: 5), // Por defecto, 5 minutos
  }) {
    authProvider.addLogoutListener(() => _cachedIsAuthenticated = false);
    authProvider.addLoginListener(() => _cachedIsAuthenticated = true);
  }

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final currentRouteName = resolver.route.name;

    _log.t('Navigation to $currentRouteName, cached auth: $_cachedIsAuthenticated');

    if (_cachedIsAuthenticated == null || _lastAuthCheckTime == null || DateTime.now().difference(_lastAuthCheckTime!) > authCacheDuration) {
      try {
        _cachedIsAuthenticated = await authProvider.isAutheticated();
      } catch (e) {
        _log.e('Error checking authentication: $e');
        _cachedIsAuthenticated = false;
      }
      _lastAuthCheckTime = DateTime.now();
    }

    final isAuthenticated = _cachedIsAuthenticated!;

    if (currentRouteName == SplashRoute.name) {
      resolver.next(true);
      return;
    }

    if (isAuthenticated) {
      if (unauthenticatedRoutes.contains(currentRouteName)) {
        resolver.redirect(const HomeRoute());
      } else {
        resolver.next(true);
      }
    } else {
      if (unauthenticatedRoutes.contains(currentRouteName)) {
        resolver.next(true);
      } else {
        resolver.redirect(const LoginRoute());
      }
    }
  }
}

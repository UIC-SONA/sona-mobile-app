import 'package:auto_route/auto_route.dart';
import 'package:logger/logger.dart';
import 'package:sona/ui/pages/navigation/home.dart';
import 'package:sona/ui/pages/navigation/login.dart';
import 'package:sona/ui/pages/navigation/menu_options.dart';
import 'package:sona/ui/pages/navigation/signup.dart';
import 'package:sona/ui/pages/navigation/services_options.dart';
import 'package:sona/ui/pages/navigation/splash.dart';
import 'package:sona/domain/services/auth.dart';
import 'package:sona/ui/pages/chat_screen.dart';
import 'package:sona/ui/pages/chat_bot_screens.dart';
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
      ];

  @override
  List<AutoRouteGuard> get guards => _guards;
}

final List<String> unauthenticatedRoutes = [LoginRoute.name, SignUpRoute.name];

class AuthGuard extends AutoRouteGuard {
  final AuthProvider authProvider;

  AuthGuard({required this.authProvider});

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final isAuthenticated = await authProvider.isAutheticated();
    final currentRouteName = resolver.route.name;

    _log.t('Navigation to ${resolver.route.name}, isAuthenticated: $isAuthenticated');

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

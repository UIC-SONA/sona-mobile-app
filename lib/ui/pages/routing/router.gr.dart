// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [ChatBotScreen]
class ChatBotRoute extends PageRouteInfo<void> {
  const ChatBotRoute({List<PageRouteInfo>? children})
      : super(
          ChatBotRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChatBotRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChatBotScreen();
    },
  );
}

/// generated route for
/// [ChatRoomScreen]
class ChatRoomRoute extends PageRouteInfo<ChatRoomRouteArgs> {
  ChatRoomRoute({
    Key? key,
    required User profile,
    required ChatRoomData roomData,
    List<PageRouteInfo>? children,
  }) : super(
          ChatRoomRoute.name,
          args: ChatRoomRouteArgs(
            key: key,
            profile: profile,
            roomData: roomData,
          ),
          initialChildren: children,
        );

  static const String name = 'ChatRoomRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatRoomRouteArgs>();
      return ChatRoomScreen(
        key: args.key,
        profile: args.profile,
        roomData: args.roomData,
      );
    },
  );
}

class ChatRoomRouteArgs {
  const ChatRoomRouteArgs({
    this.key,
    required this.profile,
    required this.roomData,
  });

  final Key? key;

  final User profile;

  final ChatRoomData roomData;

  @override
  String toString() {
    return 'ChatRoomRouteArgs{key: $key, profile: $profile, roomData: $roomData}';
  }
}

/// generated route for
/// [ChatScreen]
class ChatRoute extends PageRouteInfo<void> {
  const ChatRoute({List<PageRouteInfo>? children})
      : super(
          ChatRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChatScreen();
    },
  );
}

/// generated route for
/// [ForumNewPostScreen]
class ForumNewPostRoute extends PageRouteInfo<void> {
  const ForumNewPostRoute({List<PageRouteInfo>? children})
      : super(
          ForumNewPostRoute.name,
          initialChildren: children,
        );

  static const String name = 'ForumNewPostRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForumNewPostScreen();
    },
  );
}

/// generated route for
/// [ForumPostScreen]
class ForumPostRoute extends PageRouteInfo<ForumPostRouteArgs> {
  ForumPostRoute({
    Key? key,
    required ValueNotifier<Post> notifier,
    List<PageRouteInfo>? children,
  }) : super(
          ForumPostRoute.name,
          args: ForumPostRouteArgs(
            key: key,
            notifier: notifier,
          ),
          initialChildren: children,
        );

  static const String name = 'ForumPostRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ForumPostRouteArgs>();
      return ForumPostScreen(
        key: args.key,
        notifier: args.notifier,
      );
    },
  );
}

class ForumPostRouteArgs {
  const ForumPostRouteArgs({
    this.key,
    required this.notifier,
  });

  final Key? key;

  final ValueNotifier<Post> notifier;

  @override
  String toString() {
    return 'ForumPostRouteArgs{key: $key, notifier: $notifier}';
  }
}

/// generated route for
/// [ForumScreen]
class ForumRoute extends PageRouteInfo<void> {
  const ForumRoute({List<PageRouteInfo>? children})
      : super(
          ForumRoute.name,
          initialChildren: children,
        );

  static const String name = 'ForumRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForumScreen();
    },
  );
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [MenstrualCalendarScreen]
class MenstrualCalendarRoute extends PageRouteInfo<void> {
  const MenstrualCalendarRoute({List<PageRouteInfo>? children})
      : super(
          MenstrualCalendarRoute.name,
          initialChildren: children,
        );

  static const String name = 'MenstrualCalendarRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MenstrualCalendarScreen();
    },
  );
}

/// generated route for
/// [MenuOptionsScreen]
class MenuOptionsRoute extends PageRouteInfo<void> {
  const MenuOptionsRoute({List<PageRouteInfo>? children})
      : super(
          MenuOptionsRoute.name,
          initialChildren: children,
        );

  static const String name = 'MenuOptionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MenuOptionsScreen();
    },
  );
}

/// generated route for
/// [ServicesOptionsScreen]
class ServicesOptionsRoute extends PageRouteInfo<ServicesOptionsRouteArgs> {
  ServicesOptionsRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          ServicesOptionsRoute.name,
          args: ServicesOptionsRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'ServicesOptionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ServicesOptionsRouteArgs>(
          orElse: () => const ServicesOptionsRouteArgs());
      return ServicesOptionsScreen(key: args.key);
    },
  );
}

class ServicesOptionsRouteArgs {
  const ServicesOptionsRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'ServicesOptionsRouteArgs{key: $key}';
  }
}

/// generated route for
/// [SignUpScreen]
class SignUpRoute extends PageRouteInfo<void> {
  const SignUpRoute({List<PageRouteInfo>? children})
      : super(
          SignUpRoute.name,
          initialChildren: children,
        );

  static const String name = 'SignUpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignUpScreen();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [TipsScreen]
class TipsRoute extends PageRouteInfo<void> {
  const TipsRoute({List<PageRouteInfo>? children})
      : super(
          TipsRoute.name,
          initialChildren: children,
        );

  static const String name = 'TipsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TipsScreen();
    },
  );
}

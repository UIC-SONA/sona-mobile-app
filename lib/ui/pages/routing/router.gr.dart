// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [AppointmentMenuScreen]
class AppointmentMenuRoute extends PageRouteInfo<void> {
  const AppointmentMenuRoute({List<PageRouteInfo>? children})
      : super(
          AppointmentMenuRoute.name,
          initialChildren: children,
        );

  static const String name = 'AppointmentMenuRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AppointmentMenuScreen();
    },
  );
}

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
/// [DidacticContentScreen]
class DidacticContentRoute extends PageRouteInfo<void> {
  const DidacticContentRoute({List<PageRouteInfo>? children})
      : super(
          DidacticContentRoute.name,
          initialChildren: children,
        );

  static const String name = 'DidacticContentRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DidacticContentScreen();
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
/// [ForumPostCommentsScreen]
class ForumPostCommentsRoute extends PageRouteInfo<ForumPostCommentsRouteArgs> {
  ForumPostCommentsRoute({
    Key? key,
    required PostWithUser post,
    required void Function(PostWithUser) onPop,
    List<PageRouteInfo>? children,
  }) : super(
          ForumPostCommentsRoute.name,
          args: ForumPostCommentsRouteArgs(
            key: key,
            post: post,
            onPop: onPop,
          ),
          initialChildren: children,
        );

  static const String name = 'ForumPostCommentsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ForumPostCommentsRouteArgs>();
      return ForumPostCommentsScreen(
        key: args.key,
        post: args.post,
        onPop: args.onPop,
      );
    },
  );
}

class ForumPostCommentsRouteArgs {
  const ForumPostCommentsRouteArgs({
    this.key,
    required this.post,
    required this.onPop,
  });

  final Key? key;

  final PostWithUser post;

  final void Function(PostWithUser) onPop;

  @override
  String toString() {
    return 'ForumPostCommentsRouteArgs{key: $key, post: $post, onPop: $onPop}';
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
/// [MyAppointmentsScreen]
class MyAppointmentsRoute extends PageRouteInfo<void> {
  const MyAppointmentsRoute({List<PageRouteInfo>? children})
      : super(
          MyAppointmentsRoute.name,
          initialChildren: children,
        );

  static const String name = 'MyAppointmentsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MyAppointmentsScreen();
    },
  );
}

/// generated route for
/// [NewAppointmentScreen]
class NewAppointmentRoute extends PageRouteInfo<void> {
  const NewAppointmentRoute({List<PageRouteInfo>? children})
      : super(
          NewAppointmentRoute.name,
          initialChildren: children,
        );

  static const String name = 'NewAppointmentRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NewAppointmentScreen();
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

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [AboutUsScreen]
class AboutUsRoute extends PageRouteInfo<void> {
  const AboutUsRoute({List<PageRouteInfo>? children})
      : super(
          AboutUsRoute.name,
          initialChildren: children,
        );

  static const String name = 'AboutUsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AboutUsScreen();
    },
  );
}

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
/// [ChangePasswordScreen]
class ChangePasswordRoute extends PageRouteInfo<void> {
  const ChangePasswordRoute({List<PageRouteInfo>? children})
      : super(
          ChangePasswordRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChangePasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChangePasswordScreen();
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
    required ChatRoomUi roomData,
    List<PageRouteInfo>? children,
  }) : super(
          ChatRoomRoute.name,
          args: ChatRoomRouteArgs(
            key: key,
            chatRoom: roomData,
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
        chatRoom: args.chatRoom,
      );
    },
  );
}

class ChatRoomRouteArgs {
  const ChatRoomRouteArgs({
    this.key,
    required this.chatRoom,
  });

  final Key? key;

  final ChatRoomUi chatRoom;

  @override
  String toString() {
    return 'ChatRoomRouteArgs{key: $key, chatRoom: $chatRoom}';
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
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [ResetPasswordScreen]
class ResetPasswordRoute extends PageRouteInfo<void> {
  const ResetPasswordRoute({List<PageRouteInfo>? children})
      : super(
          ResetPasswordRoute.name,
          initialChildren: children,
        );

  static const String name = 'ResetPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ResetPasswordScreen();
    },
  );
}

/// generated route for
/// [SchedulePushScreen]
class SchedulePushRoute extends PageRouteInfo<void> {
  const SchedulePushRoute({List<PageRouteInfo>? children})
      : super(
          SchedulePushRoute.name,
          initialChildren: children,
        );

  static const String name = 'SchedulePushRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SchedulePushScreen();
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
      final args = data.argsAs<ServicesOptionsRouteArgs>(orElse: () => const ServicesOptionsRouteArgs());
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
/// [TipDetailsScreen]
class TipDetailsRoute extends PageRouteInfo<TipDetailsRouteArgs> {
  TipDetailsRoute({
    Key? key,
    required Tip tip,
    required ValueNotifier<Tip> notifier,
    List<PageRouteInfo>? children,
  }) : super(
          TipDetailsRoute.name,
          args: TipDetailsRouteArgs(
            key: key,
            tip: tip,
            notifier: notifier,
          ),
          initialChildren: children,
        );

  static const String name = 'TipDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TipDetailsRouteArgs>();
      return TipDetailsScreen(
        key: args.key,
        tip: args.tip,
        notifier: args.notifier,
      );
    },
  );
}

class TipDetailsRouteArgs {
  const TipDetailsRouteArgs({
    this.key,
    required this.tip,
    required this.notifier,
  });

  final Key? key;

  final Tip tip;

  final ValueNotifier<Tip> notifier;

  @override
  String toString() {
    return 'TipDetailsRouteArgs{key: $key, tip: $tip, notifier: $notifier}';
  }
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

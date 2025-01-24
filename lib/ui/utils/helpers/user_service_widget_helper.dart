import 'package:flutter/material.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/http/utils.dart';
import 'package:sona/ui/theme/colors.dart';

mixin UserServiceWidgetHelper {
  UserService get userService;

  static final _cachedUsers = <int, User>{};

  User get currentUser => userService.currentUser;

  @protected
  Future<User> findUser(int userId) async {
    if (_cachedUsers.containsKey(userId)) {
      final user = _cachedUsers[userId];
      if (user != null) return user;
    }

    return onNotFound<User>(
      fetch: () async {
        final user = await userService.find(userId);
        _cachedUsers[userId] = user;
        return user;
      },
      onNotFound: () => UserService.notFound,
    );
  }

  @protected
  Future<List<User>> findUsers(List<int> userIds) async {
    final users = await userService.findMany(userIds);
    for (final user in users) {
      _cachedUsers[user.id] = user;
    }
    return users;
  }

  Widget buildFutureUserPicture(int userId, {double radius = 20.0}) {
    return FutureBuilder(
      future: findUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: radius,
            child: Icon(Icons.person),
          );
        }
        if (snapshot.hasError) {
          return CircleAvatar(
            radius: radius,
            child: Icon(Icons.error),
          );
        }
        final user = snapshot.data as User;
        return buildUserAvatar(user, radius: radius);
      },
    );
  }

  Widget buildUserAvatar(User user, {double radius = 20.0}) {
    if (user.hasProfilePicture) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: userService.profilePicture(userId: user.id),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          gradient: bgGradientButton1,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Icon(Icons.person),
      ),
    );
  }

  @protected
  void clearUserCaches() {
    _cachedUsers.clear();
  }

  @protected
  Future<void> refreshCurrentUser() async {
    await userService.refreshCurrentUser();
  }

  Widget buildUserName(int userId) {
    return FutureBuilder(
      future: findUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Icon(Icons.person, color: Colors.black);
        }
        if (snapshot.hasError) {
          return const Icon(Icons.error, color: Colors.black);
        }
        final user = snapshot.data as User;
        return Text(
          user.username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}

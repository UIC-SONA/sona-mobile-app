import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/http/utils.dart';

mixin UserServiceWidgetHelper {
  UserService get userService;

  static final _cachedUsers = <int, User>{};
  static final _cachedProfilePictures = <int, ImageProvider<Object>>{};
  static final _usersWithoutProfilePictures = <int>{};

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

  Widget buildProfilePicture(int userId, {double radius = 15.0}) {
    if (!_cachedProfilePictures.containsKey(userId)) {
      _cachedProfilePictures[userId] = userService.profilePicture(userId: userId);
      if (kDebugMode) {
        print('Profile picture for user $userId not found in cache');
      }
    }
    if (_usersWithoutProfilePictures.contains(userId)) {
      return CircleAvatar(
        radius: radius,
        child: Icon(Icons.person, size: radius),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: _cachedProfilePictures[userId],
      child: _cachedProfilePictures[userId] == null ? Icon(Icons.person, size: radius) : null,
      onBackgroundImageError: (exception, stackTrace) {
        if (exception is NetworkImageLoadException) {
          if (exception.statusCode == 404) {
            _usersWithoutProfilePictures.add(userId);
          }
        }
      },
    );
  }

  @protected
  void clearUserCaches() {
    _cachedUsers.clear();
    for (final cachedProfilePicture in _cachedProfilePictures.values) {
      cachedProfilePicture.evict();
    }
    _cachedProfilePictures.clear();
    _usersWithoutProfilePictures.clear();
  }

  @protected
  Future<void> refreshCurrentUser() async {
    await userService.refreshCurrentUser();
    _refreshProfilePicture();
  }

  void _refreshProfilePicture() {
    if (_cachedProfilePictures.containsKey(currentUser.id)) {
      final cachedProfilePicture = _cachedProfilePictures[currentUser.id];
      cachedProfilePicture?.evict();
      _cachedProfilePictures[currentUser.id] = userService.profilePicture(userId: currentUser.id);
    }
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

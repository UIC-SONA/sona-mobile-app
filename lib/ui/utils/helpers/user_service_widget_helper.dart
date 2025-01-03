import 'package:flutter/material.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/http/utils.dart';

mixin UserServiceWidgetHelper {
  final UserService _userService = injector.get<UserService>();

  static final _cachedUsers = <int, User>{};
  static final _cachedProfilePictures = <int, ImageProvider<Object>>{};
  static final _usersWithoutProfilePictures = <int>{};

  User get currentUser => _userService.currentUser;

  @protected
  Future<User> findUser(int userId) async {
    if (_cachedUsers.containsKey(userId)) {
      final user = _cachedUsers[userId];
      if (user != null) return user;
    }

    return onNotFound<User>(
      fetch: () async {
        final user = await _userService.find(userId);
        _cachedUsers[userId] = user;
        return user;
      },
      onNotFound: () => UserService.notFound,
    );
  }

  Future<List<User>> findUsers(List<int> userIds) async {
    final users = await _userService.findMany(userIds);
    for (final user in users) {
      _cachedUsers[user.id] = user;
    }
    return users;
  }

  Widget buildProfilePicture(int userId, {double width = 30.0, double height = 30.0}) {
    if (!_cachedProfilePictures.containsKey(userId)) {
      _cachedProfilePictures[userId] = _userService.profilePicture(userId: userId);
    }
    if (_usersWithoutProfilePictures.contains(userId)) {
      return _sizedContainer(Icon(Icons.person), width, height);
    }
    return Image(
      image: _cachedProfilePictures[userId]!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        if (error is NetworkImageLoadException) {
          if (error.statusCode == 404) {
            _usersWithoutProfilePictures.add(userId);
            return _sizedContainer(const Icon(Icons.person), width, height);
          }
        }
        return _sizedContainer(const Icon(Icons.error), width, height);
      },
    );
  }

  Widget _sizedContainer(Widget child, double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(child: child),
    );
  }

  @protected
  void clearCaches() {
    _cachedUsers.clear();
    _cachedProfilePictures.clear();
    _usersWithoutProfilePictures.clear();
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

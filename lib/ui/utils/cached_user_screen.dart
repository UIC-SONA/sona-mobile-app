import 'package:flutter/material.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';

mixin UserServiceWidgetHelper {
  @protected
  UserService get userService;

  static final _cachedUsers = <int, User>{};

  @protected
  Future<User> getUser(int userId) async {
    if (_cachedUsers.containsKey(userId)) {
      final user = _cachedUsers[userId];
      if (user != null) return user;
    }

    final user = await userService.find(userId);
    _cachedUsers[userId] = user;
    return user;
  }

  Widget buildProfilePicture(int userId) {
    return Image(
      image: userService.profilePicture(userId: userId),
      width: 40.0,
      height: 40.0,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        if (error is NetworkImageLoadException) {
          if (error.statusCode == 404) {
            return const Icon(Icons.person);
          }
        }
        return const Icon(Icons.error);
      },
    );
  }

  @protected
  void clearCache() {
    _cachedUsers.clear();
  }

  Widget buildUserName(int userId) {
    return FutureBuilder(
      future: getUser(userId),
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

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/http/http.dart';

mixin CachedUser {
  @protected
  UserService get userService;

  final _cachedUsers = <int, dynamic>{};

  @protected
  Future<Uint8List> getProfilePicture(int userId) async {
    if (_cachedUsers.containsKey(userId)) {
      final profilePicture = _cachedUsers[userId]["profilePicture"];
      if (profilePicture != null) return profilePicture;
    } else {
      _cachedUsers[userId] = {};
    }

    final profilePicture = await onNotFound(
      fetch: () => userService.profilePicture(userId: userId),
      onNotFound: () => Uint8List(0),
    );

    _cachedUsers[userId]["profilePicture"] = profilePicture;
    return profilePicture;
  }

  @protected
  Future<User> getUser(int userId) async {
    if (_cachedUsers.containsKey(userId)) {
      final user = _cachedUsers[userId]["user"];
      if (user != null) return user;
    } else {
      _cachedUsers[userId] = {};
    }

    final user = await userService.find(userId);
    _cachedUsers[userId]["user"] = user;
    return user;
  }
}

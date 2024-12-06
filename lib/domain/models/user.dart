import 'package:sona/shared/extensions.dart';

enum Authority {
  admin,
  administrative,
  professional,
  user;

  static Authority fromString(String value) {
    return Authority.values.firstWhere((e) => e.name.equalsIgnoreCase(value));
  }
}

class UserRepresentation {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final bool emailVerified;

  UserRepresentation({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.emailVerified,
  });

  factory UserRepresentation.fromJson(Map<String, dynamic> json) {
    return UserRepresentation(
      id: json['id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      emailVerified: json['emailVerified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'emailVerified': emailVerified,
    };
  }
}

class User {
  final int id;
  final String keycloakId;
  final String? profilePicturePath;
  final UserRepresentation representation;
  final List<Authority> authorities;

  User({
    required this.id,
    required this.keycloakId,
    required this.profilePicturePath,
    required this.representation,
    required this.authorities,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      keycloakId: json['keycloakId'],
      profilePicturePath: json['profilePicturePath'],
      representation: UserRepresentation.fromJson(json['representation']),
      authorities: List.from(json['authorities']).map((e) => Authority.fromString(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keycloakId': keycloakId,
      'profilePicturePath': profilePicturePath,
      'representation': representation.toJson(),
      'authorities': authorities,
    };
  }

  String toString() {
    return 'User(id: $id, keycloakId: $keycloakId, profilePicturePath: $profilePicturePath, representation: $representation, authorities: $authorities)';
  }
}

class UserInfo {
  final String sub;
  final String name;
  final String preferredUsername;
  final String givenName;
  final String familyName;
  final String email;

  UserInfo({
    required this.sub,
    required this.name,
    required this.preferredUsername,
    required this.givenName,
    required this.familyName,
    required this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      sub: json['sub'],
      name: json['name'],
      preferredUsername: json['preferred_username'],
      givenName: json['given_name'],
      familyName: json['family_name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub': sub,
      'name': name,
      'preferred_username': preferredUsername,
      'given_name': givenName,
      'family_name': familyName,
      'email': email,
    };
  }
}

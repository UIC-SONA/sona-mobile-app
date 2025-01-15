enum Authority {
  admin("ADMIN", "Administrador"),
  administrative("ADMINISTRATIVE", "Administrativo"),
  medicalProfessional("MEDICAL_PROFESSIONAL", "Professional médico"),
  legalProfessional("LEGAL_PROFESSIONAL", "Professional jurídico"),
  user("USER", "Usuário");

  final String authority;
  final String humanName;

  const Authority(this.authority, this.humanName);

  static Authority of(String authority) {
    return Authority.values.firstWhere((e) => e.authority == authority);
  }
}

const List<Authority> professionalAuthorities = [
  Authority.medicalProfessional,
  Authority.legalProfessional,
];

class User {
  final int id;
  final String keycloakId;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final List<Authority> authorities;
  final bool anonymous;
  final bool hasProfilePicture;

  User({
    required this.id,
    required this.keycloakId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.authorities,
    required this.anonymous,
    required this.hasProfilePicture,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      keycloakId: json['keycloakId'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      authorities: List.from(json['authorities']).map((e) => Authority.of(e)).toList(),
      anonymous: json['anonymous'],
      hasProfilePicture: json['hasProfilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keycloakId': keycloakId,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'authorities': authorities,
      'anonymous': anonymous,
      'hasProfilePicture': hasProfilePicture,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, keycloakId: $keycloakId, username: $username, firstName: $firstName, lastName: $lastName, email: $email, authorities: $authorities, anonymous: $anonymous}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
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

class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String? profilePicture;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.profilePicture,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'profilePicture': profilePicture,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      profilePicture: map['profilePicture'],
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? profilePicture,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
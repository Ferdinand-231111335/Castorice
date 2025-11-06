class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String? profilePicture; // Tambahkan ini

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.profilePicture, // Tambahkan ini
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'profilePicture': profilePicture, // Tambahkan ini
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      profilePicture: map['profilePicture'], // Tambahkan ini
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? profilePicture, // Tambahkan ini
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      profilePicture: profilePicture ?? this.profilePicture, // Tambahkan ini
    );
  }
}
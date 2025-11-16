class User {
  final String id;
  final String username;
  final String pin;
  final String? name;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.pin,
    this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'pin': pin,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      username: map['username'] as String,
      pin: map['pin'] as String,
      name: map['name'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}


class User {
  final int userId;
  final String username;
  final String email;
  final String role;

  User({required this.userId, required this.username, required this.email, required this.role});

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json['user_id'],
    username: json['username'],
    email: json['email'],
    role: json['role'],
  );
}
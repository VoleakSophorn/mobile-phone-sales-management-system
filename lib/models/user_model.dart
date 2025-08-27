class UserModel {
  final String uid;
  final String email;
  final String role;

  UserModel({required this.uid, required this.email, required this.role});

  // Add copyWith method
  UserModel copyWith({
    String? uid,
    String? email,
    String? role,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
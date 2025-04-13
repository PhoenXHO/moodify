class Credentials {
  final String email;
  final String password;

  Credentials({
    required this.email,
    required this.password,
  });

  // Convert Credentials to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  // Create Credentials from JSON
  factory Credentials.fromJson(Map<String, dynamic> json) {
    return Credentials(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  // Copy with method for immutability
  Credentials copyWith({
    String? email,
    String? password,
  }) {
    return Credentials(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  String toString() => 'Credentials(email: $email, password: $password)';
}
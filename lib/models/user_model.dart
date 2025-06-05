class User {
  final String email;
  final String password;
  final String name;
  final DateTime birthDate;
  final bool acceptedTerms;

  User({
    required this.email,
    required this.password,
    required this.name,
    required this.birthDate,
    required this.acceptedTerms,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'acceptedTerms': acceptedTerms,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      password: json['password'],
      name: json['name'],
      birthDate: DateTime.parse(json['birthDate']),
      acceptedTerms: json['acceptedTerms'],
    );
  }
} 
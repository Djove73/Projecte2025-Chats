class User {
  final String email;
  final String password;
  final String name;
  final DateTime birthDate;
  final bool acceptedTerms;
  final List<String> blockedUsers;
  final List<String> reportedUsers;

  User({
    required this.email,
    required this.password,
    required this.name,
    required this.birthDate,
    required this.acceptedTerms,
    this.blockedUsers = const [],
    this.reportedUsers = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'acceptedTerms': acceptedTerms,
      'blockedUsers': blockedUsers,
      'reportedUsers': reportedUsers,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      password: json['password'],
      name: json['name'],
      birthDate: DateTime.parse(json['birthDate']),
      acceptedTerms: json['acceptedTerms'],
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
      reportedUsers: List<String>.from(json['reportedUsers'] ?? []),
    );
  }
} 
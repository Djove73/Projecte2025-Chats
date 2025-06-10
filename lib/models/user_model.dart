class User {
  final String email;
  final String password;
  final String name;
  final DateTime birthDate;
  final bool acceptedTerms;
  final List<String> blockedUsers;
  final List<String> reportedUsers;
  final List<String> interests;

  User({
    required this.email,
    required this.password,
    required this.name,
    required this.birthDate,
    required this.acceptedTerms,
    this.blockedUsers = const [],
    this.reportedUsers = const [],
    this.interests = const [],
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
      'interests': interests,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: (json['email'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      birthDate: json['birthDate'] != null && json['birthDate'].toString().isNotEmpty
          ? DateTime.parse(json['birthDate'])
          : DateTime(2000, 1, 1),
      acceptedTerms: json['acceptedTerms'] ?? false,
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
      reportedUsers: List<String>.from(json['reportedUsers'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
    );
  }
} 
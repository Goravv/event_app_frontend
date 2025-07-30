class AppUser {
  final String username;
  final String email;
  final String password;
  final String planType;
  final int bidsLeft;
  final String? imageUrl;

  AppUser({
    required this.username,
    required this.email,
    required this.password,
    required this.planType,
    required this.bidsLeft,
    this.imageUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      planType: json['planType'] ?? 'Free Plan',
      bidsLeft: json['bidsLeft'] ?? 0,
      imageUrl: json['imageUrl'],
    );
  }
}

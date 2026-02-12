class User {
  String fullName;
  String email;
  String password;

  // Optional profile fields
  String? profileImage; // path or url
  String? location;
  String? phoneNumber;
  String? gender;

  User({
    required this.fullName,
    required this.email,
    required this.password,
    this.profileImage,
    this.location,
    this.phoneNumber,
    this.gender,
  });
}

/// Simple in-memory repository for demo purposes.
class UserRepository {
  UserRepository._privateConstructor();
  static final UserRepository instance = UserRepository._privateConstructor();

  final List<User> _users = [];
  User? currentUser;
  String? lastLoggedInEmail;

  List<User> get users => List.unmodifiable(_users);

  void addUser(User user) {
    _users.add(user);
  }

  User? findByEmail(String email) {
    try {
      return _users.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  bool validateCredentials(String email, String password) {
    final user = findByEmail(email);
    if (user == null) return false;
    return user.password == password;
  }

  void setLastLoggedInEmail(String? email) {
    lastLoggedInEmail = email;
  }
}

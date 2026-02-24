class User {
  // required
  String fullName;
  String email;
  String password;

  // optional
  String? profileImage; 
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

class UserRepository {
  static final UserRepository instance = UserRepository._privateConstructor();
  final List<User> _users = [];
  User? currentUser;
  String? lastLoggedInEmail;

  // preset for easier login during testing
  UserRepository._privateConstructor() {
    _users.add(User(
      fullName: 'Matt',
      email: '1',
      password: '1',
      profileImage: null,
      location: 'Home',
      phoneNumber: '12347890',
      gender: 'Prefer not to say',
    ));
  }

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

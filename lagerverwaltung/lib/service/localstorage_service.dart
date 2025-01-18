import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // Service-Setup:
  LocalStorageService._privateConstructor();
  static final LocalStorageService _instance =
      LocalStorageService._privateConstructor();
  factory LocalStorageService() {
    return _instance;
  }

  // Keys:
  static const String _usernameKey = "username";

  // Methods:

  // Username-Methods: (Just for demonstration)
  Future<void> writeUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  Future<String?> readUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }
}

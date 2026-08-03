import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  String? currentWorkerId;
  String? currentWorkerName;
  String? currentWorkerRole;

  void startSession({
    required String id,
    String? name,
    String? role,
  }) {
    currentWorkerId = id;
    currentWorkerName = name;
    currentWorkerRole = role;
  }

  Future<void> hydrateFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');
    if (id == null || id.trim().isEmpty) return;
    currentWorkerId = id.trim();
    currentWorkerName = prefs.getString('user_name');
    currentWorkerRole = prefs.getString('user_role');
  }

  Future<void> persistToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (currentWorkerId != null) {
      await prefs.setString('user_id', currentWorkerId!);
    }
    if (currentWorkerName != null) {
      await prefs.setString('user_name', currentWorkerName!);
    }
    if (currentWorkerRole != null) {
      await prefs.setString('user_role', currentWorkerRole!);
    }
  }

  Future<void> clearSession() async {
    currentWorkerId = null;
    currentWorkerName = null;
    currentWorkerRole = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
  }
}

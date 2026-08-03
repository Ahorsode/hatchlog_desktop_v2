import 'package:shared_preferences/shared_preferences.dart';

enum SessionMode { cloudSync, secureOffline }

class SessionModeService {
  static const _modeKey = 'active_session_mode';
  static const _cloudValue = 'cloud_sync';
  static const _offlineValue = 'secure_local_offline';

  static Future<void> markCloudSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, _cloudValue);
  }

  static Future<void> markSecureOffline() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, _offlineValue);
  }

  static Future<SessionMode> currentMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_modeKey) == _offlineValue
        ? SessionMode.secureOffline
        : SessionMode.cloudSync;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_modeKey);
  }
}

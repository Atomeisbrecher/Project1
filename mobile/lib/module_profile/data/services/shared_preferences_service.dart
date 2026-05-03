import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  final Future<SharedPreferences> _prefsFuture;

  SharedPreferencesService(this._prefsFuture);

  Future<void> setString(String key, String value) async {
    final prefs = await _prefsFuture;
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await _prefsFuture;
    return prefs.getString(key);
  }

  Future<void> remove(String key) async {
    final prefs = await _prefsFuture;
    await prefs.remove(key);
  }
}

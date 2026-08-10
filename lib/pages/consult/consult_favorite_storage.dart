import 'package:shared_preferences/shared_preferences.dart';

class ConsultFavoriteStorage {
  ConsultFavoriteStorage._();

  static const _storageKey = 'consult_favorite_doctors_v1';

  static Future<Set<String>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_storageKey) ?? <String>[]).toSet();
  }

  static Future<bool> isFavorite(String doctorId) async {
    final favorites = await getAll();
    return favorites.contains(doctorId);
  }

  static Future<void> toggle(String doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getAll();
    if (favorites.contains(doctorId)) {
      favorites.remove(doctorId);
    } else {
      favorites.add(doctorId);
    }
    await prefs.setStringList(_storageKey, favorites.toList());
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

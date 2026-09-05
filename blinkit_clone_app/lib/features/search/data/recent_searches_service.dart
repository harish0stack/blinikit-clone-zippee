// lib/features/search/data/recent_searches_service.dart
// Persistent recent search terms management via SharedPreferences & local cache
import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchesService {
  static const String _prefsKey = 'zippee_recent_searches';

  static const List<String> defaultInitialSearches = [
    'ice cream',
    'icecre',
    'rosemary water alps',
    'eoe',
  ];

  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey);
    if (list == null || list.isEmpty) {
      return defaultInitialSearches;
    }
    return list;
  }

  Future<void> addSearch(String term) async {
    final clean = term.trim();
    if (clean.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_prefsKey) ?? List.from(defaultInitialSearches);

    list.removeWhere((item) => item.toLowerCase() == clean.toLowerCase());
    list.insert(0, clean);

    if (list.length > 10) {
      list = list.sublist(0, 10);
    }

    await prefs.setStringList(_prefsKey, list);
  }

  Future<void> removeSearch(String term) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_prefsKey) ?? List.from(defaultInitialSearches);
    list.removeWhere((item) => item.toLowerCase() == term.toLowerCase());
    await prefs.setStringList(_prefsKey, list);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, []);
  }
}

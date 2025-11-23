import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ds_easy_db/ds_easy_db.dart';

/// SharedPreferences implementation of [DatabaseRepository].
///
/// Provides platform-native key-value storage using Flutter's SharedPreferences.
/// Actively maintained by the Flutter team with cross-platform support.
///
/// Features:
/// - Platform-native storage (NSUserDefaults on iOS, SharedPreferences on Android)
/// - Cross-platform (iOS, Android, Web, Windows, macOS, Linux)
/// - Simple and reliable
/// - No encryption (use SecureStorageDatabase for sensitive data)
///
/// Example:
/// ```dart
/// db.configure(
///   prefs: SharedPreferencesDatabase(),
///   // ...
/// );
/// ```
class SharedPreferencesDatabase implements DatabaseRepository {
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  String _getKey(String collection, String id) => '$collection:$id';

  @override
  Future<void> set(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final processedData = data.map((key, value) {
      if (value == DatabaseRepository.serverTS) {
        return MapEntry(key, DateTime.now().toIso8601String());
      }
      return MapEntry(key, value);
    });

    await init();
    final key = _getKey(collection, id);
    await _prefs!.setString(key, jsonEncode(processedData));
  }

  @override
  Future<void> update(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final processedData = data.map((key, value) {
      if (value == DatabaseRepository.serverTS) {
        return MapEntry(key, DateTime.now().toIso8601String());
      }
      return MapEntry(key, value);
    });

    await init();
    final key = _getKey(collection, id);
    final existing = await get(collection, id) ?? {};
    final updated = {...existing, ...processedData};
    await _prefs!.setString(key, jsonEncode(updated));
  }

  @override
  Future<Map<String, dynamic>?> get(
    String collection,
    String id, {
    dynamic defaultValue,
  }) async {
    await init();
    final key = _getKey(collection, id);
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return defaultValue;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>?> getAll(String collection) async {
    await init();
    final prefix = '$collection:';
    final keys = _prefs!.getKeys().where((key) => key.startsWith(prefix));

    if (keys.isEmpty) return null;

    final Map<String, dynamic> result = {};
    for (var key in keys) {
      final id = key.substring(prefix.length);
      final jsonString = _prefs!.getString(key);
      if (jsonString != null) {
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        result[id] = data;
      }
    }
    return result;
  }

  @override
  Future<bool> exists(String collection, String id) async {
    await init();
    final key = _getKey(collection, id);
    return _prefs!.containsKey(key);
  }

  @override
  Future<bool> existsWhere(
    String collection, {
    required Map<String, dynamic> where,
  }) async {
    await init();
    final items = await query(collection);
    for (var item in items) {
      bool matches = true;
      for (var entry in where.entries) {
        if (item[entry.key] != entry.value) {
          matches = false;
          break;
        }
      }
      if (matches) return true;
    }
    return false;
  }

  @override
  Future<void> delete(String collection, String id) async {
    await init();
    final key = _getKey(collection, id);
    await _prefs!.remove(key);
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String collection, {
    Map<String, dynamic> where = const {},
  }) async {
    await init();
    final prefix = '$collection:';
    final keys = _prefs!.getKeys().where((key) => key.startsWith(prefix));

    final items = <Map<String, dynamic>>[];
    for (var key in keys) {
      final jsonString = _prefs!.getString(key);
      if (jsonString != null) {
        final item = jsonDecode(jsonString) as Map<String, dynamic>;
        items.add(item);
      }
    }

    if (where.isEmpty) {
      return items;
    }

    return items.where((item) {
      for (var entry in where.entries) {
        if (item[entry.key] != entry.value) return false;
      }
      return true;
    }).toList();
  }
}

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
/// Documents are stored as JSON strings under the key `collection:id`.
/// `DateTime` values (including [DatabaseRepository.serverTS]) are stored as
/// ISO-8601 strings and come back as strings.
///
/// Because collection and id share one key, a collection name should not
/// contain `:` — `getAll('user')` would otherwise also see the documents of a
/// collection called `user:settings`.
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

  Future<SharedPreferences> _instance() async {
    await init();
    return _prefs!;
  }

  Map<String, dynamic> _resolveServerTimestamps(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value == DatabaseRepository.serverTS) {
        return MapEntry(key, DateTime.now().toIso8601String());
      }
      return MapEntry(key, value);
    });
  }

  String _encode(Map<String, dynamic> data) => jsonEncode(
        data,
        toEncodable: (value) => value is DateTime
            ? value.toIso8601String()
            : throw JsonUnsupportedObjectError(value),
      );

  /// Decodes a stored value, or returns `null` for anything that is not a
  /// JSON document — another library may use keys with the same prefix.
  Map<String, dynamic>? _decode(Object? raw) {
    if (raw is! String) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  /// All `(id, document)` pairs of [collection].
  Future<Map<String, Map<String, dynamic>>> _documents(
    String collection,
  ) async {
    final prefs = await _instance();
    final prefix = '$collection:';

    final result = <String, Map<String, dynamic>>{};
    for (final key in prefs.getKeys()) {
      if (!key.startsWith(prefix)) continue;
      final document = _decode(prefs.get(key));
      if (document != null) result[key.substring(prefix.length)] = document;
    }
    return result;
  }

  @override
  Future<void> set(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final prefs = await _instance();
    await prefs.setString(
      _getKey(collection, id),
      _encode(_resolveServerTimestamps(data)),
    );
  }

  @override
  Future<void> update(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final prefs = await _instance();
    final existing = await get(collection, id) ?? <String, dynamic>{};
    final updated = {...existing, ..._resolveServerTimestamps(data)};
    await prefs.setString(_getKey(collection, id), _encode(updated));
  }

  @override
  Future<Map<String, dynamic>?> get(
    String collection,
    String id, {
    dynamic defaultValue,
  }) async {
    final prefs = await _instance();
    return _decode(prefs.get(_getKey(collection, id))) ?? defaultValue;
  }

  @override
  Future<Map<String, dynamic>?> getAll(String collection) async {
    final documents = await _documents(collection);
    return documents.isEmpty ? null : documents;
  }

  @override
  Future<bool> exists(String collection, String id) async {
    final prefs = await _instance();
    return prefs.containsKey(_getKey(collection, id));
  }

  @override
  Future<bool> existsWhere(
    String collection, {
    required Map<String, dynamic> where,
  }) async {
    final documents = await _documents(collection);
    return documents.values.any((document) => _matches(document, where));
  }

  @override
  Future<void> delete(String collection, String id) async {
    final prefs = await _instance();
    await prefs.remove(_getKey(collection, id));
  }

  /// Returns the matching documents, each with its document id under `id`.
  ///
  /// A document that carries its own `id` field keeps it.
  @override
  Future<List<Map<String, dynamic>>> query(
    String collection, {
    Map<String, dynamic> where = const {},
  }) async {
    final documents = await _documents(collection);
    return [
      for (final entry in documents.entries)
        if (_matches(entry.value, where))
          <String, dynamic>{'id': entry.key, ...entry.value},
    ];
  }

  bool _matches(Map<String, dynamic> document, Map<String, dynamic> where) {
    for (final entry in where.entries) {
      if (document[entry.key] != entry.value) return false;
    }
    return true;
  }
}

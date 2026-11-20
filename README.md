# DS-EasyDB SharedPreferences

SharedPreferences implementation for [DS-EasyDB](https://pub.dev/packages/ds_easy_db) (<https://github.com/Dragon-InterActive/ds_easy_db>). Provides simple, platform-native key-value storage for Flutter applications.

## Features

- **Platform Native**: Uses native preferences on each platform (NSUserDefaults on iOS, SharedPreferences on Android)
- **Simple API**: Easy key-value storage
- **Actively Maintained**: Official Flutter package with regular updates
- **Cross-Platform**: Works on iOS, Android, Web, Windows, macOS, and Linux
- **Persistent**: Data survives app restarts

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  ds_easy_db: ^1.1.1
  ds_easy_db_shared_preferences: ^1.1.0
```

## Usage

### Basic Setup

```dart
import 'package:ds_easy_db/ds_easy_db.dart';
import 'package:ds_easy_db_shared_preferences/ds_easy_db_shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  db.configure(
    prefs: SharedPreferencesDatabase(),
    // ... other configurations
  );
  
  await db.init();
  
  runApp(MyApp());
}
```

### Configuration File

In your `ds_easy_db_config.dart`:

```dart
import 'package:ds_easy_db/ds_easy_db.dart';
import 'package:ds_easy_db_shared_preferences/ds_easy_db_shared_preferences.dart';

class DS-EasyDBConfig {
  static DatabaseRepository get prefs => SharedPreferencesDatabase();
  // ... other configurations
}
```

## Examples

### Store User Settings

```dart
// Save user preferences
await db.prefs!.set('settings', 'user_prefs', {
  'theme': 'dark',
  'language': 'en',
  'notifications': true,
  'lastUpdated': DatabaseRepository.serverTS, // Uses DateTime.now()
});

// Read preferences
final prefs = await db.prefs!.get('settings', 'user_prefs');
print('Theme: ${prefs?['theme']}'); // dark

// Update specific fields
await db.prefs!.update('settings', 'user_prefs', {
  'theme': 'light',
});
```

### Store App Configuration

```dart
// Save API configuration
await db.prefs!.set('config', 'api', {
  'baseUrl': 'https://api.example.com',
  'timeout': 30,
  'version': '1.0.0',
});

// Check if exists
if (await db.prefs!.exists('config', 'api')) {
  final config = await db.prefs!.get('config', 'api');
  print('API URL: ${config?['baseUrl']}');
}
```

### Store User Session

```dart
// Save session data
await db.prefs!.set('session', 'current', {
  'userId': '12345',
  'username': 'john_doe',
  'lastLogin': DatabaseRepository.serverTS,
  'isActive': true,
});

// Get all sessions
final allSessions = await db.prefs!.getAll('session');
print('Total sessions: ${allSessions?.length}');

// Clear session
await db.prefs!.delete('session', 'current');
```

### Query Data

```dart
// Store multiple items
await db.prefs!.set('bookmarks', 'bm1', {'url': 'example.com', 'favorite': true});
await db.prefs!.set('bookmarks', 'bm2', {'url': 'flutter.dev', 'favorite': false});
await db.prefs!.set('bookmarks', 'bm3', {'url': 'dart.dev', 'favorite': true});

// Query favorites
final favorites = await db.prefs!.query('bookmarks', 
  where: {'favorite': true}
);
print('Favorite bookmarks: ${favorites.length}'); // 2

// Check if any bookmark exists with condition
final hasFavorites = await db.prefs!.existsWhere('bookmarks',
  where: {'favorite': true}
);
print('Has favorites: $hasFavorites'); // true
```

## Data Types

SharedPreferences internally uses JSON encoding, so all data is serialized to strings. Supported types:

- Strings
- Numbers (int, double)
- Booleans
- Lists
- Maps
- DateTime (automatically converted to ISO8601 strings)

## Storage Limits

SharedPreferences has platform-specific limits:

- **Android**: Typically ~2MB per app
- **iOS**: No hard limit, but keep data small
- **Web**: LocalStorage limit (~5-10MB depending on browser)

For larger data, consider using `ds_easy_db_hive` or `ds_easy_db_sqlite`.

## When to Use

Use `ds_easy_db_shared_preferences` for:

- ✅ User preferences and settings
- ✅ App configuration
- ✅ Simple flags and toggles
- ✅ Small amounts of data
- ✅ Cross-platform compatibility

Don't use it for:

- ❌ Sensitive data (use `ds_easy_db_secure_storage` instead)
- ❌ Large datasets (use `ds_easy_db_hive` or SQLite)
- ❌ Complex queries (consider Firestore or SQLite)
- ❌ Real-time sync (use `ds_easy_db_firebase_realtime`)

## Advantages over Hive

- ✅ **Actively Maintained**: Regular updates from Flutter team
- ✅ **Official Package**: Part of Flutter ecosystem
- ✅ **Platform Native**: Uses native storage mechanisms
- ✅ **Proven Stability**: Used in production by thousands of apps
- ✅ **Better Web Support**: Works seamlessly on web platform

## Performance Notes

- First access requires initialization (async)
- Subsequent reads are fast (cached in memory)
- Writes are asynchronous but fast
- All data is loaded into memory on init
- Keep stored data small for best performance

## License

BSD-3-Clause License - see LICENSE file for details.

Copyright (c) 2025, MasterNemo (Dragon Software)

---

Feel free to clone and extend. It's free to use and share.

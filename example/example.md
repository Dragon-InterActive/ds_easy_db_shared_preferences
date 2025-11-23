# DS-EasyDB SharedPreferences Example

```dart
import 'packages:ds_easy_db/ds_easy_db.dart';
import 'packages:ds_easy_db_shared_preferences/ds_easy_db_shared_preferences.dart';

void main() async {
    // Configure with SharedPreferences
    db.configure(
        prefs: SharedPreferencesDatabase();
        secure: MockDatabase();
        storage: MockDatabase();
        stream: MockDatabase();
    );

    await db.init();

    // Store app settings
    await db.prefs.set('config', 'api', {
        'baseURL': 'https://api.example.com',
        'timeout': 30,
        'version': '1.0.0',
    });

    // Read settings
    final config = await db.prefs.get('config', 'api');
    print('API URL: ${config?['baseURL']}');

    // Check existence
    if (await db.prefs.exists('config', 'api')) {
        print('API configured');
    }
}
```

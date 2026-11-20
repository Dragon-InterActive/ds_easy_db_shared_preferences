## 1.1.0

* Fixed: `DateTime` values made `set`/`update` throw; they are stored as
  ISO-8601 strings now.
* Fixed: foreign or malformed entries with a matching key prefix made
  `get`, `getAll` and `query` throw; they are skipped now.
* `query` results include the document id as `id` (a document's own `id`
  field is kept).

## 1.0.1

* Added dartdoc comments to public API
* Added example documentation

## 1.0.0

* Initial release
* SharedPreferences integration for EasyDB
* Platform-native key-value storage
* Cross-platform support (iOS, Android, Web, Windows, macOS, Linux)
* Simple API for app settings and preferences
* Actively maintained by Flutter team

import 'package:ds_easy_db/ds_easy_db.dart';
import 'package:ds_easy_db_shared_preferences/ds_easy_db_shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferencesDatabase db;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = SharedPreferencesDatabase();
  });

  test('DateTime values are stored instead of throwing', () async {
    final at = DateTime.utc(2026, 1, 2, 3, 4, 5);
    await db.set('events', 'e1', {'at': at});

    expect((await db.get('events', 'e1'))!['at'], at.toIso8601String());
  });

  test('serverTS becomes an ISO-8601 string', () async {
    await db.set('events', 'e1', {'at': DatabaseRepository.serverTS});

    final at = (await db.get('events', 'e1'))!['at'] as String;
    expect(DateTime.tryParse(at), isNotNull);
  });

  test('foreign keys with the same prefix are skipped, not thrown on',
      () async {
    SharedPreferences.setMockInitialValues({
      'users:counter': 42,
      'users:broken': 'not json',
      'users:list': '[1, 2]',
    });
    db = SharedPreferencesDatabase();
    await db.set('users', 'u1', {'age': 30});

    expect((await db.getAll('users'))!.keys, ['u1']);
    expect((await db.query('users')).map((d) => d['id']), ['u1']);
    expect(await db.get('users', 'broken'), isNull);
    expect(await db.get('users', 'counter', defaultValue: {'x': 1}), {'x': 1});
    expect(await db.existsWhere('users', where: {'age': 30}), isTrue);
  });

  test('query adds the document id and filters', () async {
    await db.set('users', 'u1', {'age': 30});
    await db.set('users', 'u2', {'age': 40});

    expect(await db.query('users', where: {'age': 30}), [
      {'id': 'u1', 'age': 30},
    ]);
  });

  test('a document with its own "id" field keeps it', () async {
    await db.set('users', 'u1', {'id': 'custom'});

    expect((await db.query('users')).single['id'], 'custom');
  });

  test('update merges and keeps the stored format readable', () async {
    await db.set('users', 'u1', {'a': 1});
    await db.update('users', 'u1', {'at': DateTime.utc(2026)});

    expect(await db.get('users', 'u1'), {
      'a': 1,
      'at': DateTime.utc(2026).toIso8601String(),
    });
  });

  test('works without an explicit init()', () async {
    await db.set('users', 'u1', {'a': 1});
    expect(await db.exists('users', 'u1'), isTrue);
  });
}

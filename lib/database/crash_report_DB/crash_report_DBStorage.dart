import 'package:sqflite/sqflite.dart';

class CrashReportDbStorage {
  static const String tableName = 'crash_reports';

  static Future<void> onCreate(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        errorMessage TEXT NOT NULL,
        stackTrace TEXT NOT NULL,
        deviceInfo TEXT,
        userInfo TEXT,
        appVersion TEXT NOT NULL,
        platform TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        errorType TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  static Future<void> onDelete(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  static Future<int> insertCrashReport(Database db, Map<String, dynamic> data) async {
    return await db.insert(tableName, data);
  }

  static Future<List<Map<String, dynamic>>> getAllUnsyncedReports(Database db) async {
    return await db.query(
      tableName,
      where: 'isSynced = ?',
      whereArgs: [0],
      orderBy: 'timestamp DESC',
    );
  }

  static Future<List<Map<String, dynamic>>> getAllReports(Database db) async {
    return await db.query(tableName, orderBy: 'timestamp DESC');
  }

  static Future<int> markAsSynced(Database db, List<int> ids) async {
    if (ids.isEmpty) return 0;
    return await db.update(
      tableName,
      {'isSynced': 1},
      where: 'id IN (${ids.map((_) => '?').join(',')})',
      whereArgs: ids,
    );
  }

  static Future<int> deleteAllSynced(Database db) async {
    return await db.delete(
      tableName,
      where: 'isSynced = ?',
      whereArgs: [1],
    );
  }

  static Future<int> getUnsyncedCount(Database db) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE isSynced = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

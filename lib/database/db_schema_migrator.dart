import 'package:sqflite/sqflite.dart';

import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:pos_mobile/database/crash_report_DB/crash_report_DBService.dart';
import 'package:pos_mobile/database/imageModel_DB/image_DBsevice.dart';
import 'package:pos_mobile/database/itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/Item_DbStorage.dart';
import 'package:pos_mobile/database/itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/category_DbStorage.dart';
import 'package:pos_mobile/database/itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/group_DbStorage.dart';
import 'package:pos_mobile/database/itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/type_DbStorage.dart';
import 'package:pos_mobile/database/itemModel_DB/module_component_item_DB/module_component_item_DbService.dart';
import 'package:pos_mobile/database/itemModel_DB/uniqueItem_DB/uniqueItem_DbService.dart';
import 'package:pos_mobile/database/userModel_DB/user_DBService.dart';
import 'package:pos_mobile/utils/debug_print.dart';

class DbColumnSpec {
  final String name;
  final String definition;

  const DbColumnSpec({
    required this.name,
    required this.definition,
  });
}

class DbTableSpec {
  final String tableName;
  final List<DbColumnSpec> columns;

  const DbTableSpec({
    required this.tableName,
    required this.columns,
  });
}

class DbSchemaMigrator {
  static const List<DbTableSpec> _schemaSpecs = [
    DbTableSpec(
      tableName: 'crash_reports',
      columns: [
        DbColumnSpec(name: 'errorMessage', definition: 'TEXT NOT NULL'),
        DbColumnSpec(name: 'stackTrace', definition: 'TEXT NOT NULL'),
        DbColumnSpec(name: 'deviceInfo', definition: 'TEXT'),
        DbColumnSpec(name: 'userInfo', definition: 'TEXT'),
        DbColumnSpec(name: 'appVersion', definition: 'TEXT NOT NULL'),
        DbColumnSpec(name: 'platform', definition: 'TEXT NOT NULL'),
        DbColumnSpec(name: 'timestamp', definition: 'TEXT NOT NULL'),
        DbColumnSpec(name: 'errorType', definition: 'TEXT NOT NULL'),
        DbColumnSpec(
          name: 'isSynced',
          definition: 'INTEGER NOT NULL DEFAULT 0',
        ),
      ],
    ),
    DbTableSpec(
      tableName: TxtConstants.userTableName,
      columns: [
        DbColumnSpec(name: 'userName', definition: 'TEXT NOT NULL'),
        DbColumnSpec(name: 'password', definition: 'TEXT NOT NULL'),
        DbColumnSpec(name: 'userLevel', definition: 'TEXT NOT NULL'),
        DbColumnSpec(name: 'userCreateTime', definition: 'TEXT NOT NULL'),
        DbColumnSpec(name: 'userLoginTime', definition: 'TEXT'),
        DbColumnSpec(name: 'userLogoutTime', definition: 'TEXT'),
        DbColumnSpec(
          name: 'activeStatus',
          definition: 'INTEGER NOT NULL DEFAULT 1',
        ),
        DbColumnSpec(
          name: 'imageId',
          definition: 'INTEGER REFERENCES ${TxtConstants.imageTableName}(id)',
        ),
      ],
    ),
    DbTableSpec(
      tableName: TxtConstants.categoryTableName,
      columns: [
        DbColumnSpec(name: 'name', definition: 'TEXT NOT NULL'),
        DbColumnSpec(name: 'createTime', definition: 'TEXT NOT NULL'),
        DbColumnSpec(name: 'lastUpdateTime', definition: 'TEXT'),
        DbColumnSpec(name: 'deleteTime', definition: 'TEXT'),
        DbColumnSpec(
          name: 'activeStatus',
          definition: 'INTEGER NOT NULL DEFAULT 1',
        ),
        DbColumnSpec(
          name: 'createPersonId',
          definition: 'INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL',
        ),
        DbColumnSpec(
          name: 'deletePersonId',
          definition: 'INTEGER REFERENCES ${TxtConstants.userTableName}(id)',
        ),
        DbColumnSpec(name: 'colorCode', definition: 'TEXT'),
      ],
    ),
    DbTableSpec(
      tableName: TxtConstants.groupTableName,
      columns: [
        DbColumnSpec(name: 'name', definition: 'TEXT NOT NULL'),
        DbColumnSpec(
          name: 'categoryId',
          definition:
              'INTEGER REFERENCES ${TxtConstants.categoryTableName}(id) NOT NULL',
        ),
        DbColumnSpec(name: 'createTime', definition: 'TEXT NOT NULL'),
        DbColumnSpec(name: 'lastUpdateTime', definition: 'TEXT'),
        DbColumnSpec(name: 'deleteTime', definition: 'TEXT'),
        DbColumnSpec(
          name: 'activeStatus',
          definition: 'INTEGER NOT NULL DEFAULT 1',
        ),
        DbColumnSpec(name: 'description', definition: 'TEXT'),
        DbColumnSpec(
          name: 'createPersonId',
          definition: 'INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL',
        ),
        DbColumnSpec(
          name: 'deletePersonId',
          definition: 'INTEGER REFERENCES ${TxtConstants.userTableName}(id)',
        ),
        DbColumnSpec(name: 'colorCode', definition: 'TEXT'),
      ],
    ),
    DbTableSpec(
      tableName: TxtConstants.typeTableName,
      columns: [
        DbColumnSpec(
          name: 'groupId',
          definition: 'INTEGER REFERENCES ${TxtConstants.groupTableName}(id) NOT NULL',
        ),
        DbColumnSpec(name: 'name', definition: 'TEXT NOT NULL'),
        DbColumnSpec(name: 'createTime', definition: 'TEXT NOT NULL'),
        DbColumnSpec(name: 'lastUpdateTime', definition: 'TEXT'),
        DbColumnSpec(name: 'deleteTime', definition: 'TEXT'),
        DbColumnSpec(
          name: 'activeStatus',
          definition: 'INTEGER NOT NULL DEFAULT 1',
        ),
        DbColumnSpec(
          name: 'createPersonId',
          definition: 'INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL',
        ),
        DbColumnSpec(
          name: 'deletePersonId',
          definition: 'INTEGER REFERENCES ${TxtConstants.userTableName}(id)',
        ),
        DbColumnSpec(name: 'colorCode', definition: 'TEXT'),
        DbColumnSpec(
          name: 'imageId',
          definition: 'INTEGER REFERENCES ${TxtConstants.imageTableName}(id)',
        ),
        DbColumnSpec(name: 'generalDescription', definition: 'TEXT'),
        DbColumnSpec(
          name: 'generalRestrictionId',
          definition: 'INTEGER REFERENCES ${TxtConstants.restrictionTableName}(id)',
        ),
        DbColumnSpec(
          name: 'hasExpire',
          definition: 'INTEGER NOT NULL DEFAULT 0',
        ),
      ],
    ),
    DbTableSpec(
      tableName: TxtConstants.itemTableName,
      columns: [
        DbColumnSpec(name: 'name', definition: 'TEXT NOT NULL'),
        DbColumnSpec(
          name: 'typeId',
          definition: 'INTEGER REFERENCES ${TxtConstants.typeTableName}(id) NOT NULL',
        ),
        DbColumnSpec(name: 'createTime', definition: 'TEXT NOT NULL'),
        DbColumnSpec(name: 'lastUpdateTime', definition: 'TEXT'),
        DbColumnSpec(name: 'deleteTime', definition: 'TEXT'),
        DbColumnSpec(
          name: 'activeStatus',
          definition: 'INTEGER NOT NULL DEFAULT 1',
        ),
        DbColumnSpec(name: 'description', definition: 'TEXT'),
        DbColumnSpec(
          name: 'hasExpire',
          definition: 'INTEGER NOT NULL DEFAULT 0',
        ),
        DbColumnSpec(
          name: 'createPersonId',
          definition: 'INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL',
        ),
        DbColumnSpec(
          name: 'deletePersonId',
          definition: 'INTEGER REFERENCES ${TxtConstants.userTableName}(id)',
        ),
        DbColumnSpec(name: 'colorCode', definition: 'TEXT'),
        DbColumnSpec(name: 'code', definition: 'TEXT'),
        DbColumnSpec(
          name: 'restrictionId',
          definition: 'INTEGER REFERENCES ${TxtConstants.restrictionTableName}(id)',
        ),
        DbColumnSpec(name: 'profitPrice', definition: 'REAL NOT NULL DEFAULT 0'),
        DbColumnSpec(name: 'originalPrice', definition: 'REAL NOT NULL DEFAULT 0'),
        DbColumnSpec(name: 'taxPercentage', definition: 'REAL NOT NULL DEFAULT 0'),
        DbColumnSpec(
          name: 'imageId',
          definition: 'INTEGER REFERENCES ${TxtConstants.imageTableName}(id)',
        ),
      ],
    ),
    DbTableSpec(
      tableName: TxtConstants.uniqueItemTableName,
      columns: [
        DbColumnSpec(
          name: 'itemId',
          definition: 'INTEGER REFERENCES ${TxtConstants.itemTableName}(id) NOT NULL',
        ),
        DbColumnSpec(
          name: 'stockInId',
          definition: 'INTEGER REFERENCES ${TxtConstants.stockInTableName}(id) NOT NULL',
        ),
        DbColumnSpec(
          name: 'stockOutId',
          definition: 'INTEGER REFERENCES ${TxtConstants.stockOutTableName}(id)',
        ),
        DbColumnSpec(name: 'createTime', definition: 'TEXT NOT NULL'),
        DbColumnSpec(name: 'lastUpdateTime', definition: 'TEXT'),
        DbColumnSpec(name: 'deleteTime', definition: 'TEXT'),
        DbColumnSpec(name: 'itemManufactureDate', definition: 'TEXT'),
        DbColumnSpec(name: 'itemExpireDate', definition: 'TEXT'),
        DbColumnSpec(name: 'code', definition: 'TEXT'),
        DbColumnSpec(name: 'originalPrice', definition: 'REAL NOT NULL DEFAULT 0'),
        DbColumnSpec(name: 'profitPrice', definition: 'REAL NOT NULL DEFAULT 0'),
        DbColumnSpec(name: 'taxPercentage', definition: 'REAL NOT NULL DEFAULT 0'),
        DbColumnSpec(
          name: 'createPersonId',
          definition: 'INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL',
        ),
        DbColumnSpec(
          name: 'deletePersonId',
          definition: 'INTEGER REFERENCES ${TxtConstants.userTableName}(id)',
        ),
        DbColumnSpec(
          name: 'activeStatus',
          definition: 'INTEGER NOT NULL DEFAULT 1',
        ),
        DbColumnSpec(name: 'getItemFromWhere', definition: 'TEXT'),
        DbColumnSpec(name: 'moduleCount', definition: 'INTEGER'),
      ],
    ),
  ];

  static Future<void> reconcile(Database db) async {
    try {
      await _recreateKnownTables(db);
      for (final tableSpec in _schemaSpecs) {
        await _ensureColumns(db, tableSpec);
      }
      await _ensureIndexes(db);
    } catch (e) {
      cusDebugPrint('DB schema reconciliation failed: $e');
      rethrow;
    }
  }

  static Future<void> _recreateKnownTables(Database db) async {
    await CrashReportDbService.initCrashReportDb(db);
    await ImageDbService.initImageDb(db);
    await UserDBService.initUserDB(db);
    await CategoryDbStorage.onCreate(db);
    await GroupDbStorage.onCreate(db);
    await TypeDbStorage.onCreate(db);
    await ItemDbStorage.onCreate(db);
    await UniqueItemDbService.initUniqueItemDb(db);
    await ModuleComponentItemDbService.initModuleComponentItemDbService(db);
  }

  static Future<void> _ensureIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_uniqueItem_itemId ON ${TxtConstants.uniqueItemTableName}(itemId);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_uniqueItem_stockOutId ON ${TxtConstants.uniqueItemTableName}(stockOutId);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_uniqueItem_activeStatus ON ${TxtConstants.uniqueItemTableName}(activeStatus);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_item_typeId ON ${TxtConstants.itemTableName}(typeId);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_item_activeStatus ON ${TxtConstants.itemTableName}(activeStatus);',
    );
  }

  static Future<void> _ensureColumns(Database db, DbTableSpec tableSpec) async {
    final existingColumns = await _getExistingColumns(db, tableSpec.tableName);
    for (final column in tableSpec.columns) {
      if (existingColumns.contains(column.name)) {
        continue;
      }

      await db.execute(
        'ALTER TABLE ${tableSpec.tableName} ADD COLUMN ${column.name} ${column.definition}',
      );
      cusDebugPrint(
        'Added missing column ${tableSpec.tableName}.${column.name}',
      );
    }
  }

  static Future<Set<String>> _getExistingColumns(
    Database db,
    String tableName,
  ) async {
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'PRAGMA table_info($tableName)',
    );
    return rows
        .map((row) => row['name'])
        .whereType<String>()
        .toSet();
  }
}

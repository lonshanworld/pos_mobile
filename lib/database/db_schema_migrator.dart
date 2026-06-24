import 'package:sqflite/sqflite.dart';

import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:pos_mobile/database/crash_report_DB/crash_report_DBService.dart';
import 'package:pos_mobile/database/imageModel_DB/image_DBsevice.dart';
import 'package:pos_mobile/database/itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/Item_DbStorage.dart';
import 'package:pos_mobile/database/itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/category_DbStorage.dart';
import 'package:pos_mobile/database/itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/group_DbStorage.dart';
import 'package:pos_mobile/database/itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/type_DbStorage.dart';
import 'package:pos_mobile/database/itemModel_DB/item_business_detail_DB/item_business_detail_db_service.dart';
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
              'INTEGER REFERENCES ${TxtConstants.categoryTableName}(id)',
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
          definition: 'INTEGER REFERENCES ${TxtConstants.groupTableName}(id)',
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
          name: 'categoryId',
          definition: 'INTEGER REFERENCES ${TxtConstants.categoryTableName}(id)',
        ),
        DbColumnSpec(
          name: 'groupId',
          definition: 'INTEGER REFERENCES ${TxtConstants.groupTableName}(id)',
        ),
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
        DbColumnSpec(
          name: 'need_stock',
          definition: 'INTEGER NOT NULL DEFAULT 1',
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
        DbColumnSpec(name: 'instanceLength', definition: 'REAL'),
        DbColumnSpec(name: 'instanceWidth', definition: 'REAL'),
        DbColumnSpec(name: 'instanceBatchNumber', definition: 'TEXT'),
        DbColumnSpec(name: 'instanceImei', definition: 'TEXT'),
      ],
    ),
    DbTableSpec(
      tableName: TxtConstants.itemBusinessDetailTableName,
      columns: [
        DbColumnSpec(
          name: 'itemId',
          definition:
              'INTEGER REFERENCES ${TxtConstants.itemTableName}(id) NOT NULL UNIQUE',
        ),
        DbColumnSpec(name: 'clothingColor', definition: 'TEXT'),
        DbColumnSpec(name: 'measurementLength', definition: 'REAL'),
        DbColumnSpec(name: 'measurementWidth', definition: 'REAL'),
        DbColumnSpec(name: 'measurementUnit', definition: 'TEXT'),
        DbColumnSpec(name: 'pricePerMeasurementUnit', definition: 'REAL'),
        DbColumnSpec(name: 'brand', definition: 'TEXT'),
        DbColumnSpec(name: 'deviceCategory', definition: 'TEXT'),
        DbColumnSpec(name: 'deviceColor', definition: 'TEXT'),
        DbColumnSpec(name: 'ram', definition: 'TEXT'),
        DbColumnSpec(name: 'rom', definition: 'TEXT'),
        DbColumnSpec(name: 'modelNumber', definition: 'TEXT'),
        DbColumnSpec(name: 'weightValue', definition: 'REAL'),
        DbColumnSpec(name: 'weightUnit', definition: 'TEXT'),
        DbColumnSpec(name: 'packSize', definition: 'TEXT'),
        DbColumnSpec(name: 'barcode', definition: 'TEXT'),
        DbColumnSpec(
          name: 'isOrganic',
          definition: 'INTEGER NOT NULL DEFAULT 0',
        ),
        DbColumnSpec(name: 'shelfLifeDays', definition: 'INTEGER'),
        DbColumnSpec(name: 'dosage', definition: 'TEXT'),
        DbColumnSpec(name: 'activeIngredient', definition: 'TEXT'),
        DbColumnSpec(name: 'manufacturer', definition: 'TEXT'),
      ],
    ),
  ];

  static Future<void> reconcile(Database db) async {
    try {
      await _recreateKnownTables(db);
      await _migrateIndependentCatalogs(db);
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
    await ItemBusinessDetailDbService.initItemBusinessDetailDb(db);
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
      'CREATE INDEX IF NOT EXISTS idx_item_categoryId ON ${TxtConstants.itemTableName}(categoryId);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_item_groupId ON ${TxtConstants.itemTableName}(groupId);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_item_activeStatus ON ${TxtConstants.itemTableName}(activeStatus);',
    );
  }

  static Future<void> _migrateIndependentCatalogs(Database db) async {
    await _ensureColumnIfMissing(
      db,
      TxtConstants.itemTableName,
      'categoryId',
      'INTEGER REFERENCES ${TxtConstants.categoryTableName}(id)',
    );
    await _ensureColumnIfMissing(
      db,
      TxtConstants.itemTableName,
      'groupId',
      'INTEGER REFERENCES ${TxtConstants.groupTableName}(id)',
    );

    await db.execute('''
      UPDATE ${TxtConstants.itemTableName}
      SET groupId = (
        SELECT groupId FROM ${TxtConstants.typeTableName}
        WHERE ${TxtConstants.typeTableName}.id = ${TxtConstants.itemTableName}.typeId
      )
      WHERE groupId IS NULL
    ''');

    await db.execute('''
      UPDATE ${TxtConstants.itemTableName}
      SET categoryId = (
        SELECT categoryId FROM ${TxtConstants.groupTableName}
        WHERE ${TxtConstants.groupTableName}.id = ${TxtConstants.itemTableName}.groupId
      )
      WHERE categoryId IS NULL
    ''');

    final bool needsGroupRebuild = await _isColumnRequired(
      db,
      TxtConstants.groupTableName,
      'categoryId',
    );
    final bool needsTypeRebuild = await _isColumnRequired(
      db,
      TxtConstants.typeTableName,
      'groupId',
    );

    if (!needsGroupRebuild && !needsTypeRebuild) {
      return;
    }

    await db.execute('PRAGMA foreign_keys = OFF');
    try {
      if (needsGroupRebuild) {
        await db.execute('''
          CREATE TABLE ${TxtConstants.groupTableName}_independent(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            categoryId INTEGER REFERENCES ${TxtConstants.categoryTableName}(id),
            createTime TEXT NOT NULL,
            lastUpdateTime TEXT,
            deleteTime TEXT,
            activeStatus INTEGER NOT NULL DEFAULT 1,
            description TEXT,
            createPersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL,
            deletePersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id),
            colorCode TEXT
          )
        ''');
        await db.execute('''
          INSERT INTO ${TxtConstants.groupTableName}_independent(
            id, name, categoryId, createTime, lastUpdateTime, deleteTime,
            activeStatus, description, createPersonId, deletePersonId, colorCode
          )
          SELECT
            id, name, categoryId, createTime, lastUpdateTime, deleteTime,
            activeStatus, description, createPersonId, deletePersonId, colorCode
          FROM ${TxtConstants.groupTableName}
        ''');
        await db.execute('DROP TABLE ${TxtConstants.groupTableName}');
        await db.execute(
          'ALTER TABLE ${TxtConstants.groupTableName}_independent RENAME TO ${TxtConstants.groupTableName}',
        );
      }

      if (needsTypeRebuild) {
        await db.execute('''
          CREATE TABLE ${TxtConstants.typeTableName}_independent(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            groupId INTEGER REFERENCES ${TxtConstants.groupTableName}(id),
            name TEXT NOT NULL,
            createTime TEXT NOT NULL,
            lastUpdateTime TEXT,
            deleteTime TEXT,
            activeStatus INTEGER NOT NULL DEFAULT 1,
            createPersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL,
            deletePersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id),
            colorCode TEXT,
            imageId INTEGER REFERENCES ${TxtConstants.imageTableName}(id),
            generalDescription TEXT,
            generalRestrictionId INTEGER REFERENCES ${TxtConstants.restrictionTableName}(id),
            hasExpire INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          INSERT INTO ${TxtConstants.typeTableName}_independent(
            id, groupId, name, createTime, lastUpdateTime, deleteTime,
            activeStatus, createPersonId, deletePersonId, colorCode,
            imageId, generalDescription, generalRestrictionId, hasExpire
          )
          SELECT
            id, groupId, name, createTime, lastUpdateTime, deleteTime,
            activeStatus, createPersonId, deletePersonId, colorCode,
            imageId, generalDescription, generalRestrictionId, hasExpire
          FROM ${TxtConstants.typeTableName}
        ''');
        await db.execute('DROP TABLE ${TxtConstants.typeTableName}');
        await db.execute(
          'ALTER TABLE ${TxtConstants.typeTableName}_independent RENAME TO ${TxtConstants.typeTableName}',
        );
      }
    } finally {
      await db.execute('PRAGMA foreign_keys = ON');
    }
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

  static Future<void> _ensureColumnIfMissing(
    Database db,
    String tableName,
    String columnName,
    String definition,
  ) async {
    final existingColumns = await _getExistingColumns(db, tableName);
    if (existingColumns.contains(columnName)) {
      return;
    }
    await db.execute(
      'ALTER TABLE $tableName ADD COLUMN $columnName $definition',
    );
  }

  static Future<bool> _isColumnRequired(
    Database db,
    String tableName,
    String columnName,
  ) async {
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'PRAGMA table_info($tableName)',
    );
    for (final row in rows) {
      if (row['name'] == columnName) {
        return (row['notnull'] as int? ?? 0) == 1;
      }
    }
    return false;
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

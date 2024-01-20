import 'package:path/path.dart';
import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper{
  DBHelper._();

  static final DBHelper instance = DBHelper._();

  factory DBHelper() => instance;

  Database? _database ;

  Database? get database => _database;

  Future<String> getDbPath()async{
    return join(await getDatabasesPath(), "${TxtConstants.databaseKey}.db");
  }



  @pragma("vm:entry-point")
  Future<void>initiateAllDB()async{
    String path = await getDbPath();
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: dbConfig,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void>dbConfig(Database db)async{
    await _database?.execute("PRAGMA foreign_keys = ON");
  }


  // TODO : please put all the services here
  Future<void>_onCreate(Database db, int value)async{

  }

  Future<void>_onUpgrade(Database db, int oldVersion, int newVersion)async{

  }
}

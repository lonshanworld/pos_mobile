import 'package:sqflite/sqflite.dart';

class DBHelper{
  DBHelper._();

  static final DBHelper instance = DBHelper._();

  factory DBHelper() => instance;

  Database? _database ;
}

import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const databaseName = "MyDatabase.db";
  static const databaseVersion = 1;
  static const table = 'Transaction_table';
  static const transId = 'transId';
  static const transDesc = 'transDesc';
  static const transStatus = 'transStatus';
  static const transDateTime = 'transDateTime';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, databaseName);
    return await openDatabase(path,
        version: databaseVersion, onCreate: _onCreate);
  }

// SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $transId INTEGER PRIMARY KEY,
            $transDesc TEXT NOT NULL,
            $transStatus INTEGER NOT NULL,
            $transDateTime DATETIME NOT NULL
          )
          ''');
  }

  Future<List<Map<String, dynamic>>> getErrorTransactions() async {
    Database? db = await instance.database;
    return await db!.rawQuery("SELECT * FROM Transaction_table WHERE transStatus = 'Error'");
  }

}

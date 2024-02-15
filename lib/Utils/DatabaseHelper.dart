import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../Model/ModelClass.dart';

class DatabaseHelper {

  static final _databaseName = "flutDB.db";
  static final _databaseVersion = 1;
  static final table = 'tbl_todo';

  static final id=1;
  static final title="title";
  static final description="description";
  static final status="status";
  static final timer="timer";


  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }


  _initDatabase() async {
    print("databse created");
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {

    await db.execute('''
          CREATE TABLE $table (
            id INTEGER PRIMARY KEY, $title TEXT,$description TEXT,$status TEXT,$timer TEXT
           )
          ''');

    print(db.isOpen);
    print("databse created");
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.

  Future insert(ModelClass row) async {
    // Get a reference to the database.
    final Database? db = await database;

    try {
      await db!.insert(
        table,
        row.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('Db Inserted');
    }
    catch(e){
      print('DbException'+e.toString());
    }
  }

  Future update(ModelClass row, int? id) async {
    // Get a reference to the database.
    final Database? db = await database;

    try {
      await db!.update(
        where: "id = ?",
        whereArgs: [id],
        table,
        row.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('Db Inserted');
    }
    catch(e){
      print('DbException'+e.toString());
    }
  }


  //
  // // All of the rows are returned as a list of maps, where each map is
  // // a key-value list of columns.
  // Future<List<Map<String, dynamic>>> queryAllRows() async {
  //   Database db = await instance.database;
  //   return await db.query(table);
  // }
  //
  // Future<List<Map<String, dynamic>>> queryFilterRows() async {
  //   Database db = await instance.database;
  //   return await db.rawQuery("select * from $table where stCol2='111'");
  // }
  //
  // // All of the methods (insert, query, update, delete) can also be done using
  // // raw SQL commands. This method uses a raw query to give the row count.
  // Future<int> queryRowCount() async {
  //   Database db = await instance.database;
  //   return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  // }
  //
  //
  Future<int> delete(int id) async {
    Database? db = await instance.database;
     await db!.rawDelete('DELETE FROM $table WHERE id = ?', [id]);
    return 1;
  }
}
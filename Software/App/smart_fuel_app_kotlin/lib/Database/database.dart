import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import "stats.dart";


class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "DrinkStats.db");
    return await openDatabase(path, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Client ("
          "id INTEGER PRIMARY KEY,"
          "first_name TEXT,"
          "last_name TEXT,"
          ")");
    });
  }

  newClient(Client newClient) async {
    final db = await database;
    var res = await db!.insert("Client", newClient.toMap());
    return res;
  }

  Future<Client> getClient(int id) async {
    //TODO Nullpointer Exception
    //res.isNotEmpty
    final db = await database;
    var res =await  db!.query("Client", where: "id = ?", whereArgs: [id]);
    return Client.fromMap(res.first);
  }

}

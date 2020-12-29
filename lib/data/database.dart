import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DispatcherDBProvider {
  DispatcherDBProvider();

  Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDatabase();
    return _database;
  }

  initDatabase() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path =
        join(documentsDir.path, 'dispatcher-dev.db'); // TODO! config/env

    await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 1,
      onOpen: (
        Database db,
      ) async {},
      onCreate: (
        Database db,
        int version,
      ) async {
        // Create the 'room_messages' table
        await db.execute('''
				CREATE TABLE room_messages(
					id INTEGER PRIMARY KEY,
					message_identifier TEXT NOT NULL,
					room_identifier TEXT NOT NULL,
					user_identifier TEXT NOT NULL,
					message TEXT NOT NULL,
          type INTEGER NOT NULL,
					created_date TEXT NOT NULL
				)
			  ''');
      },
    );
  }
}

import 'package:gnotes/global/global.dart';
import 'package:gnotes/models/notes.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  final int version = 1;
  Database? db;

  int shiftBy = 3;

  Future<Database?> openDb() async {
    db ??= await openDatabase(join(await getDatabasesPath(), Global.dbName),
        onCreate: (database, version) {
      database.execute(
          'CREATE TABLE ${Global.tableName}(id INTEGER PRIMARY KEY, title TEXT,description TEXT, color TEXT)');
    }, version: version);
    return db;
  }

  Future<int?> insertANote(Notes notes) async {
    Notes encryptedNote = encryptANote(notes);
    int? id = await db?.insert(
      Global.tableName,
      encryptedNote.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  Future<int?> updateANote(Notes notes) async {
    Notes encryptedNote = encryptANote(notes);
    int? id = await db?.update(
      Global.tableName,
      encryptedNote.toMap(),
      where: "id = ?",
      whereArgs: [notes.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  Future<int?> deleteANote(Notes notes) async {
    int? id = await db?.delete(
      Global.tableName,
      where: "id = ?",
      whereArgs: [notes.id],
    );

    return id;
  }

  Future<List<Notes>> getAllNotes() async {
    final List<Map<String, dynamic>>? maps = await db?.query(Global.tableName);

    return List.generate(maps!.length, (i) {
      Notes notefetched = Notes(
          id: maps[i]['id'],
          title: maps[i]['title'],
          description: maps[i]['description'],
          color: maps[i]['color']);

      Notes decrypedNote = dencryptANote(notefetched);
      return decrypedNote;
    });
  }

  String shiftString(String input, int shift) {
    // Convert the shift to a value between 0 and 25
    shift = shift % 26;
    // Create a buffer to hold the shifted characters
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < input.length; i++) {
      var char = input[i];
      if (char.contains(RegExp(r'[a-z]'))) {
        // For lowercase letters
        buffer.writeCharCode(
            (char.codeUnitAt(0) - 'a'.codeUnitAt(0) + shift) % 26 +
                'a'.codeUnitAt(0));
      } else if (char.contains(RegExp(r'[A-Z]'))) {
        // For uppercase letters
        buffer.writeCharCode(
            (char.codeUnitAt(0) - 'A'.codeUnitAt(0) + shift) % 26 +
                'A'.codeUnitAt(0));
      } else {
        // For non-alphabet characters, keep them as they are
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  Notes encryptANote(Notes note) {
    String shiftedTitle = shiftString(note.title, shiftBy);
    String shiftedDesc = shiftString(note.description, shiftBy);

    return Notes(
        title: shiftedTitle,
        description: shiftedDesc,
        color: note.color,
        id: note.id);
  }

  Notes dencryptANote(Notes note) {
    String shiftedTitle = shiftString(note.title, (shiftBy * -1));
    String shiftedDesc = shiftString(note.description, (shiftBy * -1));

    return Notes(
        title: shiftedTitle,
        description: shiftedDesc,
        color: note.color,
        id: note.id);
  }

  Future testDb() async {
    db = await openDb();
    await db?.execute(
        'INSERT INTO ${Global.tableName} VALUES (0, "Note title", "Note description", "0xff000000")');

    List? lists = await db?.rawQuery('select * from ${Global.tableName}');

    print(lists?.toString());
  }
}

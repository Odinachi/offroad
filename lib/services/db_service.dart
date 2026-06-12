import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'offroad_chat.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chat_sessions(
        id TEXT PRIMARY KEY,
        title TEXT,
        modelName TEXT,
        createdAt INTEGER,
        updatedAt INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages(
        id TEXT PRIMARY KEY,
        sessionId TEXT,
        role TEXT,
        content TEXT,
        hasImage INTEGER,
        createdAt INTEGER,
        FOREIGN KEY(sessionId) REFERENCES chat_sessions(id) ON DELETE CASCADE
      )
    ''');
  }

  // ── Session Methods ──

  Future<void> createSession({
    required String id,
    required String title,
    required String modelName,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert('chat_sessions', {
      'id': id,
      'title': title,
      'modelName': modelName,
      'createdAt': now,
      'updatedAt': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateSessionModel(String id, String modelName) async {
    final db = await database;
    await db.update(
      'chat_sessions',
      {'modelName': modelName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSessionTime(String id) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      'chat_sessions',
      {'updatedAt': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSessionTitle(String id, String title) async {
    final db = await database;
    await db.update(
      'chat_sessions',
      {'title': title},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getSessions({
    int limit = 10,
    int offset = 0,
  }) async {
    final db = await database;
    return await db.query(
      'chat_sessions',
      orderBy: 'updatedAt DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<void> deleteSession(String id) async {
    final db = await database;
    await db.delete('chat_sessions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteSessionsByModel(String modelName) async {
    final db = await database;
    await db.transaction((txn) async {
      final sessions = await txn.query(
        'chat_sessions',
        columns: ['id'],
        where: 'modelName = ?',
        whereArgs: [modelName],
      );
      final sessionIds = sessions.map((s) => s['id'] as String).toList();
      if (sessionIds.isNotEmpty) {
        final placeholders = List.filled(sessionIds.length, '?').join(',');
        await txn.delete(
          'chat_messages',
          where: 'sessionId IN ($placeholders)',
          whereArgs: sessionIds,
        );
        await txn.delete(
          'chat_sessions',
          where: 'modelName = ?',
          whereArgs: [modelName],
        );
      }
    });
  }

  // ── Message Methods ──

  Future<void> addMessage({
    required String id,
    required String sessionId,
    required String role,
    required String content,
    bool hasImage = false,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert('chat_messages', {
      'id': id,
      'sessionId': sessionId,
      'role': role,
      'content': content,
      'hasImage': hasImage ? 1 : 0,
      'createdAt': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    // Also update the session time so it bumps to the top
    await updateSessionTime(sessionId);
  }

  Future<List<Map<String, dynamic>>> getMessages(
    String sessionId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await database;
    return await db.query(
      'chat_messages',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );
  }
}

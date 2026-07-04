import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqliteDatabaseService {
  static const String _fileName = 'igreja_estoque.db';
  static const int _version = 1;

  Database? _db;
  Future<Database>? _connecting;

  Future<Database> get database {
    final current = _db;

    if (current != null && current.isOpen) {
      return Future.value(current);
    }

    return _connecting ??= _connect();
  }

  Future<Database> _connect() async {
    sqfliteFfiInit();

    final factory = databaseFactoryFfi;
    final path = p.join(await factory.getDatabasesPath(), _fileName);

    final db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _version,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _createSchema,
      ),
    );

    _db = db;

    return db;
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE itens (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        nome              TEXT NOT NULL,
        categoria         TEXT NOT NULL,
        unidade           TEXT NOT NULL DEFAULT 'un',
        quantidade        INTEGER NOT NULL DEFAULT 0 CHECK (quantidade >= 0),
        quantidade_minima INTEGER NOT NULL DEFAULT 0 CHECK (quantidade_minima >= 0),
        descricao         TEXT,
        criado_em         TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE movimentacoes (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id     INTEGER NOT NULL REFERENCES itens (id) ON DELETE CASCADE,
        tipo        TEXT NOT NULL CHECK (tipo IN ('entrada', 'saida')),
        quantidade  INTEGER NOT NULL CHECK (quantidade > 0),
        responsavel TEXT NOT NULL,
        observacao  TEXT,
        criado_em   TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE tickets (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo       TEXT NOT NULL UNIQUE,
        evento       TEXT NOT NULL,
        participante TEXT NOT NULL,
        valor        REAL NOT NULL DEFAULT 0 CHECK (valor >= 0),
        status       TEXT NOT NULL DEFAULT 'valido'
                     CHECK (status IN ('valido', 'utilizado', 'cancelado')),
        criado_em    TEXT NOT NULL DEFAULT (datetime('now')),
        utilizado_em TEXT
      )
    ''');
  }

  Future<void> dispose() async {
    await _db?.close();

    _db = null;
    _connecting = null;
  }
}

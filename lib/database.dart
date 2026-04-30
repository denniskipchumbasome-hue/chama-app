import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ChamaDatabase {
  static final ChamaDatabase _instance = ChamaDatabase._internal();
  factory ChamaDatabase() => _instance;
  ChamaDatabase._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db!= null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'chama.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        id_number TEXT,
        savings_balance REAL DEFAULT 0,
        welfare_balance REAL DEFAULT 0,
        shares INTEGER DEFAULT 0,
        photo_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        member_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        mpesa_code TEXT,
        notes TEXT,
        FOREIGN KEY (member_id) REFERENCES members (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE loans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        member_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        interest_rate REAL DEFAULT 0.01,
        balance REAL NOT NULL,
        date_issued TEXT NOT NULL,
        FOREIGN KEY (member_id) REFERENCES members (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        reserve_percent REAL DEFAULT 0.10,
        interest_rate REAL DEFAULT 0.05,
        project_percent REAL DEFAULT 0.20,
        monthly_contribution REAL DEFAULT 500.0,
        treasurer_pin TEXT DEFAULT '1234',
        last_backup_date TEXT DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE activity_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT NOT NULL,
        details TEXT,
        timestamp TEXT NOT NULL,
        user TEXT DEFAULT 'Treasurer'
      )
    ''');

    await db.insert('settings', {'id': 1});
  }

  Future<int> insertMember(Map<String, dynamic> member) async {
    final db = await database;
    return await db.insert('members', member);
  }

  Future<List<Map<String, dynamic>>> getMembers() async {
    final db = await database;
    return await db.query('members');
  }

  Future<int> updateMember(Map<String, dynamic> member) async {
    final db = await database;
    return await db.update('members', member, where: 'id =?', whereArgs: [member['id']]);
  }

  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getMemberLedger(int memberId) async {
    final db = await database;
    return await db.query('transactions', where: 'member_id =?', whereArgs: [memberId], orderBy: 'date ASC');
  }

  Future<int> insertLoan(Map<String, dynamic> loan) async {
    final db = await database;
    return await db.insert('loans', loan);
  }

  Future<List<Map<String, dynamic>>> getLoans() async {
    final db = await database;
    return await db.query('loans');
  }

  Future<int> updateLoanBalance(int loanId, double newBalance) async {
    final db = await database;
    return await db.update('loans', {'balance': newBalance}, where: 'id =?', whereArgs: [loanId]);
  }

  Future<Map<String, dynamic>> getSettings() async {
    final db = await database;
    final result = await db.query('settings', where: 'id = 1');
    return result.first;
  }

  Future<int> updateSettings(Map<String, dynamic> settings) async {
    final db = await database;
    return await db.update('settings', settings, where: 'id = 1');
  }

  Future<void> updateLastBackupDate() async {
    final db = await database;
    await db.update('settings', {'last_backup_date': DateTime.now().toIso8601String()}, where: 'id = 1');
  }

  Future<bool> isBackupOverdue() async {
    final settings = await getSettings();
    String? lastBackup = settings['last_backup_date'] as String?;
    if (lastBackup == null || lastBackup.isEmpty) return true;
    DateTime lastDate = DateTime.parse(lastBackup);
    Duration difference = DateTime.now().difference(lastDate);
    return difference.inDays >= 30;
  }

  Future<int> logActivity(String action, {String details = '', String user = 'Treasurer'}) async {
    final db = await database;
    return await db.insert('activity_log', {
      'action': action,
      'details': details,
      'timestamp': DateTime.now().toIso8601String(),
      'user': user,
    });
  }

  Future<List<Map<String, dynamic>>> getActivityLogs() async {
    final db = await database;
    return await db.query('activity_log', orderBy: 'timestamp DESC', limit: 50);
  }

  Future<void> closeDatabase() async {
    final db = _db;
    if (db!= null) {
      await db.close();
      _db = null;
    }
  }
}

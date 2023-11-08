import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:point_of_sale_app/database/user_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const dbName = 'slieww.db';
  static const dbVersion = 1;

  static final DatabaseHelper instance = DatabaseHelper();

  static Database? _database;

  Future<Database?> get database async {
    _database ??= await initDB();
    return _database;
  }

  initDB() async {
    Directory directory = await getApplicationCacheDirectory();
    String path = join(directory.path, dbName);
    return await openDatabase(path, version: dbVersion, onCreate: onCreate);
  }

  Future onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE  Products (
      productId INTEGER PRIMARY KEY AUTOINCREMENT,
      category TEXT ,
      prodName TEXT NOT NULL,
      barCode TEXT NOT NULL,
      unitCost INT,
      unitPrice INT,
      stock INT NOT NULL,
      companyName TEXT,
      supplierName TEXT
    )''');
    await db.execute('''
    CREATE TABLE Ingredients (
      ingredientId INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      unitCost INT,
      stock INT NOT NULL,
      companyName TEXT,
      supplierName TEXT
    ) ''');
    await db.execute('''
    CREATE TABLE  OrderItems (
      orderItemId INTEGER PRIMARY KEY AUTOINCREMENT,
      prodName TEXT NOT NULL,
      price INT NOT NULL,
      quantity INT NOT NULL,
      productId INTEGER,
      FOREIGN KEY (productId) REFERENCES Products (productId)
    )''');
    await db.execute('''
    CREATE TABLE Size (
      sizeId INTEGER PRIMARY KEY AUTOINCREMENT,
      size TEXT,
      unitCost INT,
      productId INTEGER,
      FOREIGN KEY (productId) REFERENCES Products (productId)
    ) ''');
    await db.execute('''
    CREATE TABLE Users (
      userId INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      userName TEXT,
      password VARCHAR,
      isAdmin BOOL
    ) ''');
  }

  insertRecord(dbTable, Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db?.insert(dbTable, row);
  }

  Future<int?> deleteRecord(
      {required String dbTable, required String where, required int id}) async {
    final Database? db = await instance.database;
    return await db?.delete(dbTable, where: where, whereArgs: [id]);
  }

  Future<int?> updateRecord(
      dbTable, Map<String, dynamic> updatedRow, String where, int id) async {
    final Database? db = await instance.database;
    return await db?.update(
      dbTable,
      updatedRow,
      where: where,
      whereArgs: [id],
    );
  }

  Future<int?> updateOrderItems(
      dbTable, Map<String, dynamic> updatedRow, int id) async {
    final Database? db = await instance.database;
    return await db?.update(
      dbTable,
      updatedRow,
      where: 'orderItemId = ?',
      whereArgs: [id],
    );
  }

  Future<void> changeQuantity(int orderId, bool decrement) async {
    final int newQuantity;
    if (decrement == false) {
      newQuantity = (await getQuantity(orderId) + 1);
    } else {
      newQuantity = await getQuantity(orderId) - 1;
    }
    final Database? db = await instance.database;
    await db?.update(
      'OrderItems',
      {'quantity': newQuantity},
      where: 'orderItemId = ?',
      whereArgs: [orderId],
    );
  }

  Future<List<Map<String, Object?>>?> getRecord(
    String dbTable,
    String where,
    int id,
  ) async {
    final Database? db = await instance.database;
    return await db?.query(
      dbTable,
      where: where,
      whereArgs: [id],
    );
  }

  Future<UserModel?> loginCheck(String username, String password) async {
    final Database? db = await instance.database;
    final List<Map<String, Object?>>? result = await db?.query(
      'Users',
      where: 'userName = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result!.isNotEmpty) {
      // print('resss=${result}');
      // print('resss=${result[0]}');
      // print('Model=${UserModel.fromMap(result[0])}');
      return UserModel.fromMap(result[0]);
    } else {
      return null;
    }
  }

  Future<int> getQuantity(int orderItemId) async {
    final Database? db = await instance.database;
    final List<Map<String, Object?>>? result = await db?.query(
      'OrderItems',
      columns: ['quantity'],
      where: 'orderItemId = ?',
      whereArgs: [orderItemId],
    );
    if (result!.isNotEmpty) {
      // print(" quantity: ${result[0]['quantity']}");
      return (result[0]['quantity'] ?? 0) as int;
    } else {
      return 0;
    }
  }

  Future<int?> productCount(int productId) async {
    final Database? db = await instance.database;
    final result = await db?.rawQuery(
        'SELECT COUNT(*) as count FROM OrderItems WHERE productId = ?',
        [productId]);

    if (result != null && result.isNotEmpty) {
      final count = Sqflite.firstIntValue(result);
      return count;
    }
    return -1;
  }

  Future<void> truncateTable(String dbTable) async {
    final Database? db = await instance.database;
    await db?.rawDelete('DELETE FROM $dbTable');
  }

  Future<List<Map<String, dynamic>>?> queryDatabase(dbTable) async {
    Database? db = await instance.database;
    return await db?.query(dbTable);
  }

  Future<void> deleteDatabase() async {
    Directory directory = await getApplicationCacheDirectory();
    String path = join(directory.path, dbName);
    return databaseFactory.deleteDatabase(path);
  }
}

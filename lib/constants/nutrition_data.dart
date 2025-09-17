import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NutritionDatabaseHelper {
  static final NutritionDatabaseHelper _instance =
  NutritionDatabaseHelper._internal();
  factory NutritionDatabaseHelper() => _instance;

  static Database? _database;

  NutritionDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nutrition_history.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE nutrition_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            calories TEXT NOT NULL,
            protein TEXT,
            fat TEXT,
            carbs TEXT,
            goodForWeightLoss INTEGER,
            goodForHealth INTEGER,
            healthBenefits TEXT,
            mealType TEXT,
            timestamp TEXT NOT NULL
          )
        ''');
      },
    );
  }


  Future<void> saveNutritionData(Map<String, dynamic> data) async {
    final db = await database;
    final now = DateTime.now();



    final nutritionEntry = {
      "name": data["nameOfFood"] ?? "",
      "calories": data["calories_kcal"] ?? "",
      "protein": data["protein_g"] ?? "",
      "fat": data["fat_g"] ?? "",
      "carbs": data["carbs_g"] ?? "",
      "goodForWeightLoss": (data["goodForWeightLoss"] == true) ? 1 : 0,
      "goodForHealth": (data["goodForHealth"] == true) ? 1 : 0,
      "healthBenefits": "",

      "timestamp": now.toIso8601String(),
    };

    await db.insert(
      'nutrition_history',
      nutritionEntry,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<List<Map<String, dynamic>>> getNutritionHistory() async {
    final db = await database;
    final result = await db.query('nutrition_history', orderBy: "timestamp DESC");
    return result;
  }


  Future<void> clearNutritionHistory() async {
    final db = await database;
    await db.delete('nutrition_history');
  }


  Future<List<Map<String, dynamic>>> getWeightLossFoods() async {
    final db = await database;
    return await db.query(
      'nutrition_history',
      where: 'goodForWeightLoss = ?',
      whereArgs: [1],
      orderBy: "timestamp DESC",
    );
  }


  Future<List<Map<String, dynamic>>> getHealthyFoods() async {
    final db = await database;
    return await db.query(
      'nutrition_history',
      where: 'goodForHealth = ?',
      whereArgs: [1],
      orderBy: "timestamp DESC",
    );
  }


  Future<List<Map<String, dynamic>>> getHighProteinFoods() async {
    final db = await database;
    final result = await db.query('nutrition_history');
    return result.where((row) {
      final protein = row["protein"] != null
          ? int.tryParse(row["protein"].toString().split('-').first.trim()) ?? 0
          : 0;
      return protein >= 20;
    }).toList();
  }


  Future<List<Map<String, dynamic>>> getTodayNutrition() async {
    final db = await database;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).toIso8601String();
    final end = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

    return await db.query(
      'nutrition_history',
      where: "timestamp BETWEEN ? AND ?",
      whereArgs: [start, end],
      orderBy: "timestamp DESC",
    );
  }


  Future<List<Map<String, dynamic>>> getThisWeekNutrition() async {
    final db = await database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day).toIso8601String();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    return await db.query(
      'nutrition_history',
      where: "timestamp BETWEEN ? AND ?",
      whereArgs: [start, end],
      orderBy: "timestamp DESC",
    );
  }


  Future<List<Map<String, dynamic>>> getLast7DaysNutrition() async {
    final db = await database;
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7)).toIso8601String();
    final end = now.toIso8601String();

    return await db.query(
      'nutrition_history',
      where: "timestamp BETWEEN ? AND ?",
      whereArgs: [start, end],
      orderBy: "timestamp DESC",
    );
  }


  Future<List<Map<String, dynamic>>> getNutritionByDateRange(
      DateTime startDate, DateTime endDate) async {
    final db = await database;
    final start = DateTime(startDate.year, startDate.month, startDate.day).toIso8601String();
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59).toIso8601String();

    return await db.query(
      'nutrition_history',
      where: "timestamp BETWEEN ? AND ?",
      whereArgs: [start, end],
      orderBy: "timestamp DESC",
    );
  }


  Future<List<Map<String, dynamic>>> getAllMealsSorted() async {
    final db = await database;
    return await db.query(
      'nutrition_history',
      orderBy: 'timestamp DESC',
    );
  }
}

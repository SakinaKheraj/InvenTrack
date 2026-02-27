// lib/db/database_helper.dart

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/grocery_item.dart';
import '../models/recipe.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, Constants.databaseName);

    return await openDatabase(
      path,
      version: 2, // bumped from 1 → 2
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${Constants.tableName}(
        ${Constants.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Constants.name} TEXT NOT NULL,
        ${Constants.category} TEXT NOT NULL,
        ${Constants.quantity} REAL NOT NULL,
        ${Constants.unit} TEXT NOT NULL,
        ${Constants.expiryDate} TEXT NOT NULL,
        ${Constants.imagePath} TEXT,
        ${Constants.createdAt} TEXT NOT NULL
      )
      ''');
    await _createRecipeHistoryTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createRecipeHistoryTable(db);
    }
  }

  Future<void> _createRecipeHistoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS recipe_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        ingredients_json TEXT NOT NULL,
        instructions_json TEXT NOT NULL,
        generated_at TEXT NOT NULL
      )
    ''');
  }

  // --- Grocery CRUD ---

  Future<int> insertItem(GroceryItem item) async {
    final db = await database;
    return await db.insert(
      Constants.tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<GroceryItem>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      Constants.tableName,
      orderBy: '${Constants.expiryDate} ASC',
    );
    return List.generate(maps.length, (i) => GroceryItem.fromMap(maps[i]));
  }

  Future<int> updateItem(GroceryItem item) async {
    final db = await database;
    return await db.update(
      Constants.tableName,
      item.toMap(),
      where: '${Constants.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      Constants.tableName,
      where: '${Constants.id} = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllGroceries() async {
    final db = await database;
    await db.delete(Constants.tableName);
    debugPrint(' All grocery records deleted from the database.');
  }

  // --- Recipe History CRUD ---

  Future<Recipe> insertRecipe(Recipe recipe) async {
    final db = await database;
    final id = await db.insert(
      'recipe_history',
      recipe.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return recipe.copyWith(id: id);
  }

  Future<List<Recipe>> getRecipeHistory() async {
    final db = await database;
    final maps = await db.query('recipe_history', orderBy: 'generated_at DESC');
    return maps.map((m) => Recipe.fromDbMap(m)).toList();
  }

  Future<void> deleteRecipe(int id) async {
    final db = await database;
    await db.delete('recipe_history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllRecipes() async {
    final db = await database;
    await db.delete('recipe_history');
    debugPrint(' All recipe history deleted.');
  }

  Future<void> closeDb() async {
    final db = await database;
    db.close();
    _database = null;
  }
}

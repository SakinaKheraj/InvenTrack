import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/recipe.dart';

class RecipeProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Recipe> _history = [];
  bool _isLoading = false;

  List<Recipe> get history => _history;
  bool get isLoading => _isLoading;

  RecipeProvider() {
    loadHistory();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    _history = await _dbHelper.getRecipeHistory();
    _isLoading = false;
    notifyListeners();
  }

  /// Saves a freshly generated recipe and prepends it to the history list.
  Future<Recipe> addRecipe(Recipe recipe) async {
    final saved = await _dbHelper.insertRecipe(recipe);
    _history.insert(0, saved);
    notifyListeners();
    return saved;
  }

  Future<void> deleteRecipe(int id) async {
    await _dbHelper.deleteRecipe(id);
    _history.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  Future<void> deleteAllRecipes() async {
    await _dbHelper.deleteAllRecipes();
    _history.clear();
    notifyListeners();
  }
}

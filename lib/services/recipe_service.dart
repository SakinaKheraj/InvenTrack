// lib/services/recipe_service.dart

import '../models/recipe.dart';
import '../models/grocery_item.dart';
import '../data/recipes.dart';

/// A utility class that matches an inventory of grocery items against a
/// static set of recipes. All operations are performed in memory so the
/// app remains fully offline.
class RecipeService {
  /// Returns the list of recipes where *every* ingredient is available in
  /// [items] with at least the required quantity. Matching is done using a
  /// case‑insensitive comparison of ingredient name to grocery item name.
  static List<Recipe> findMatchingRecipes(List<GroceryItem> items) {
    return kAllRecipes.where((recipe) {
      return recipe.ingredients.every((ingredient) {
        GroceryItem? match;
        for (var item in items) {
          if (item.name.toLowerCase() == ingredient.name.toLowerCase()) {
            match = item;
            break;
          }
        }
        if (match == null) return false;
        return match.quantity >= ingredient.quantity;
      });
    }).toList();
  }

  /// For convenience a method that returns recipes that are *almost* doable –
  /// the user is missing only one ingredient. Useful for showing partial
  /// suggestions in the UI later.
  static List<Recipe> findNearMatches(List<GroceryItem> items) {
    return kAllRecipes.where((recipe) {
      int missing = 0;
      for (var ingredient in recipe.ingredients) {
        GroceryItem? match;
        for (var item in items) {
          if (item.name.toLowerCase() == ingredient.name.toLowerCase()) {
            match = item;
            break;
          }
        }
        if (match == null || match.quantity < ingredient.quantity) {
          missing++;
          if (missing > 1) break;
        }
      }
      return missing == 1;
    }).toList();
  }
}

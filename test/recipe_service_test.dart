import 'package:flutter_test/flutter_test.dart';
import 'package:iventrack/models/grocery_item.dart';
import 'package:iventrack/services/recipe_service.dart';

void main() {
  group('RecipeService', () {
    test('findMatchingRecipes returns appropriate recipes', () {
      // provide all ingredients for omelette (eggs, milk, salt)
      final items = [
        GroceryItem(
          id: 1,
          name: 'Eggs',
          category: 'Dairy',
          quantity: 2,
          unit: 'pcs',
          expiryDate: DateTime.now().add(Duration(days: 5)),
          createdAt: DateTime.now(),
        ),
        GroceryItem(
          id: 2,
          name: 'Milk',
          category: 'Beverages',
          quantity: 1,
          unit: 'L',
          expiryDate: DateTime.now().add(Duration(days: 5)),
          createdAt: DateTime.now(),
        ),
        GroceryItem(
          id: 3,
          name: 'Salt',
          category: 'Pantry',
          quantity: 1,
          unit: 'tsp',
          expiryDate: DateTime.now().add(Duration(days: 365)),
          createdAt: DateTime.now(),
        ),
      ];

      final matches = RecipeService.findMatchingRecipes(items);
      expect(matches.isNotEmpty, true);
      expect(matches.any((r) => r.name == 'Omelette'), isTrue);
    });

    test('findNearMatches returns empty when only eggs are available', () {
      final items = [
        GroceryItem(
          id: 1,
          name: 'Eggs',
          category: 'Dairy',
          quantity: 2,
          unit: 'pcs',
          expiryDate: DateTime.now().add(Duration(days: 5)),
          createdAt: DateTime.now(),
        ),
      ];

      final near = RecipeService.findNearMatches(items);
      expect(near.isEmpty, true);
    });
  });
}

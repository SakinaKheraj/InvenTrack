// lib/data/recipes.dart

import '../models/recipe.dart';

final List<Recipe> kAllRecipes = [
  Recipe(
    name: 'Omelette',
    ingredients: [
      const RecipeIngredient(name: 'Eggs', quantity: 2, unit: 'pcs'),
      const RecipeIngredient(name: 'Milk', quantity: 0.25, unit: 'L'),
      const RecipeIngredient(name: 'Salt', quantity: 1, unit: 'tsp'),
    ],
    instructions: ['Whisk eggs and milk.', 'Heat pan.', 'Pour and cook.'],
  ),
  Recipe(
    name: 'Pancakes',
    ingredients: [
      const RecipeIngredient(name: 'Flour', quantity: 0.5, unit: 'kg'),
      const RecipeIngredient(name: 'Eggs', quantity: 1, unit: 'pcs'),
      const RecipeIngredient(name: 'Milk', quantity: 0.3, unit: 'L'),
    ],
    instructions: ['Mix ingredients.', 'Cook on griddle.'],
  ),
  Recipe(
    name: 'Fruit Salad',
    ingredients: [
      const RecipeIngredient(name: 'Apple', quantity: 1, unit: 'pcs'),
      const RecipeIngredient(name: 'Banana', quantity: 1, unit: 'pcs'),
      const RecipeIngredient(name: 'Orange', quantity: 1, unit: 'pcs'),
    ],
    instructions: ['Chop fruits.', 'Mix in a bowl.'],
  ),
  Recipe(
    name: 'Grilled Cheese Sandwich',
    ingredients: [
      const RecipeIngredient(name: 'Bread', quantity: 2, unit: 'slices'),
      const RecipeIngredient(name: 'Cheese', quantity: 1, unit: 'slice'),
      const RecipeIngredient(name: 'Butter', quantity: 1, unit: 'tbsp'),
    ],
    instructions: [
      'Butter bread.',
      'Place cheese between slices.',
      'Grill until melted.',
    ],
  ),
  Recipe(
    name: 'Tomato Pasta',
    ingredients: [
      const RecipeIngredient(name: 'Pasta', quantity: 0.2, unit: 'kg'),
      const RecipeIngredient(name: 'Tomato Sauce', quantity: 0.1, unit: 'kg'),
      const RecipeIngredient(name: 'Salt', quantity: 1, unit: 'tsp'),
    ],
    instructions: ['Boil pasta.', 'Drain and mix with sauce.'],
  ),
];

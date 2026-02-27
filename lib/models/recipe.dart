// lib/models/recipe.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';

@immutable
class RecipeIngredient {
  final String name;
  final double quantity;
  final String unit;

  const RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'quantity': quantity, 'unit': unit};
  }

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      name: map['name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String,
    );
  }
}

@immutable
class Recipe {
  final int? id; // DB row id (null until saved)
  final String name;
  final List<RecipeIngredient> ingredients;
  final List<String> instructions;
  final DateTime generatedAt; // when the recipe was created

  Recipe({
    this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  // Used when parsing Gemini JSON response (no id/generatedAt yet)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ingredients': ingredients.map((x) => x.toMap()).toList(),
      'instructions': instructions,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      name: map['name'] as String,
      ingredients: List<RecipeIngredient>.from(
        (map['ingredients'] as List).map(
          (x) => RecipeIngredient.fromMap(x as Map<String, dynamic>),
        ),
      ),
      instructions: List<String>.from(map['instructions'] as List),
    );
  }

  // Serialise for SQLite storage
  Map<String, dynamic> toDbMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'ingredients_json': jsonEncode(
        ingredients.map((i) => i.toMap()).toList(),
      ),
      'instructions_json': jsonEncode(instructions),
      'generated_at': generatedAt.toIso8601String(),
    };
  }

  // Deserialise from SQLite row
  factory Recipe.fromDbMap(Map<String, dynamic> map) {
    final ingredientsList =
        (jsonDecode(map['ingredients_json'] as String) as List)
            .map((e) => RecipeIngredient.fromMap(e as Map<String, dynamic>))
            .toList();
    final instructionsList = List<String>.from(
      jsonDecode(map['instructions_json'] as String) as List,
    );
    return Recipe(
      id: map['id'] as int?,
      name: map['name'] as String,
      ingredients: ingredientsList,
      instructions: instructionsList,
      generatedAt: DateTime.parse(map['generated_at'] as String),
    );
  }

  Recipe copyWith({int? id}) => Recipe(
    id: id ?? this.id,
    name: name,
    ingredients: ingredients,
    instructions: instructions,
    generatedAt: generatedAt,
  );
}

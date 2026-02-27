// lib/utils/constants.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  // Database constants
  static const String databaseName = 'grocytrack_db.db';
  static const String tableName = 'groceries';

  // Column names
  static const String id = 'id';
  static const String name = 'name';
  static const String category = 'category';
  static const String quantity = 'quantity';
  static const String unit = 'unit';
  static const String expiryDate = 'expiry_date';
  static const String imagePath = 'image_path';
  static const String createdAt = 'created_at';

  // Categories
  static const List<String> categories = [
    'Dairy',
    'Produce',
    'Meat',
    'Frozen',
    'Pantry',
    'Snacks',
    'Beverages',
    'Other',
  ];

  // Units
  static const List<String> units = [
    'pcs',
    'kg',
    'g',
    'L',
    'ml',
    'pack',
    'bottle',
    'box',
  ];

  // AI Constants — loaded from .env at runtime
  static String get geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? 'YOUR_GEMINI_API_KEY_HERE';
}

# 🧺 InvenTrack

> **A smart pantry & grocery inventory manager built with Flutter — know what you have, reduce waste, and let AI cook for you.**

---

## 📱 Screenshots

<!-- > _Add screenshots here once running on a device._ -->

---

## ✨ Features

### 🗃️ Pantry Inventory Management
- Add grocery items with **name, quantity, unit, category, and expiry date**
- Attach a **photo** to each item via the device camera or gallery
- **Swipe to delete** items directly from the list
- **Edit** any item's details at any time
- **Mark items as used** — enter the amount consumed and the quantity updates automatically; items at zero are removed

### ⚠️ Expiry Tracking & Alerts
- Color-coded expiry indicators on every item card:
  - 🟢 **Green** — plenty of time left
  - 🟠 **Orange** — expiring within 7 days
  - 🔴 **Red** — already expired
- **Low-stock warnings** — items with quantity ≤ 1 are highlighted with a distinct border and badge
- **Local push notifications** scheduled at the time an item is added or updated to remind you before it expires

### 🔀 Smart Sorting
- Sort your pantry by:
  - **Expiry Date** (default, nearest first)
  - **Name** (A–Z)
  - **Quantity** (low to high)
- Sort preference is preserved across sessions

### 🤖 AI Kitchen — Gemini-Powered Recipe Generator
- Tap **AI Kitchen** to let Google Gemini generate a recipe using **exactly what's in your pantry**
- Automatically discovers the best available Gemini model for your API key (prefers `gemini-2.0-flash`, falls back gracefully)
- Handles quota limits — automatically retries with alternative models on `429` responses
- Generated recipes include:
  - Recipe name
  - Full ingredient list with quantities and units
  - Step-by-step cooking instructions

### 📜 Recipe History
- Every AI-generated recipe is **automatically saved** to a local SQLite database
- Browse your full generation history from the **History** screen (clock icon in AI Kitchen)
- Tap any past recipe to view its full details again
- **Delete** individual recipes or clear the entire history
- A green dot badge on the history icon indicates saved recipes exist

### ⚙️ Settings
- **Delete all grocery records** — with a confirmation dialog, removes all items from local storage

---

## 🏗️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev) (Dart, SDK ^3.9.2) |
| State Management | [Provider](https://pub.dev/packages/provider) `^6.1.1` |
| Local Database | [sqflite](https://pub.dev/packages/sqflite) `^2.3.0` |
| AI / LLM | [Google Gemini API](https://aistudio.google.com) via HTTP (`http` package) |
| Notifications | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) `^19.4.2` |
| Image Picking | [image_picker](https://pub.dev/packages/image_picker) `^1.0.0` |
| Date Formatting | [intl](https://pub.dev/packages/intl) `^0.18.1` |
| Timezone Support | [timezone](https://pub.dev/packages/timezone) `^0.10.1` |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.9.2` — [Install Flutter](https://docs.flutter.dev/get-started/install)
- A Google Gemini API key — free tier available at [aistudio.google.com](https://aistudio.google.com)

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/your-username/InvenTrack.git
cd InvenTrack

# 2. Install dependencies
flutter pub get

# 3. Add your Gemini API key
#    Open lib/utils/constants.dart and set:
#    static const String geminiApiKey = 'YOUR_API_KEY_HERE';

# 4. Run the app
flutter run
```

> **Supported platforms:** Android, iOS, Windows _(tested)_

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point, MultiProvider setup
├── models/
│   ├── grocery_item.dart        # GroceryItem data model
│   └── recipe.dart              # Recipe + RecipeIngredient models (with DB serialization)
├── providers/
│   ├── grocery_provider.dart    # ChangeNotifier for pantry state
│   └── recipe_provider.dart     # ChangeNotifier for recipe history state
├── db/
│   └── database_helper.dart     # SQLite helper (groceries + recipe_history tables)
├── services/
│   ├── ai_recipe_service.dart   # Gemini API integration with model discovery & fallback
│   ├── notification_service.dart# Local push notification scheduling
│   └── recipe_service.dart      # Offline recipe matching helper
├── screens/
│   ├── splash_screen.dart
│   ├── main_screen.dart         # Bottom nav shell
│   ├── home_screen.dart         # Pantry list
│   ├── add_item_screen.dart     # Add new grocery item
│   ├── edit_item_screen.dart    # Edit / delete existing item
│   ├── recipe_screen.dart       # AI Kitchen landing + generation
│   ├── recipe_history_screen.dart # Saved AI recipe history
│   └── settings_screen.dart
├── widgets/
│   └── grocery_card.dart        # Reusable pantry item card with consume dialog
├── data/
│   └── recipes.dart             # Static offline recipe definitions
└── utils/
    └── constants.dart           # DB names, column constants, categories, units, API key
```

---

## 🗄️ Database Schema

### `groceries` table
| Column | Type | Description |
|---|---|---|
| `id` | INTEGER PK | Auto-increment |
| `name` | TEXT | Item name |
| `category` | TEXT | e.g. Dairy, Produce |
| `quantity` | REAL | Amount remaining |
| `unit` | TEXT | e.g. kg, pcs, L |
| `expiry_date` | TEXT | ISO-8601 date string |
| `image_path` | TEXT | Local file path (nullable) |
| `created_at` | TEXT | ISO-8601 datetime |

### `recipe_history` table _(added in DB version 2)_
| Column | Type | Description |
|---|---|---|
| `id` | INTEGER PK | Auto-increment |
| `name` | TEXT | Recipe name |
| `ingredients_json` | TEXT | JSON array of ingredients |
| `instructions_json` | TEXT | JSON array of steps |
| `generated_at` | TEXT | ISO-8601 datetime |

---

## 🧠 State Management Architecture

InvenTrack uses the **Provider** pattern with two `ChangeNotifier` classes:

```
MultiProvider
├── GroceryProvider   → pantry items, sorting, loading state
└── RecipeProvider    → AI recipe history (load, add, delete)
```

- **`GroceryProvider`** — loaded at startup, persists all CRUD operations to SQLite and schedules expiry notifications
- **`RecipeProvider`** — automatically saves each AI-generated recipe to `recipe_history` table; history is loaded at startup

---

## 🔑 API Key Security

> ⚠️ **Do not commit your real Gemini API key to a public repository.**

The API key is currently stored in `lib/utils/constants.dart`. For production or open-source use, consider loading it from:
- A `.env` file (using `flutter_dotenv`)
- A secrets manager
- Firebase Remote Config

---

## 📄 License

This project is open source. See [LICENSE](LICENSE) for details.

---

<p align="center">Built with ❤️ using Flutter & Google Gemini</p>

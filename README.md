# 🧺 InvenTrack

> **A smart pantry & grocery inventory manager built with Flutter — know what you have, reduce waste, and let AI cook for you.**

---

<!-- ## 📱 Screenshots

<!-- _Add screenshots here once running on a device._

--- -->

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
- **Local push notifications** scheduled when an item is added or updated to remind you before it expires

### 🔀 Smart Sorting
- Sort your pantry by:
  - **Expiry Date** (default, nearest first)
  - **Name** (A–Z)
  - **Quantity** (low to high)

### 🤖 AI Kitchen — Gemini-Powered Recipe Generator
- Dedicated **AI Kitchen tab** in the bottom navigation
- Generates a recipe using **exactly what's in your pantry** via Google Gemini
- Automatically discovers the best available Gemini model for your API key (prefers `gemini-2.0-flash`, falls back gracefully)
- Handles quota limits — retries with alternative models on `429` responses
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

### 📊 Pantry Insights (Analytics Dashboard)
- Dedicated **Stats tab** with a full analytics dashboard:
  - **Summary cards** — total items, expiring soon count, expired count
  - **Expiry donut chart** — visual breakdown of Fresh / Expiring Soon / Expired items with percentage labels
  - **Category progress bars** — item counts per category shown as clean horizontal bars with colour-coded badges
  - **Low stock list** — items with quantity ≤ 1 listed with quantity badges
- All data computed live from the in-memory pantry state — no extra DB queries

### 🔔 In-App Toast Notifications
- Lightweight **animated top-toast overlay** replaces all snackbars
- Slides in from the top and fades out automatically after ~2 seconds
- Color-coded variants: ✅ green (success), 🟠 orange (warning), 🔴 red (error)
- Never blocks or interferes with the FAB or bottom navigation bar

### 🧭 Navigation
- Persistent **bottom navigation bar** with four tabs:
  - 📦 **Inventory** — pantry list
  - 🍽️ **AI Kitchen** — recipe generator
  - 📊 **Stats** — analytics dashboard
  - ⚙️ **Settings** — app preferences
- Centred gradient **FAB** for quickly adding items from any tab

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
| Charts | [fl_chart](https://pub.dev/packages/fl_chart) `^1.1.1` |
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
├── main.dart                      # App entry point, MultiProvider setup
├── models/
│   ├── grocery_item.dart          # GroceryItem data model
│   └── recipe.dart                # Recipe + RecipeIngredient models
├── providers/
│   ├── grocery_provider.dart      # Pantry state + analytics computed getters
│   └── recipe_provider.dart       # Recipe history state
├── db/
│   └── database_helper.dart       # SQLite helper (groceries + recipe_history tables)
├── services/
│   ├── ai_recipe_service.dart     # Gemini API integration with model fallback
│   ├── notification_service.dart  # Local push notification scheduling
│   └── recipe_service.dart        # Offline recipe matching
├── screens/
│   ├── splash_screen.dart
│   ├── main_screen.dart           # 4-tab bottom nav shell + gradient FAB
│   ├── home_screen.dart           # Pantry list with swipe-to-delete
│   ├── add_item_screen.dart       # Add new grocery item
│   ├── edit_item_screen.dart      # Edit / delete existing item
│   ├── stats_screen.dart          # Analytics dashboard (charts + summaries)
│   ├── recipe_screen.dart         # AI Kitchen landing + generation
│   ├── recipe_history_screen.dart # Saved AI recipe history
│   └── settings_screen.dart
├── widgets/
│   └── grocery_card.dart          # Pantry item card with consume dialog
├── data/
│   └── recipes.dart               # Static offline recipe definitions
└── utils/
    ├── constants.dart             # DB names, categories, units, API key
    └── app_toast.dart             # Animated top-toast overlay utility
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
├── GroceryProvider   → pantry CRUD, sorting, analytics getters
└── RecipeProvider    → AI recipe history (load, add, delete)
```

- **`GroceryProvider`** — persists all CRUD to SQLite, schedules notifications, and exposes computed analytics getters (`totalItems`, `expiredCount`, `expiringSoonCount`, `freshCount`, `lowStockItems`, `itemsByCategory`)
- **`RecipeProvider`** — saves each AI-generated recipe to the `recipe_history` table; history is loaded at startup

---

## 🔑 API Key Security

> ⚠️ **Do not commit your real Gemini API key to a public repository.**

The API key is stored in `lib/utils/constants.dart`. For production use, consider loading it from:
- A `.env` file (using `flutter_dotenv`)
- A secrets manager
- Firebase Remote Config

---

## 📄 License

This project is open source. See [LICENSE](LICENSE) for details.

---

<p align="center">Built with ❤️ using Flutter & Google Gemini</p>

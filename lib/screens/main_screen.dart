import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'add_item_screen.dart';
import 'stats_screen.dart';
import 'recipe_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    RecipeScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  static const _navItems = [
    _NavItem(
      icon: Icons.inventory_2_rounded,
      activeIcon: Icons.inventory_2,
      label: 'Inventory',
    ),
    _NavItem(
      icon: Icons.restaurant_menu_rounded,
      activeIcon: Icons.restaurant_menu,
      label: 'AI Kitchen',
    ),
    _NavItem(
      icon: Icons.bar_chart_rounded,
      activeIcon: Icons.bar_chart,
      label: 'Stats',
    ),
    _NavItem(
      icon: Icons.settings_rounded,
      activeIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  void _onAddPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddItemScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: _GreenFab(onPressed: _onAddPressed),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ── Gradient FAB ─────────────────────────────────────────────────────────────

class _GreenFab extends StatelessWidget {
  final VoidCallback onPressed;
  const _GreenFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.40),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }
}

// ── Bottom Nav ───────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Split items around the FAB notch: left two, right two
    final leftItems = items.sublist(0, 2);
    final rightItems = items.sublist(2);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 20,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BottomAppBar(
          color: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          notchMargin: 10,
          shape: const CircularNotchedRectangle(),
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                // Left side — 2 items
                ...leftItems.asMap().entries.map(
                  (e) => Expanded(child: _buildItem(e.value, e.key)),
                ),
                // FAB gap
                const SizedBox(width: 72),
                // Right side — 2 items (indices 2 and 3)
                ...rightItems.asMap().entries.map(
                  (e) => Expanded(child: _buildItem(e.value, e.key + 2)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(_NavItem item, int index) {
    final selected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF43A047).withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              color: selected ? const Color(0xFF2E7D32) : Colors.grey.shade400,
              size: selected ? 26 : 24,
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade400,
              ),
              child: Text(item.label, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/screens/stats_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grocery_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int? _touchedIndex;

  static const _green900 = Color(0xFF1B5E20);
  static const _green700 = Color(0xFF2E7D32);
  static const _green500 = Color(0xFF43A047);
  static const _green100 = Color(0xFFC8E6C9);
  static const _green50 = Color(0xFFE8F5E9);
  static const _orange = Color(0xFFF57C00);
  static const _red = Color(0xFFD32F2F);
  static const _pageBg = Color(0xFFF1F8F1);
  static const _card = Colors.white;
  static final _muted = Colors.grey.shade600;

  static const _catColors = [
    Color(0xFF43A047),
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
    Color(0xFFE53935),
    Color(0xFFFF8F00),
    Color(0xFF00ACC1),
    Color(0xFF6D4C41),
    Color(0xFFEC407A),
  ];

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GroceryProvider>();

    return Scaffold(
      backgroundColor: _pageBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSummaryRow(gp),
                const SizedBox(height: 20),
                if (gp.totalItems > 0) ...[
                  _sectionTitle('Expiry Breakdown'),
                  const SizedBox(height: 10),
                  _buildExpiryCard(gp),
                  const SizedBox(height: 20),
                ],
                if (gp.itemsByCategory.isNotEmpty) ...[
                  _sectionTitle('Category Breakdown'),
                  const SizedBox(height: 10),
                  _buildCategoryCard(gp),
                  const SizedBox(height: 20),
                ],
                _sectionTitle('Low Stock'),
                const SizedBox(height: 10),
                _buildLowStockCard(gp),
                if (gp.totalItems == 0) _buildEmpty(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────────
  Widget _buildAppBar() => SliverAppBar(
    expandedHeight: 110,
    pinned: true,
    backgroundColor: _green700,
    flexibleSpace: FlexibleSpaceBar(
      centerTitle: false,
      titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
      background: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_green900, _green500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: const Row(
        children: [
          Icon(Icons.insights_rounded, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            'Pantry Insights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );

  // ── Helpers ──────────────────────────────────────────────────────────────────
  Widget _sectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: _green900,
      letterSpacing: 0.4,
    ),
  );

  Widget _sheet({required Widget child, EdgeInsets? padding}) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: _green500.withOpacity(0.10),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: padding ?? const EdgeInsets.all(18),
    child: child,
  );

  // ── 1. Summary row ───────────────────────────────────────────────────────────
  Widget _buildSummaryRow(GroceryProvider gp) {
    return Row(
      children: [
        _kpi(
          'Total',
          gp.totalItems.toString(),
          Icons.inventory_2_rounded,
          _green500,
          _green50,
        ),
        const SizedBox(width: 10),
        _kpi(
          'Expiring\nSoon',
          gp.expiringSoonCount.toString(),
          Icons.timer_rounded,
          _orange,
          const Color(0xFFFFF3E0),
        ),
        const SizedBox(width: 10),
        _kpi(
          'Expired',
          gp.expiredCount.toString(),
          Icons.warning_amber_rounded,
          _red,
          const Color(0xFFFFEBEE),
        ),
      ],
    );
  }

  Widget _kpi(
    String label,
    String value,
    IconData icon,
    Color accent,
    Color bg,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: accent, size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10.5, color: _muted, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. Expiry donut + legend ─────────────────────────────────────────────────
  Widget _buildExpiryCard(GroceryProvider gp) {
    final data = [
      _Slice('Fresh', gp.freshCount, _green500),
      _Slice('Soon', gp.expiringSoonCount, _orange),
      _Slice('Expired', gp.expiredCount, _red),
    ].where((s) => s.count > 0).toList();

    final sections = data.asMap().entries.map((e) {
      final touched = _touchedIndex == e.key;
      final pct = (e.value.count / gp.totalItems * 100);
      return PieChartSectionData(
        value: e.value.count.toDouble(),
        color: e.value.color,
        radius: touched ? 62 : 52,
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black26, blurRadius: 3)],
        ),
      );
    }).toList();

    return _sheet(
      child: Row(
        children: [
          // Donut chart
          SizedBox(
            width: 160,
            height: 160,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 42,
                sectionsSpace: 3,
                pieTouchData: PieTouchData(
                  touchCallback: (ev, resp) => setState(() {
                    _touchedIndex = resp?.touchedSection?.touchedSectionIndex;
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Legend column
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Centre stat
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${gp.totalItems}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _green900,
                      ),
                    ),
                    Text(
                      'total items',
                      style: TextStyle(fontSize: 12, color: _muted),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...data.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: s.color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          s.label,
                          style: TextStyle(fontSize: 13, color: _muted),
                        ),
                        const Spacer(),
                        Text(
                          '${s.count}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _green900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Category progress bars ────────────────────────────────────────────────
  Widget _buildCategoryCard(GroceryProvider gp) {
    final cats = gp.itemsByCategory.entries.toList();
    final maxVal = cats.first.value;

    return _sheet(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        children: cats.asMap().entries.map((e) {
          final color = _catColors[e.key % _catColors.length];
          final pct = e.value.value / maxVal;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                // Icon dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                // Label
                SizedBox(
                  width: 72,
                  child: Text(
                    e.value.key,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _muted,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Progress bar
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${e.value.value}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── 4. Low stock ─────────────────────────────────────────────────────────────
  Widget _buildLowStockCard(GroceryProvider gp) {
    if (gp.lowStockItems.isEmpty) {
      return _sheet(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: _green50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: _green500,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'All items are well stocked 🎉',
                style: TextStyle(
                  fontSize: 14,
                  color: _green900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _sheet(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: gp.lowStockItems.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: _red,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _green900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _red.withOpacity(0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '${item.quantity} ${item.unit}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: _red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Empty ────────────────────────────────────────────────────────────────────
  Widget _buildEmpty() => Padding(
    padding: const EdgeInsets.only(top: 60),
    child: Column(
      children: [
        Icon(Icons.insights_rounded, size: 80, color: _green100),
        const SizedBox(height: 16),
        const Text(
          'No pantry data yet',
          style: TextStyle(
            color: _green700,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Add items to your pantry to see insights.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
        ),
      ],
    ),
  );
}

class _Slice {
  final String label;
  final int count;
  final Color color;
  const _Slice(this.label, this.count, this.color);
}

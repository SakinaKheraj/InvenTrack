// lib/screens/recipe_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../models/grocery_item.dart';
import '../providers/grocery_provider.dart';
import '../providers/recipe_provider.dart';
import '../services/ai_recipe_service.dart';
import 'recipe_history_screen.dart';

const _kGreen = Color(0xFF2E7D32);
const _kGreenLight = Color(0xFFE8F5E9);
const _kSurface = Color(0xFFF9FBF9);
const _kTextDark = Color(0xFF1B1B1B);

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen>
    with SingleTickerProviderStateMixin {
  bool _isGenerating = false;

  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _generate(BuildContext ctx, List<GroceryItem> items) async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Your pantry is empty! Add items first.')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final recipe = await AiRecipeService.generateRecipeFromPantry(items);
      if (!mounted) return;

      if (recipe != null) {
        final saved = await context.read<RecipeProvider>().addRecipe(recipe);

        Navigator.of(ctx).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => RecipeDetailScreen(recipe: saved),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Chef Gemini had an error. Try again!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString();
      final display = raw.toLowerCase().contains('quota')
          ? 'Quota exceeded. Check your Gemini key limits or try later.'
          : 'AI Error: $raw';
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(display)));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = context.select<GroceryProvider, List<GroceryItem>>(
      (p) => p.items,
    );

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: _KitchenAppBar(
        onHistoryTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const RecipeHistoryScreen())),
      ),
      body: Stack(
        children: [
          _KitchenBody(
            itemCount: items.length,
            isGenerating: _isGenerating,
            spinController: _spinController,
            onGenerate: () => _generate(context, items),
          ),
          if (_isGenerating) _LoadingOverlay(controller: _spinController),
        ],
      ),
    );
  }
}

class _KitchenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _KitchenAppBar({required this.onHistoryTap});

  final VoidCallback onHistoryTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'AI Kitchen',
        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.4),
      ),
      backgroundColor: Colors.white,
      foregroundColor: _kGreen,
      elevation: 0,
      surfaceTintColor: Colors.white,
      actions: [
        Consumer<RecipeProvider>(
          builder: (_, provider, __) => Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.history_rounded),
                tooltip: 'Recipe History',
                onPressed: onHistoryTap,
              ),
              if (provider.history.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _kGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.grey.shade200),
      ),
    );
  }
}

class _KitchenBody extends StatelessWidget {
  const _KitchenBody({
    required this.itemCount,
    required this.isGenerating,
    required this.spinController,
    required this.onGenerate,
  });

  final int itemCount;
  final bool isGenerating;
  final AnimationController spinController;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ChefIconBadge(),
            const SizedBox(height: 28),
            _HeadlineText(),
            const SizedBox(height: 10),
            _PantryCountLabel(count: itemCount),
            const SizedBox(height: 44),
            _GenerateButton(
              isGenerating: isGenerating,
              spinController: spinController,
              onTap: onGenerate,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChefIconBadge extends StatelessWidget {
  const _ChefIconBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: _kGreenLight,
        shape: BoxShape.circle,
        border: Border.all(color: _kGreen.withOpacity(0.18), width: 2),
      ),
      child: const Icon(Icons.restaurant_menu, size: 54, color: _kGreen),
    );
  }
}

class _HeadlineText extends StatelessWidget {
  const _HeadlineText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Let AI Chef create a recipe\nfrom your pantry',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 22,
        color: _kTextDark,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
    );
  }
}

class _PantryCountLabel extends StatelessWidget {
  const _PantryCountLabel({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$count item${count == 1 ? '' : 's'} in pantry',
      style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
    );
  }
}

class _GenerateButton extends StatelessWidget {
  const _GenerateButton({
    required this.isGenerating,
    required this.spinController,
    required this.onTap,
  });

  final bool isGenerating;
  final AnimationController spinController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isGenerating ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kGreen,
          disabledBackgroundColor: _kGreen.withOpacity(0.45),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: _kGreen.withOpacity(0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: isGenerating ? spinController : kAlwaysCompleteAnimation,
              child: const Icon(
                Icons.auto_awesome,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isGenerating ? 'Generating…' : 'Generate Recipe',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: Colors.white.withOpacity(0.78),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: controller,
                child: const Icon(Icons.soup_kitchen, size: 76, color: _kGreen),
              ),
              const SizedBox(height: 24),
              const Text(
                'AI Chef is thinking…',
                style: TextStyle(
                  color: _kTextDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Creating a masterpiece for you',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({required this.recipe, super.key});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSurface,
      body: CustomScrollView(
        slivers: [
          _RecipeAppBar(name: recipe.name),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _SectionHeader(
                  title: 'Ingredients',
                  icon: Icons.shopping_basket_outlined,
                ),
                const SizedBox(height: 12),
                ...recipe.ingredients.map(
                  (ing) => _IngredientTile(ingredient: ing),
                ),
                const SizedBox(height: 32),
                const _SectionHeader(
                  title: 'Instructions',
                  icon: Icons.format_list_numbered,
                ),
                const SizedBox(height: 12),
                ...recipe.instructions.asMap().entries.map(
                  (e) => _StepTile(step: e.key + 1, text: e.value),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeAppBar extends StatelessWidget {
  const _RecipeAppBar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 250,
      backgroundColor: Colors.white,
      foregroundColor: _kGreen,
      surfaceTintColor: Colors.white,
      elevation: 0,
      // Title is on SliverAppBar directly → never shrinks on scroll
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: _kTextDark,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: _kGreenLight,
          child: Center(
            child: Icon(
              Icons.restaurant,
              size: 80,
              color: _kGreen.withOpacity(0.2),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _kGreen, size: 24),
        const SizedBox(width: 15),
        Text(
          title,
          style: const TextStyle(
            color: _kTextDark,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ── Ingredient Tile ───────────────────────────────────────────────────────────
class _IngredientTile extends StatelessWidget {
  const _IngredientTile({required this.ingredient});
  final RecipeIngredient ingredient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: _kGreenLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: _kGreen, size: 16),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                '${ingredient.quantity} ${ingredient.unit}  ${ingredient.name}',
                style: const TextStyle(
                  color: _kTextDark,
                  fontSize: 16,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Instruction Step ──────────────────────────────────────────────────────────
class _StepTile extends StatelessWidget {
  const _StepTile({required this.step, required this.text});
  final int step;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: _kGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 16,
                  height: 1.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

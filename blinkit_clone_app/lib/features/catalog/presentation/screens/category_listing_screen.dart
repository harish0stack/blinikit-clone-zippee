// lib/features/catalog/presentation/screens/category_listing_screen.dart
// Phase 1 — Grid of categories (subcategory cards)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../home/presentation/providers/catalog_providers.dart';
import '../../../home/models/category_model.dart';

class CategoryListingScreen extends ConsumerWidget {
  const CategoryListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider(null));

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.headerGradientTop,
        title: Text(
          'Categories',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        elevation: 0,
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categories) => GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return _CategoryCard(cat: cat);
          },
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel cat;
  const _CategoryCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/products?categoryId=${cat.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.categoryTileBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.hairline, width: 0.5),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: cat.images.isNotEmpty
                    ? AppNetworkImage(
                        imageUrl: cat.images.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : const Icon(
                        Icons.shopping_basket,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                cat.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

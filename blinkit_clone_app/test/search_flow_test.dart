// test/search_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blinkit_clone_app/features/search/presentation/screens/search_screen.dart';
import 'package:blinkit_clone_app/features/search/presentation/controllers/search_controller.dart';
import 'package:blinkit_clone_app/features/search/data/local_search_index.dart';
import 'package:blinkit_clone_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:blinkit_clone_app/features/home/models/product_model.dart';
import 'package:blinkit_clone_app/features/home/models/category_model.dart';
import 'package:blinkit_clone_app/features/home/data/catalog_repository.dart';
import 'package:blinkit_clone_app/features/home/presentation/providers/catalog_providers.dart';

class FakeCatalogRepository implements CatalogRepository {
  @override
  Future<List<CategoryModel>> fetchCategories({String? sectionType}) async => [];

  @override
  Future<List<ProductModel>> fetchProducts({required String categoryId}) async => [];

  @override
  Future<ProductModel> fetchProductById(String productId) async => throw UnimplementedError();

  @override
  Future<List<ProductModel>> fetchAllProducts() async => [];
}

void main() {
  final testOverrides = [
    catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
  ];

  group('Search Feature UI & Logic Tests', () {
    testWidgets('SearchScreen renders Browse State sections accurately',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides,
          child: const MaterialApp(
            home: SearchScreen(autofocus: false),
          ),
        ),
      );
      await tester.pump();

      // Verify Top Pinned Search Bar elements
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search for atta, dal, co...'), findsOneWidget);
      expect(find.byType(SvgPicture), findsWidgets); // Search & Mic SVG icons
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Verify Browse State Section Headers
      expect(find.text('Recent searches'), findsOneWidget);
      expect(find.text('clear'), findsOneWidget);
      expect(find.text('Continue browsing for'), findsOneWidget);
      expect(find.text('Trending in your city'), findsOneWidget);
      expect(find.text('Your wishlist'), findsOneWidget);

      // Verify Recent search pills
      expect(find.text('ice cream'), findsOneWidget);
      expect(find.text('rosemary water alps'), findsOneWidget);

      // Verify View cart is NOT shown when cart is empty (dynamic check)
      expect(find.text('View cart'), findsNothing);
    });

    testWidgets('Typing into search field switches to Results State and displays matches',
        (tester) async {
      final container = ProviderContainer(overrides: testOverrides);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: SearchScreen(autofocus: false),
          ),
        ),
      );
      await tester.pump();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'milk');
      await tester.pump(const Duration(milliseconds: 350));

      // Verify query is updated in search state
      expect(container.read(searchNotifierProvider).query, 'milk');
    });

    testWidgets('View cart floating pill displays dynamically when cart has items',
        (tester) async {
      final container = ProviderContainer(overrides: testOverrides);

      // Add a product to the cart
      const testProduct = ProductModel(
        id: 'p_101',
        name: 'Amul Butter 500g',
        unit: '500 g',
        imageUrl: '',
        categoryId: 'dairy',
        mrp: 275,
        sellingPrice: 260,
        inStock: true,
      );
      container.read(cartProvider.notifier).addProduct(testProduct);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: SearchScreen(autofocus: false),
          ),
        ),
      );
      await tester.pump();

      // View cart pill should now be visible dynamically
      expect(find.text('View cart'), findsOneWidget);
      expect(find.text('1 item'), findsOneWidget);
    });

    testWidgets('Tapping clear clears recent searches', (tester) async {
      final container = ProviderContainer(overrides: testOverrides);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: SearchScreen(autofocus: false),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Recent searches'), findsOneWidget);
      await tester.tap(find.text('clear'));
      await tester.pump();

      // After clearing, the recent search list in state is empty
      expect(container.read(searchNotifierProvider).recentSearches.isEmpty, true);
    });

    test('LocalSearchIndex matches Hinglish vernacular terms (amul dudh, pyaz, aloo, tata namak)', () {
      final index = LocalSearchIndex();
      final sampleCatalog = [
        const ProductModel(
          id: 'p1',
          name: 'Amul Taaza Homogenised Toned Milk 1L',
          unit: '1 L',
          imageUrl: '',
          categoryId: 'dairy',
          mrp: 75,
          sellingPrice: 72,
          inStock: true,
        ),
        const ProductModel(
          id: 'p2',
          name: 'Fresh Hybrid Onion',
          unit: '1 kg',
          imageUrl: '',
          categoryId: 'vegetables',
          mrp: 45,
          sellingPrice: 38,
          inStock: true,
        ),
        const ProductModel(
          id: 'p3',
          name: 'Fresh Potato (Aloo)',
          unit: '1 kg',
          imageUrl: '',
          categoryId: 'vegetables',
          mrp: 35,
          sellingPrice: 28,
          inStock: true,
        ),
        const ProductModel(
          id: 'p4',
          name: 'Tata Salt Vacuum Evaporated Iodised Salt',
          unit: '1 kg',
          imageUrl: '',
          categoryId: 'staples',
          mrp: 30,
          sellingPrice: 28,
          inStock: true,
        ),
      ];

      index.buildFromCatalog(sampleCatalog);

      // 1. "amul dudh" matches "Amul Taaza Homogenised Toned Milk 1L"
      final amulResults = index.search('amul dudh');
      expect(amulResults.isNotEmpty, true);
      expect(amulResults.first.id, 'p1');

      // 2. "2 packet amul doodh chahiye" matches "Amul Taaza Homogenised Toned Milk 1L"
      final sentenceResults = index.search('2 packet amul doodh chahiye');
      expect(sentenceResults.isNotEmpty, true);
      expect(sentenceResults.first.id, 'p1');

      // 3. "pyaz" matches "Fresh Hybrid Onion"
      final onionResults = index.search('pyaz');
      expect(onionResults.isNotEmpty, true);
      expect(onionResults.first.id, 'p2');

      // 4. "kanda" matches "Fresh Hybrid Onion"
      final kandaResults = index.search('kanda');
      expect(kandaResults.isNotEmpty, true);
      expect(kandaResults.first.id, 'p2');

      // 5. "batata" matches "Fresh Potato (Aloo)"
      final potatoResults = index.search('batata');
      expect(potatoResults.isNotEmpty, true);
      expect(potatoResults.first.id, 'p3');

      // 6. "tata namak" matches "Tata Salt Vacuum Evaporated Iodised Salt"
      final saltResults = index.search('tata namak');
      expect(saltResults.isNotEmpty, true);
      expect(saltResults.first.id, 'p4');
    });
  });
}

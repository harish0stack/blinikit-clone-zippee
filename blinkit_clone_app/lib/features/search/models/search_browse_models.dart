// lib/features/search/models/search_browse_models.dart
// Models for Search screen browse state matching reference designs

class BrowseHistoryItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String daysAgo;

  const BrowseHistoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.daysAgo = '1 day ago',
  });
}

class TrendingItem {
  final String id;
  final String title;
  final String imageUrl;

  const TrendingItem({
    required this.id,
    required this.title,
    required this.imageUrl,
  });
}

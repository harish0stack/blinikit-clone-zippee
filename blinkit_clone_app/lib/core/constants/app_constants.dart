// lib/core/constants/app_constants.dart
class AppConstants {
  AppConstants._();

  static const String appName = 'Blinkit Clone';

  /// Supabase Edge Functions base path
  static const String edgeFunctionBase = '/functions/v1';

  /// Delivery promise (UI label only)
  static const int deliveryMinutes = 10;

  /// Catalog page size for pagination
  static const int catalogPageSize = 20;
}

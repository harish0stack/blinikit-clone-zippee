// lib/core/services/upi_detector_service.dart
// Production-grade NPCI-compliant UPI launcher & real on-device detector
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class UpiAppInfo {
  final String name;
  final String packageName;
  final String assetIcon;
  final bool isDefaultRecommendation;

  const UpiAppInfo({
    required this.name,
    required this.packageName,
    required this.assetIcon,
    this.isDefaultRecommendation = false,
  });
}

class UpiDetectorService {
  static const String defaultReceiverVpa = '8928560233@ybl';
  static const String defaultPayeeName = 'Pratik Swain';
  static const MethodChannel _nativeChannel =
      MethodChannel('com.zippee.app/upi_launcher');

  static List<UpiAppInfo>? _cachedInstalledApps;

  static const List<UpiAppInfo> knownUpiApps = [
    UpiAppInfo(
      name: 'Google Pay',
      packageName: 'com.google.android.apps.nbu.paisa.user',
      assetIcon: 'assets/figma-assests/icons/gpay.png',
      isDefaultRecommendation: true,
    ),
    UpiAppInfo(
      name: 'PhonePe',
      packageName: 'com.phonepe.app',
      assetIcon: 'assets/figma-assests/icons/phonepe.png',
    ),
    UpiAppInfo(
      name: 'Paytm',
      packageName: 'net.one97.paytm',
      assetIcon: 'assets/figma-assests/icons/paytm.png',
    ),
    UpiAppInfo(
      name: 'FamApp UPI',
      packageName: 'com.fampay.in',
      assetIcon: 'assets/figma-assests/icons/famapp.png',
    ),
    UpiAppInfo(
      name: 'Any Other UPI App',
      packageName: '',
      assetIcon: '',
    ),
  ];

  /// Returns only the apps genuinely installed on this device, in
  /// knownUpiApps catalog order, plus the always-available "Any Other" entry.
  static Future<List<UpiAppInfo>> getAvailableUpiApps() async {
    if (_cachedInstalledApps != null && _cachedInstalledApps!.isNotEmpty) {
      return _cachedInstalledApps!;
    }

    List<String> installedPackages = [];
    if (Platform.isAndroid) {
      try {
        final result = await _nativeChannel.invokeMethod<List<dynamic>>(
          'getInstalledUpiPackages',
        );
        installedPackages = result?.cast<String>() ?? [];
        debugPrint('[UPI Detection] Installed UPI packages: $installedPackages');
      } catch (e) {
        debugPrint('[UPI Detection] Detection failed, falling back to empty list: $e');
      }
    }

    final available = knownUpiApps.where((app) {
      if (app.packageName.isEmpty) return true; // "Any Other UPI App" always shown
      return installedPackages.contains(app.packageName);
    }).toList();

    // If detection returned empty on non-Android or debug failure, provide full list
    if (available.length <= 1 && installedPackages.isEmpty) {
      _cachedInstalledApps = knownUpiApps;
      return knownUpiApps;
    }

    _cachedInstalledApps = available;
    return available;
  }

  /// Force a re-scan of installed apps
  static void clearCache() => _cachedInstalledApps = null;

  /// Builds clean NPCI P2P URI without invalid merchant parameters (tr)
  static String buildUpiUrl({
    required double amount,
    required String orderId,
    String payeeVpa = defaultReceiverVpa,
    String payeeName = defaultPayeeName,
  }) {
    final formattedAmount = amount.toStringAsFixed(2);
    return 'upi://pay?'
        'pa=$payeeVpa'
        '&pn=${Uri.encodeComponent(payeeName)}'
        '&tn=${Uri.encodeComponent('Order_$orderId')}'
        '&am=$formattedAmount'
        '&cu=INR';
  }

  /// Returns a dynamic QR code URL for scan-and-pay fallback
  static String buildQrCodeUrl({
    required double amount,
    required String orderId,
    String payeeVpa = defaultReceiverVpa,
    String payeeName = defaultPayeeName,
  }) {
    final upiUrl = buildUpiUrl(
      amount: amount,
      orderId: orderId,
      payeeVpa: payeeVpa,
      payeeName: payeeName,
    );
    return 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${Uri.encodeComponent(upiUrl)}';
  }

  /// Launch UPI payment intent directly into target app via native Android Intent.setPackage()
  static Future<bool> launchUpiPayment({
    required double amount,
    required String orderId,
    String payeeVpa = defaultReceiverVpa,
    String payeeName = defaultPayeeName,
    String? specificPackage,
  }) async {
    final upiUriString = buildUpiUrl(
      amount: amount,
      orderId: orderId,
      payeeVpa: payeeVpa,
      payeeName: payeeName,
    );

    debugPrint('[UPI] Launching targeted UPI intent: $specificPackage -> $upiUriString');

    if (Platform.isAndroid) {
      try {
        final success = await _nativeChannel.invokeMethod<bool>('launchUpiApp', {
          'uri': upiUriString,
          'packageName': specificPackage ?? '',
        });
        if (success == true) return true;
      } catch (e) {
        debugPrint('[UPI Native] Direct package launch failed for $specificPackage: $e');
        // Only fall through to untargeted resolution when the user picked
        // "Any Other UPI App" (empty package). A named-app failure returns false.
        if (specificPackage != null && specificPackage.isNotEmpty) {
          return false;
        }
      }
    }

    // Untargeted fallback — only reached for "Any Other UPI App" or non-Android
    try {
      final uri = Uri.parse(upiUriString);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[UPI] Untargeted launch fallback failed: $e');
      return false;
    }
  }
}

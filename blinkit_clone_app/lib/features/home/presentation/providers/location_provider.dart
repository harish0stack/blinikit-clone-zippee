// lib/features/home/presentation/providers/location_provider.dart
// Location detection service & Riverpod StateNotifier
// Detects client device address using geolocator & geocoding

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

const kDefaultAddress = 'Sindhu Nagar, Sewri';

final locationProvider =
    StateNotifierProvider<LocationNotifier, AsyncValue<String>>((ref) {
  return LocationNotifier()..fetchCurrentAddress();
});

class LocationNotifier extends StateNotifier<AsyncValue<String>> {
  LocationNotifier() : super(const AsyncValue.data(kDefaultAddress));

  void setManualAddress(String address) {
    state = AsyncValue.data(address);
  }

  Future<bool> fetchCurrentAddress({bool openSettingsIfDenied = false}) async {
    try {
      state = const AsyncValue.loading();
      debugPrint('[Location] Initiating location detection...');

      // 1. Check whether location services (GPS) are enabled on the device
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[Location] Location services (GPS) disabled on device.');
        if (openSettingsIfDenied) {
          await Geolocator.openLocationSettings();
        }
        state = const AsyncValue.data(kDefaultAddress);
        return false;
      }

      // 2. Check and request location permissions
      var permission = await Geolocator.checkPermission();
      debugPrint('[Location] Current permission: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('[Location] Requested permission result: $permission');
        if (permission == LocationPermission.denied) {
          debugPrint('[Location] Permission denied by user.');
          state = const AsyncValue.data(kDefaultAddress);
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[Location] Permission denied permanently.');
        if (openSettingsIfDenied) {
          await Geolocator.openAppSettings();
        }
        state = const AsyncValue.data(kDefaultAddress);
        return false;
      }

      // 3. Try fastest GPS retrieval first (last known position)
      Position? position = await Geolocator.getLastKnownPosition();
      debugPrint('[Location] Last known position: $position');

      // 4. If no last known position, request fresh position with timeout
      if (position == null) {
        debugPrint('[Location] Requesting fresh GPS fix...');
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
        debugPrint('[Location] Fresh GPS fix obtained: $position');
      }

      // 5. Reverse geocode to human-readable address
      debugPrint('[Location] Reverse geocoding coordinates (${position.latitude}, ${position.longitude})...');
      final placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        debugPrint('[Location] Placemark received: locality=${place.locality}, subLocality=${place.subLocality}, name=${place.name}, street=${place.street}');

        // Build clean short address, e.g. "Sindhu Nagar, Sewri" or "Indiranagar, Bengaluru"
        final subArea = place.subLocality?.trim().isNotEmpty == true
            ? place.subLocality!.trim()
            : place.thoroughfare?.trim().isNotEmpty == true
                ? place.thoroughfare!.trim()
                : place.name?.trim();

        final city = place.locality?.trim().isNotEmpty == true
            ? place.locality!.trim()
            : place.subAdministrativeArea?.trim();

        String formattedAddress = kDefaultAddress;
        if (subArea != null && city != null && subArea.toLowerCase() != city.toLowerCase()) {
          formattedAddress = '$subArea, $city';
        } else if (subArea != null) {
          formattedAddress = subArea;
        } else if (city != null) {
          formattedAddress = city;
        }

        debugPrint('[Location] Detected formatted address: $formattedAddress');
        state = AsyncValue.data(formattedAddress);
        return true;
      } else {
        debugPrint('[Location] No placemarks returned for coordinates.');
        state = const AsyncValue.data(kDefaultAddress);
        return false;
      }
    } catch (e, stack) {
      debugPrint('[Location] Error during location detection: $e\n$stack');
      state = const AsyncValue.data(kDefaultAddress);
      return false;
    }
  }
}

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

class LocationInfo {
  final double latitude;
  final double longitude;
  final String locationName;

  const LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });
}

class LocationService {
  static final LocationService instance = LocationService._init();
  LocationService._init();

  /// Lấy vị trí GPS hiện tại kèm tên địa chỉ được giải mã
  Future<LocationInfo?> getCurrentMeetingLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return null;
      }

      // Lấy tọa độ GPS với độ chính xác cao
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Giải mã tọa độ sang địa chỉ thực tế (Reverse Geocoding)
      String locationName = 'Tọa độ: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      try {
        final List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final List<String> addressParts = [];
          if (p.street != null && p.street!.isNotEmpty) addressParts.add(p.street!);
          if (p.subAdministrativeArea != null && p.subAdministrativeArea!.isNotEmpty) {
            addressParts.add(p.subAdministrativeArea!);
          } else if (p.locality != null && p.locality!.isNotEmpty) {
            addressParts.add(p.locality!);
          }
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) {
            addressParts.add(p.administrativeArea!);
          }

          if (addressParts.isNotEmpty) {
            locationName = addressParts.join(', ');
          }
        }
      } catch (e) {
        debugPrint('Geocoding error: $e');
      }

      return LocationInfo(
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: locationName,
      );
    } catch (e) {
      debugPrint('Location service exception: $e');
      return null;
    }
  }
}

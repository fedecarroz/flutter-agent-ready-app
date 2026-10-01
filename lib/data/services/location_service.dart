import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Map<String, double>> getLocation({bool highAccuracy = false}) async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError('Permesso di localizzazione non concesso');
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('Servizi di localizzazione disattivati');
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: highAccuracy
            ? LocationAccuracy.high
            : LocationAccuracy.medium,
      ),
    );
    return {'latitude': position.latitude, 'longitude': position.longitude};
  }
}

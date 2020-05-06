import 'dart:async';
import 'package:location/location.dart';
import 'package:isotope/src/models/geographic_coordinate.dart';

class LocationService {
  // Keep track of current Location
  GeographicCoordinate _currentLocation;
  Location location = Location();
  
  // Continuously emit location updates
  StreamController<GeographicCoordinate> _locationController = StreamController<GeographicCoordinate>.broadcast();

  LocationService() {
    location.requestPermission().then((granted) {
      if (granted != null) {
        location.onLocationChanged().listen((locationData) {
          if (locationData != null) {
            _locationController.add(GeographicCoordinate(
              latitude: locationData.latitude,
              longitude: locationData.longitude,
            ));
          }
        });
      }
    });
  }

  Stream<GeographicCoordinate> get locationStream => _locationController.stream;

  Future<GeographicCoordinate> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = GeographicCoordinate(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
    } catch (e) {
      print('Could not get the location: $e');
    }

    return _currentLocation;
  }
}

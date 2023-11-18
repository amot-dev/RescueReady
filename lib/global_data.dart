import 'package:google_maps_flutter/google_maps_flutter.dart';

class GlobalData {
  static final rescueRequests = <RescueRequest>[];
}

class RescueRequest {
  final String name;
  final String age;
  final String detail;
  final String dangerLevel;
  final LatLng location;

  RescueRequest(
      {required this.name, required this.age, required this.detail, required this.dangerLevel, required this.location});
}

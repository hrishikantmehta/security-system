import 'package:google_maps_flutter/google_maps_flutter.dart';

class Request {
  late String? id;
  late String? requesterID;
  late String? requesterName;
  late LatLng location;
  late String? from;
  late String? to;
  late String? place;
  late String? status;

  Request({
    this.id,
    this.requesterID,
    required this.location,
    this.from,
    this.to,
    this.place,
    this.status,
    this.requesterName,
  });
}

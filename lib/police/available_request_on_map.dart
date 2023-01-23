import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationOnMap extends StatefulWidget {
  static String id = "locationOnMap";
  List<LatLng> locations;
  LocationOnMap({Key? key, required this.locations}) : super(key: key);

  @override
  State<LocationOnMap> createState() => _LocationOnMapState();
}

class _LocationOnMapState extends State<LocationOnMap> {
  final Completer<GoogleMapController?> _controller = Completer();
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};
  Location location = Location();
  PolylinePoints polylinePoints = PolylinePoints();
  LocationData? _currentPosition;
  LatLng? currLocation;
  // StreamSubscription<LocationData>? locationSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations'),
      ),
      body: FutureBuilder<int>(
        future: init(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Stack(
            children: [
              GoogleMap(
                zoomControlsEnabled: true,
                polylines: polylines,
                initialCameraPosition:
                    CameraPosition(target: widget.locations[0], zoom: 16),
                markers: markers,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<int> init() async {
    await getNavigation();
    await addMarker();
    await getDirections();

    return 1;
  }

  getDirections() async {
    int n = widget.locations.length;
    for (int i = 1; i < n; i++) {
      List<LatLng> polylineCoordinates = [];
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        '',
        PointLatLng(widget.locations[i - 1].latitude,
            widget.locations[i - 1].longitude),
        PointLatLng(
            widget.locations[i].latitude, widget.locations[i].longitude),
        travelMode: TravelMode.driving,
      );
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(
            LatLng(point.latitude, point.longitude),
          );
        }
      } else {
        print(result.errorMessage);
      }

      PolylineId id = PolylineId(i.toString());
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 3,
      );

      polylines.add(polyline);
    }

    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyAntt3LIuduhnuBDOj1GGwmh7rmbi1w0vQ',
      PointLatLng(
          widget.locations[n - 1].latitude, widget.locations[n - 1].longitude),
      PointLatLng(widget.locations[0].latitude, widget.locations[0].longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
    } else {
      print(result.errorMessage);
    }

    PolylineId id = const PolylineId('0');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 3,
    );

    polylines.add(polyline);
  }

  getNavigation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    if (_permissionGranted == PermissionStatus.granted) {
      location.changeSettings(accuracy: LocationAccuracy.high);
      _currentPosition = await location.getLocation();

      currLocation =
          LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);

      //     // locationSubscription = location.onLocationChanged.listen(
      //     //   (LocationData currentLocation) {
      //     //     controller?.animateCamera(
      //     //       CameraUpdate.newCameraPosition(
      //     //         CameraPosition(
      //     //           target: LatLng(
      //     //               currentLocation.latitude!, currentLocation.longitude!),
      //     //           zoom: 16,
      //     //         ),
      //     //       ),
      //     //     );
      //     //     if (mounted) {
      //     //       setState(() {
      //     //         currLocation =
      //     //             LatLng(currentLocation.latitude!, currentLocation.longitude!);
      //     //       });
      //     //     }
      //     //   },
      //     // );
    }
  }

  addMarker() async {
    for (int i = 0; i < widget.locations.length; i++) {
      MarkerId id = MarkerId(i.toString());
      markers.add(
        Marker(
          markerId: id,
          position: widget.locations[i],
          icon: BitmapDescriptor.defaultMarkerWithHue(
              i == 0 ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: i == 0 ? 'start' : i.toString(),
          ),
        ),
      );
    }
  }
}

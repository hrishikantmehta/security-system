import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ChooseLocation extends StatefulWidget {
  static String id = "chooseLocation";
  const ChooseLocation({Key? key}) : super(key: key);

  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  LatLng? pickedLocation = const LatLng(11.0, 79.0);
  Location location = Location();
  LocationData? currentPosition;
  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

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

      currentPosition = await location.getLocation();

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              currentPosition!.latitude!,
              currentPosition!.longitude!,
            ),
            zoom: 16,
          ),
        ),
      );
      setState(() {
        pickedLocation =
            LatLng(currentPosition!.latitude!, currentPosition!.longitude!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Location'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.navigate_next),
        onPressed: () {
          Navigator.pop(context, pickedLocation);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: CameraPosition(
              target: pickedLocation!,
              zoom: 16,
            ),
            onCameraMove: (CameraPosition? position) {
              if (pickedLocation != position!.target) {
                setState(() {
                  pickedLocation = position.target;
                });
              }
            },
            onCameraIdle: () {
              print('Camera Idle');
            },
            onTap: (latLng) {
              print(latLng);
            },
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35.0),
              child: Image.asset(
                'images/pin.png',
                height: 45,
                width: 45,
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(10.0),
              child: Text(
                '${pickedLocation?.latitude.toStringAsFixed(6)}, ${pickedLocation?.longitude.toStringAsFixed(6)}',
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: () {
                getCurrentLocation();
              },
              child: const Icon(Icons.my_location, color: Colors.white),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
                backgroundColor: Colors.blue, // <-- Button color
                foregroundColor: Colors.red, // <-- Splash color
              ),
            ),
          ),
        ],
      ),
    );
  }
}

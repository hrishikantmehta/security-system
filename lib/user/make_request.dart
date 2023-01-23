import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:security_system/user/choose_location.dart';

class MakeRequest extends StatefulWidget {
  const MakeRequest({Key? key}) : super(key: key);

  static String id = "MakeRequest";

  @override
  State<MakeRequest> createState() => _MakeRequestState();
}

class _MakeRequestState extends State<MakeRequest> {
  final TextEditingController _place = TextEditingController();
  final TextEditingController _fromdate = TextEditingController();
  final TextEditingController _todate = TextEditingController();
  final TextEditingController _myLocLat = TextEditingController();
  final TextEditingController _myLocLon = TextEditingController();
  late LatLng _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security System'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Make Request',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _place,
                decoration: const InputDecoration(
                  label: Text('Place'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                readOnly: true,
                controller: _fromdate,
                decoration: const InputDecoration(
                  label: Text('From'),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  DateTime? pickeddate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  print(pickeddate);
                  if (pickeddate != null) {
                    setState(() {
                      _fromdate.text =
                          DateFormat('dd-MM-yyyy').format(pickeddate);
                    });
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                readOnly: true,
                controller: _todate,
                decoration: const InputDecoration(
                  label: Text('To'),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  DateTime? pickeddate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  print(pickeddate);
                  if (pickeddate != null) {
                    setState(() {
                      _todate.text =
                          DateFormat('dd-MM-yyyy').format(pickeddate);
                    });
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _myLocLat,
                readOnly: true,
                decoration: const InputDecoration(
                  label: Text('Latitude'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _myLocLon,
                readOnly: true,
                decoration: const InputDecoration(
                  label: Text('Longitude'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  LatLng? pickedLocation = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChooseLocation(),
                    ),
                  );

                  _pickedLocation = pickedLocation!;
                  _myLocLat.text =
                      '${pickedLocation.latitude.toStringAsFixed(6)}';
                  _myLocLon.text =
                      '${pickedLocation.longitude.toStringAsFixed(6)}';
                },
                child: const Text(
                  'choose on map',
                ),
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.greenAccent,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                  minimumSize: Size(150, 40), //////// HERE
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  final requestDoc =
                      FirebaseFirestore.instance.collection('requests');
                  final userDoc =
                      FirebaseFirestore.instance.collection('users').doc(uid);

                  final snapshot = await userDoc.get();
                  String name = snapshot.data()!['name'];

                  // make entry in requests collection
                  requestDoc.add({
                    'requesterId': uid,
                    'requesterName': name,
                    'loc': {
                      'lat': _pickedLocation.latitude,
                      'lon': _pickedLocation.longitude,
                    },
                    'status': 'pending',
                    'from': _fromdate.text.trim(),
                    'to': _todate.text.trim(),
                    'place': _place.text.trim(),
                  }).then((value) {
                    // make entry in current user's request collection
                    userDoc.update({
                      'myRequests.${value.id}': {
                        'loc': {
                          'lat': _pickedLocation.latitude,
                          'lon': _pickedLocation.longitude,
                        },
                        'status': 'pending',
                        'from': _fromdate.text.trim(),
                        'to': _todate.text.trim(),
                        'place': _place.text.trim(),
                      }
                    });

                    Navigator.pop(context);
                  }).onError((error, stackTrace) {
                    print(error);
                  });
                },
                child: const Text(
                  'Submit',
                ),
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.greenAccent,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0)),
                  minimumSize: Size(150, 40), //////// HERE
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:core';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:security_system/police/available_request_on_map.dart';

import '../globals.dart';

class AvailableRequest extends StatefulWidget {
  static String id = "availableRequest";
  const AvailableRequest({Key? key}) : super(key: key);

  @override
  State<AvailableRequest> createState() => _AvailableRequestState();
}

class _AvailableRequestState extends State<AvailableRequest> {
  Location location = Location();
  List<LatLng> locations = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Requests'),
      ),
      body: FutureBuilder(
        future: getRequests(),
        builder: (context, AsyncSnapshot<List<Request>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          List<Request> requests = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(
                        Icons.home,
                        color: Colors.green,
                      ),
                      title: Text(requests[index].requesterName!),
                      subtitle: Text(
                        '${requests[index].place}\n${requests[index].from} to ${requests[index].to}',
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          final reqRef = FirebaseFirestore.instance
                              .collection('requests')
                              .doc(requests[index].id);

                          await reqRef.delete();

                          final userId = FirebaseAuth.instance.currentUser?.uid;
                          final userReqRef = FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId);

                          await userReqRef.update({
                            'myRequests.${requests[index].id}.status': 'done',
                          });

                          setState(() {
                            requests.removeAt(index);
                            locations.removeAt(index);
                          });
                        },
                        child: const Icon(
                          Icons.done_outline_rounded,
                          color: Colors.red,
                        ),
                      ),
                      horizontalTitleGap: 5.0,
                      isThreeLine: true,
                    );
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    // on press of this button, move to google map screen passing the locations list.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LocationOnMap(locations: locations),
                      ),
                    );
                  },
                  child: const Text('Show on Map'),
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.greenAccent,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    minimumSize: Size(150, 40), //////// HERE
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.greenAccent,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    minimumSize: Size(150, 40), //////// HERE
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<List<Request>> getRequests() async {
    final doc = FirebaseFirestore.instance.collection('requests');
    List<Request> result = [];

    final snapshot = await doc.get();

    for (var doc in snapshot.docs) {
      result.add(
        Request(
          id: doc.id,
          requesterID: doc.data()['requesterId'],
          location: LatLng(doc.data()['loc']['lat'], doc.data()['loc']['lon']),
          from: doc.data()['from'],
          to: doc.data()['to'],
          place: doc.data()['place'],
          status: doc.data()['status'],
          requesterName: doc.data()['requesterName'],
        ),
      );
    }

    // find the distance between each pair of points in adjacency matrix
    int n = result.length;
    List<List<double>> adjMat = [];

    final policeLocation = await getCurrentLocation();

    for (int i = 0; i <= n; i++) {
      List<double> row = [];
      for (int i = 0; i <= n; i++) {
        row.add(0);
      }
      adjMat.add(row);
    }

    for (int i = 1; i <= n; i++) {
      adjMat[0][i] = adjMat[i][0] = getDistance(
          LatLng(policeLocation.latitude, policeLocation.longitude),
          result[i - 1].location);
    }

    for (int i = 1; i <= n; i++) {
      for (int j = i + 1; j <= n; j++) {
        adjMat[i][j] = adjMat[j][i] =
            getDistance(result[i - 1].location, result[j - 1].location);
      }
    }

    // call a function getOrder passing this adjacency matrix to that, to get the order using TSP
    List<int> order = await getOrder(adjMat);

    List<Request> newResult = [];

    // now rearrange the points in that order and return the result.
    // set these points in a class variable list, in case the user presses the on map button then pass this.
    locations = [];
    locations.add(LatLng(policeLocation.latitude, policeLocation.longitude));
    for (int i = 1; i <= n; i++) {
      newResult.add(result[order[i] - 1]);
      locations.add(result[order[i] - 1].location);
    }

    return newResult;
  }

  List<int> simulatedAnnealing(List<List<double>> adjMat, double temperature,
      int maxIter, double alpha) {
    Random random = Random();

    List<int> currState = [];
    int n = adjMat.length;

    for (int i = 1; i < n; i++) {
      currState.add(i);
    }

    // do random shuffle
    currState.shuffle();

    // find current cost
    double currCost = adjMat[0][currState[0]];
    for (int i = 1; i < n - 1; i++) {
      currCost += adjMat[currState[i - 1]][currState[i]];
    }

    currCost += adjMat[currState[n - 2]][0];

    int currIter = 0;

    while (currIter < maxIter && temperature > 0) {
      // find next state by randomly swapping two index values
      // random.nextInt is exclusive of end value
      int x = random.nextInt(n - 1);
      int y = random.nextInt(n - 1);
      int t = currState[x];
      currState[x] = currState[y];
      currState[y] = t;

      // find next cost
      double nextCost = adjMat[0][currState[0]];
      for (int i = 1; i < n - 1; i++) {
        nextCost += adjMat[currState[i - 1]][currState[i]];
      }
      nextCost += adjMat[currState[n - 2]][0];

      if (nextCost < currCost) {
        currCost = nextCost;
      } else {
        double acceptP = exp((currCost - nextCost) / temperature);

        double p = random.nextDouble(); // some random value between 0 to 1

        if (p < acceptP) {
          currCost = nextCost;
        } else {
          // else swap back
          int t = currState[x];
          currState[x] = currState[y];
          currState[y] = t;
        }
      }

      currIter += 1;
      temperature *= alpha;
    }

    return currState;
  }

  Future<List<int>> getOrder(List<List<double>> adjMat) async {
    // The 0th location in adjMat(parameter) is the current police location(start and end of tour)
    // Make sure you are return the order in which first item is always 0
    // other items(from first index) can be permutated
    // Implement TSP

    List<int> result = simulatedAnnealing(adjMat, 10000, 100, 0.90);
    result.insert(0, 0);
    return result;
  }

  getCurrentLocation() async {
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

      var currentPosition = await location.getLocation();

      return currentPosition;
    }
  }

  double getDistance(LatLng src, LatLng des) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((des.latitude - src.latitude) * p) / 2 +
        cos(src.latitude * p) *
            cos(des.latitude * p) *
            (1 - cos((des.longitude - src.longitude) * p)) /
            2;

    return 12742 * asin(sqrt(a));
  }
}

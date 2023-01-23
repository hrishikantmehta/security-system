import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../globals.dart';

class MyRequests extends StatefulWidget {
  const MyRequests({Key? key}) : super(key: key);

  static String id = "MyRequest";

  @override
  State<MyRequests> createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
      ),
      body: FutureBuilder(
        future: getRequests(),
        builder: (context, AsyncSnapshot<List<Request>> myRequests) {
          if (!myRequests.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          List<Request> requests = myRequests.data!;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(
                  requests[index].status == 'pending'
                      ? Icons.pending
                      : Icons.done_outline_rounded,
                  color: Colors.green,
                ),
                title: Text(requests[index].place ?? ''),
                subtitle: Text(
                  '${requests[index].from} - ${requests[index].from}',
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    final userMyReqRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId);

                    await userMyReqRef.update({
                      'myRequests.${requests[index].id}': FieldValue.delete(),
                    });

                    final myReqRef = FirebaseFirestore.instance
                        .collection('requests')
                        .doc(requests[index].id);

                    await myReqRef.delete();

                    setState(() {
                      requests.removeAt(index);
                    });
                  },
                  child: Icon(
                    requests[index].status == 'pending' ? Icons.delete : null,
                    color: Colors.red,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Request>> getRequests() async {
    List<Request> result = [];

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    doc['myRequests'].forEach(
      (key, value) {
        result.add(
          Request(
            id: key,
            requesterID: uid,
            requesterName: value['name'],
            location: LatLng(value['loc']['lat'], value['loc']['lon']),
            from: value['from'],
            to: value['to'],
            place: value['place'],
            status: value['status'],
          ),
        );
      },
    );

    return result;
  }
}

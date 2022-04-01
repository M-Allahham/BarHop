import 'dart:convert';

import 'package:barhop/checkout_page.dart';
import 'package:barhop/constants.dart';
import 'package:barhop/portal_page.dart';
import 'package:barhop/redemption_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Redemption {
  String time, place;
  Redemption(this.time, this.place);
}

// ignore: must_be_immutable
class LoggedInWidget extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  final ref = FirebaseFirestore.instance.collection("customers");

  final refRedemptions = FirebaseFirestore.instance
      .collection("cities")
      .doc("lexington")
      .collection("redemptions");

  String customerID = '';

  List<Redemption> result = [];

  LoggedInWidget({Key? key}) : super(key: key);

  Future<String> getCheckoutURL(String customerID) async {
    http.Response res = await http.get(Uri.parse(
        'https://us-central1-barhop-26da1.cloudfunctions.net/createCheckout?uid=' +
            customerID));

    if (res.statusCode == 200) {
      String body = jsonDecode(res.body);

      return body;
    } else {
      throw "Unable to retrieve sessionID.";
    }
  }

  Future<String> getSubscriptionURL(String customerID) async {
    http.Response res = await http.get(Uri.parse(
        'https://us-central1-barhop-26da1.cloudfunctions.net/createPortalSession?uid=' +
            customerID));

    if (res.statusCode == 200) {
      String body = jsonDecode(json.encode(res.body));

      return body;
    } else {
      throw "Unable to retrieve sessionID.";
    }
  }

  Future<bool> isSubbed(String customerID) async {
    http.Response res = await http.get(Uri.parse(
        'https://us-central1-barhop-26da1.cloudfunctions.net/checkSubscribed?uid=' +
            customerID));

    if (res.statusCode == 200) {
      String body = jsonDecode(json.encode(res.body)).toString();
      return body != "[]";
    } else {
      throw "Cannot connect to subscription service";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.grey.shade900,
            automaticallyImplyLeading: true,
            title: const Text("BarHop"),
            actions: [
              TextButton(
                child:
                    const Text("Logout", style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
              )
            ]),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          // ignore: prefer_const_literals_to_create_immutables
          children: <Widget>[
            //const Spacer(),
            Text(user!.phoneNumber.toString(), textAlign: TextAlign.center),

            Row(
              children: [
                const Spacer(),
                //DATASTREAM FOR CURRENT STRIPE ID
                StreamBuilder(
                    stream: ref.snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        int count = snapshot.data!.docs.length;
                        for (int i = 0; i < count; i++) {
                          if (snapshot.data!.docs[i].id.toString() ==
                              uid.toString()) {
                            customerID =
                                snapshot.data!.docs[i]['stripeId'].toString();
                          }
                        }
                        return FutureBuilder<bool>(
                            future: isSubbed(customerID),
                            builder: (context, AsyncSnapshot<bool> snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data == false) {
                                  return ElevatedButton(
                                      onPressed: () async {
                                        final sessionId =
                                            await getCheckoutURL(customerID);

                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (_) => CheckoutPage(
                                                    sessionId: sessionId)));
                                      },
                                      child: const Text("Subscribe"));
                                } else {
                                  return ElevatedButton(
                                    onPressed: () async {
                                      final sessionID =
                                          await getSubscriptionURL(customerID);
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (_) => PortalPage(
                                                  sessionURL: sessionID)));
                                    },
                                    child: const Text("Manage Subscription"),
                                  );
                                }
                              }
                              return const CircularProgressIndicator();
                            });
                      } else {
                        return const CircularProgressIndicator();
                      }
                    }),
                const Spacer(),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const RedemptionWidget()));
                  },
                  child: const Text("Redeem"),
                ),
                const Spacer()
              ],
            ),
            //const Spacer(),
            StreamBuilder<QuerySnapshot>(
                stream: refRedemptions.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Text("There are no redemptions nearby");
                  } else {
                    return Flexible(
                        child: ListView(
                      children: getRedemptions(snapshot),
                      scrollDirection: Axis.vertical,
                    ));
                  }
                }),
          ],
        ));
  }

  getRedemptions(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data!.docs
        .map((doc) => ListTile(
            title: Text(locations[doc['location'].toString()].toString()),
            subtitle: Text(doc["time"])))
        .toList()
        .reversed
        .toList();
  }
}

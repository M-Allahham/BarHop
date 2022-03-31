import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RedemptionWidget extends StatefulWidget {
  const RedemptionWidget({Key? key}) : super(key: key);

  @override
  _RedemptionWidget createState() => _RedemptionWidget();
}

final ref = FirebaseFirestore.instance.collection("customers");
Future<String> redeemDrink() async {
  String url =
      'https://us-central1-barhop-26da1.cloudfunctions.net/redeemDrink?uid=' +
          FirebaseAuth.instance.currentUser!.uid.toString();
  final response = await http.get(Uri.parse(url));
  var responseData = json.decode(response.body).toString();
  return responseData;
}

Future<bool> checkDrink() async {
  String url =
      'Google cloud function check drink URL' +
          FirebaseAuth.instance.currentUser!.uid.toString();
  final response = await http.get(Uri.parse(url));
  var responseData = json.decode(response.body).toString();
  return responseData.trim() == 'true';
}

class _RedemptionWidget extends State<RedemptionWidget> {
  bool _isButtonDisabled = true;

  final _locationTextController = TextEditingController();

  Widget _buildPopupDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Redemption Successful!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        // ignore: prefer_const_literals_to_create_immutables
        children: <Widget>[
          const Text("Remember to tip your bartender :)"),
        ],
      ),
      actions: <Widget>[
        // ignore: deprecated_member_use
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Close'),
        ),
      ],
    );
  }

  CollectionReference redemptions = FirebaseFirestore.instance
      .collection('cities')
      .doc('lexington')
      .collection('redemptions');

  Widget buildRedeemButton() {
    return FutureBuilder<bool>(
        future: checkDrink(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text("Stinky!");
          } else {
            _isButtonDisabled = snapshot.data!;
            return ElevatedButton(
                child: const Text("Redeem"),
                onPressed: _isButtonDisabled
                    ? () async => {
                          await redeemDrink(),
                          redemptions
                              .add({
                                'time': DateFormat("MMMM dd, yyyy hh:mm:ss a")
                                    .format(DateTime.now()),
                                'location':
                                    _locationTextController.text.toUpperCase()
                              })
                              .then((value) => print("Redemption Added"))
                              .catchError((error) =>
                                  print("Failed to add redemption: $error")),
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst),
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  _buildPopupDialog(context)),
                        }
                    : null);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BarHop')),
      body: Column(
        children: <Widget>[
          const Spacer(),
          const Spacer(),
          const Spacer(),
          const Text("Let your bartender do the rest!"),
          const Spacer(),
          TextField(
            maxLength: 4,
            controller: _locationTextController,
            //decoration: const InputDecoration(hintText: "Enter Bar Code"),
          ),
          const Spacer(),
          buildRedeemButton(),
          const Spacer(),
          const Spacer(),
          const Spacer(),
          const Spacer(),
        ],
      ),
    );
  }
}

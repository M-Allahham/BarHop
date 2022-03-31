//@dart=2.9
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barhop/deal_search.dart';

class Deals extends StatefulWidget {
  const Deals({Key key}) : super(key: key);

  @override
  DataFromAPIState createState() => DataFromAPIState();
}

class DataFromAPIState extends State<Deals> {
  getUserData() async {
    http.Response response;
    // ignore: prefer_typing_uninitialized_variables
    var jsonData;
    try {
      response = await http
          .get(Uri.http('m-allahham.github.io', 'lexington/promos.json'));
      if (response.statusCode == 200) {
      } else {}
      jsonData = jsonDecode(response.body);
    } catch (e) {
      jsonData =
          jsonDecode("[{\"title\":\"No network\",\"text\":\"\",\"img\":\"\"}]");
    }

    List<Promo> promos = [];
    for (var p in jsonData) {
      Promo promo = Promo(p["title"], p["text"], p["location"], p["type"]);
      promos.add(promo);
    }
    return promos;
  }

  List<ExpansionTile> searchStrings = [];

// ADD SEARCH BAR !!!
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('BarHop'),
          actions: [
            IconButton(
              onPressed: () {
                showSearch(
                    context: context, delegate: DealSearch(searchStrings));
              },
              icon: const Icon(Icons.search),
            )
          ],
        ),
        body: Container(
          color: Colors.grey.shade900,
          constraints: const BoxConstraints.expand(),
          child: Card(
            color: Colors.grey.shade900,
            child: FutureBuilder(
              future: getUserData(),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  const Center(child: Text("Loading..."));
                } else if (snapshot.data[0].title == "No network") {
                  return const Center(child: Text("Cannot connect to network"));
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, i) {
                        searchStrings.add(ExpansionTile(
                            title: Row(
                              children: [
                                Text(snapshot.data[i].location,
                                    style: TextStyle(
                                        color:
                                            Colors.yellow.withOpacity(0.65))),
                                const Spacer(),
                                Text(
                                  snapshot.data[i].type,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.7)),
                                  textAlign: TextAlign.right,
                                )
                              ],
                            ),
                            backgroundColor: Colors.grey[800],
                            collapsedBackgroundColor: Colors.grey[800],
                            children: [
                              ListTile(
                                tileColor: Colors.grey[800],
                                contentPadding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                onTap: () => {},
                                title: Text(snapshot.data[i].title,
                                    style: TextStyle(
                                        color:
                                            Colors.yellow.withOpacity(0.65))),
                                subtitle: Text(snapshot.data[i].text,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.7))),
                              )
                            ]));
                        return Card(
                            child: ExpansionTile(
                                title: Row(children: [
                                  Text(snapshot.data[i].location,
                                      style: TextStyle(
                                          color:
                                              Colors.yellow.withOpacity(0.65))),
                                  const Spacer(),
                                  Text(
                                    snapshot.data[i].type,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.7)),
                                    textAlign: TextAlign.right,
                                  )
                                ]),
                                backgroundColor: Colors.grey[800],
                                collapsedBackgroundColor: Colors.grey[800],
                                children: [
                              ListTile(
                                tileColor: Colors.grey[800],
                                contentPadding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                onTap: () => {},
                                title: Text(snapshot.data[i].title,
                                    style: TextStyle(
                                        color:
                                            Colors.yellow.withOpacity(0.65))),
                                subtitle: Text(snapshot.data[i].text,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.7))),
                              )
                            ]));
                      });
                }
                return const Center(child: Text("Loading..."));
              },
            ),
          ),
        ));
  }
}

class Promo {
  final String title, text, location, type;

  Promo(this.title, this.text, this.location, this.type);
}

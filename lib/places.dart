//@dart=2.9
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Places extends StatefulWidget {
  const Places({Key key}) : super(key: key);

  @override
  DataFromAPIStatePlaces createState() => DataFromAPIStatePlaces();
}

class DataFromAPIStatePlaces extends State<Places> {
  DataFromAPIStatePlaces();

  String yelpAPIKey =
      "Yelp API Key here!";

  List<Place> places = [];

  // ignore: prefer_typing_uninitialized_variables
  var _result;
  // ignore: prefer_typing_uninitialized_variables
  var jsonData;
  // ignore: prefer_typing_uninitialized_variables
  var jsonDataYelp;

  http.Response response;
  http.Response responseYelp;

  @override
  void initState() {
    super.initState();

    getUserData().then((result) {
      setState(() {
        _result = result;
      });
    });
  }

  getUserData() async {
    // ignore: prefer_typing_uninitialized_variables

    try {
      response = await http
          .get(Uri.http('m-allahham.github.io', 'lexington/places.json'));

      if (response.statusCode == 200) {
      } else {}
      jsonData = jsonDecode(response.body);
    } catch (e) {
      jsonData =
          jsonDecode("[{\"name\":\"No network\",\"desc\":\"\",\"biz\":\"\"}]");
    }

    for (var p in jsonData) {
      Place place =
          Place(p["name"], p["desc"], p["biz"], 0.0, "", true, 0.0, 0.0, "");
      places.add(place);
    }

    try {
      for (int i = 0; i < places.length; i++) {
        responseYelp = await http.get(
            Uri.http(
                'api.yelp.com', 'v3/businesses/' + places[i].biz.toString()),
            headers: {HttpHeaders.authorizationHeader: yelpAPIKey});

        if (response.statusCode == 200) {
        } else {}
        jsonDataYelp = jsonDecode(responseYelp.body);

        String start = "is_open_now: "; //first thing to look for
        String end = "}], transactions:"; //Last thing to look for

        int startIndex = jsonDataYelp.toString().indexOf(start);
        int endIndex = jsonDataYelp.toString().indexOf(end);

        if (jsonDataYelp
                .toString()
                .substring(startIndex + start.length, endIndex) ==
            "true") {
          places[i].isopen = true;
        } else {
          places[i].isopen = false;
        }

        start = "rating: ";
        end = ", location:";

        startIndex = jsonDataYelp.toString().indexOf(start);
        endIndex = jsonDataYelp.toString().indexOf(end);

        places[i].rating = double.parse(jsonDataYelp
            .toString()
            .substring(startIndex + start.length, endIndex));

        start = "display_address: [";
        end = "], cross_streets:";

        startIndex = jsonDataYelp.toString().indexOf(start);
        endIndex = jsonDataYelp.toString().indexOf(end);

        places[i].location = jsonDataYelp
            .toString()
            .substring(startIndex + start.length, endIndex);

        start = "latitude: ";
        end = ", lon";

        startIndex = jsonDataYelp.toString().indexOf(start);
        endIndex = jsonDataYelp.toString().indexOf(end);

        places[i].latitude = double.parse(jsonDataYelp
            .toString()
            .substring(startIndex + start.length, endIndex));

        start = "longitude: ";
        end = "}, photos:";

        startIndex = jsonDataYelp.toString().indexOf(start);
        endIndex = jsonDataYelp.toString().indexOf(end);

        places[i].longitude = double.parse(jsonDataYelp
            .toString()
            .substring(startIndex + start.length, endIndex));

        start = "photos: [";
        end = ", http";

        startIndex = jsonDataYelp.toString().indexOf(start);
        endIndex = jsonDataYelp.toString().indexOf(end);

        places[i].photoURL = jsonDataYelp
            .toString()
            .substring(startIndex + start.length, endIndex);
      }
    } catch (e) {
      jsonDataYelp =
          jsonDecode("[{\"name\":\"No network\",\"desc\":\"\",\"biz\":\"\"}]");
    }
    return places;
  }

  Widget _buildCard(BuildContext context, int index) {
    if (places[index].name == "No Network") {
      return const Center(child: Text("Cannot connect to network"));
    }

    Text closed;
    if (!places[index].isopen) {
      closed = const Text(
        "Closed now",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.red),
      );
    } else {
      closed = const Text("Open",
          textAlign: TextAlign.center, style: TextStyle(color: Colors.green));
    }

    return Card(
        child: ExpansionTile(
            childrenPadding: const EdgeInsets.all(8),
            title: Text(places[index].name,
                style: TextStyle(color: Colors.yellow.withOpacity(0.65))),
            backgroundColor: Colors.grey[800],
            collapsedBackgroundColor: Colors.grey[800],
            children: [
          Text(places[index].desc,
              style: TextStyle(color: Colors.white.withOpacity(0.7))),
          const Text(""),
          Row(
            children: [
              Expanded(
                  child: Align(alignment: Alignment.bottomLeft, child: closed)),
              Expanded(
                child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(places[index].location,
                        textAlign: TextAlign.center)),
              ),
            ],
          )
        ]));
  }

  @override
  Widget build(BuildContext context) {
    if (_result == null) {
      return Container();
    }
    return Scaffold(
        appBar: AppBar(title: const Text('BarHop')),
        body: Container(
            color: Colors.grey.shade900,
            constraints: const BoxConstraints.expand(),
            child: Card(
                color: Colors.grey.shade900,
                child: ListView.builder(
                  itemCount: _result.length,
                  itemBuilder: _buildCard,
                ))));
  }
}

class Place {
  String name, desc, biz, location, photoURL;
  bool isopen;
  double rating, latitude, longitude;

  Place(this.name, this.desc, this.biz, this.rating, this.location, this.isopen,
      this.latitude, this.longitude, this.photoURL);
}

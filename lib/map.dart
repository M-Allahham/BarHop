import 'dart:math';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:barhop/places.dart';

// ignore: must_be_immutable
class GMap extends StatefulWidget {
  Set<Marker> _markers = {};

  GMap({Key? key}) : super(key: key);

  // ignore: non_constant_identifier_names
  Set<Marker> GetMarkers() {
    return _markers;
  }

  // ignore: non_constant_identifier_names
  void SetMarkers(Set<Marker> mark) {
    _markers = mark;
  }

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<GMap> {
  final LatLng _initialcameraposition = const LatLng(38.04859, -84.50032);

  late GoogleMapController _controller;
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  final Set<Marker> _markers = {};

  double avgLat = 0;
  double avgLon = 0;
  double largestDistance = 0;

  LatLngBounds bounds = LatLngBounds(
      northeast: const LatLng(0, 0), southwest: const LatLng(-1, -1));

  List<LatLng> latlnglist = [];

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  LatLngBounds computeBounds(List<LatLng> list) {
    assert(list.isNotEmpty);
    var firstLatLng = list.first;
    var s = firstLatLng.latitude,
        n = firstLatLng.latitude,
        w = firstLatLng.longitude,
        e = firstLatLng.longitude;
    for (var i = 1; i < list.length; i++) {
      var latlng = list[i];
      s = min(s, latlng.latitude);
      n = max(n, latlng.latitude);
      w = min(w, latlng.longitude);
      e = max(e, latlng.longitude);
    }
    return LatLngBounds(southwest: LatLng(s, w), northeast: LatLng(n, e));
  }

  Future<void> _onMapCreated(GoogleMapController _cntlr) async {
    _controller = _cntlr;
    _customInfoWindowController.googleMapController = _controller;
    Location location = Location();

    LocationData _locationData = await location.getLocation();
    latlnglist.add(LatLng(
        _locationData.latitude as double, _locationData.longitude as double));

    List<dynamic> placeslist = await DataFromAPIStatePlaces().getUserData();

    for (Place p in placeslist) {
      latlnglist.add(LatLng(p.latitude, p.longitude));
    }
    bounds = computeBounds(latlnglist);

    CameraUpdate update = CameraUpdate.newLatLngBounds(bounds, 50);
    _controller.animateCamera(update);
    if (mounted) {
      setState(() {
        for (Place p in placeslist) {
          Text closed;
          if (!p.isopen) {
            closed = const Text(
              "Closed now",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            );
          } else {
            closed = const Text("Open",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green));
          }

          avgLat += p.latitude;
          avgLon += p.longitude;
          _markers.add(Marker(
              markerId: MarkerId(p.name),
              position: LatLng(p.latitude, p.longitude),
              onTap: () {
                _customInfoWindowController.addInfoWindow!(
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(children: <Widget>[
                              //TOP TITLE
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                        //mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(p.name,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              )),
                                          const Divider(
                                            thickness: 2,
                                            indent: 10,
                                            endIndent: 10,
                                            color: Colors.black,
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: <Widget>[
                                              closed,
                                              Text(p.location,
                                                  style: const TextStyle(
                                                      color: Colors.white))
                                            ],
                                          )
                                        ]),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 80,
                              ),
                              const Divider(
                                thickness: 2,
                                indent: 10,
                                endIndent: 10,
                                color: Colors.black,
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 80,
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image.network(
                                      p.photoURL,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.25,
                                    ),
                                  ]),
                            ]),
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.4,
                        ),
                      ),
                    ],
                  ),
                  LatLng(p.latitude, p.longitude),
                );
              }));
        }
        avgLat /= placeslist.length;
        avgLon /= placeslist.length;
      });
    }

    String value = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
    _cntlr.setMapStyle(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('BarHop')),
        body: Stack(children: <Widget>[
          GoogleMap(
              onTap: (position) {
                _customInfoWindowController.hideInfoWindow!();
              },
              onCameraMove: (position) {
                _customInfoWindowController.onCameraMove!();
              },
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                  target: _initialcameraposition, zoom: 10, tilt: 30),
              onMapCreated: _onMapCreated,
              markers: _markers),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.95,
            offset: 20,
          ),
        ]));
  }
}

class SetMarkers {}

import 'dart:async';
//import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MaterialApp(
      home: MyApp(),
    )); //runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _homeloc = "searching...";
  Position _currentPosition;
  String gmaploc = "";
  double screenHeight, screenWidth;
  double latitude = 6.4676929;
  double longitude = 100.5067673;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController gmcontroller;
  CameraPosition _userpos;
  CameraPosition _home;
  MarkerId markerId1 = MarkerId("12");
  Set<Marker> markers = Set();

  static const LatLng _center = const LatLng(6.4676929, 100.5067673);

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    try {
      _controller = Completer();
      _userpos = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 17,
      );

      return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text('Select Location',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              backgroundColor: Colors.blueGrey[100],
            ),
            body: SingleChildScrollView(
                child: Column(
              children: [
                Container(
                    color: Colors.blueGrey[100],
                    child: Stack(children: <Widget>[
                      Container(
                        height: screenHeight - 235,
                        width: screenWidth - 10,
                        padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
                        child: GoogleMap(
                            mapType: MapType.normal,
                            initialCameraPosition: _userpos,
                            markers: markers.toSet(),
                            onMapCreated: (controller) {
                              _controller.complete(controller);
                            },
                            onTap: (newLatLng) {
                              _loadLoc(newLatLng);
                            }),
                      ),
                    ])),
                SizedBox(
                  height: 10,
                ),
                Column(children: [
                  Row(children: [
                    Container(
                      child: Text(
                        "  Your Current Address: ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]),
                  Row(children: <Widget>[
                    Flexible(
                      // Container(
                      //padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: Container(
                          child: Text(
                        "  " + _homeloc,
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      )),
                    ),
                  ]),
                ]),
                SizedBox(
                  height: 5,
                ),
                Row(children: [
                  Container(
                    child: Text(
                      "  Your Current Latitude: ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]),
                Row(children: [
                  Container(
                    child: Text(
                      "  " + latitude.toString(),
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                ]),
                SizedBox(
                  height: 5,
                ),
                Row(children: [
                  Container(
                    child: Text(
                      "  Your Current Longitude: ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]),
                Row(children: [
                  Container(
                    child: Text(
                      "  " + longitude.toString(),
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                ]),
              ],
            )),
            backgroundColor: Colors.blueGrey[100]),
      );
    } catch (e) {
      print(e);
    }
  }

  void _loadLoc(LatLng loc) {
    setState(() {
      print("insetstate");
      markers.clear();
      latitude = loc.latitude;
      longitude = loc.longitude;
      _getLocationfromlatlng(latitude, longitude);
      _home = CameraPosition(
        target: loc,
        zoom: 17,
      );
      markers.add(Marker(
        markerId: markerId1,
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(
          title: 'New Location',
          snippet: 'New Select Location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      ));
    });
    _userpos = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 14.4746,
    );
    _newhomeLocation();
  }

  _getLocationfromlatlng(double lat, double lng) async {
    final Geolocator geolocator = Geolocator()
      ..placemarkFromCoordinates(lat, lng);
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    _homeloc = first.addressLine;
    setState(() {
      _homeloc = first.addressLine;
      if (_homeloc != null) {
        latitude = lat;
        longitude = lng;
        return;
      }
    });
  }

  Future<void> _newhomeLocation() async {
    gmcontroller = await _controller.future;
    gmcontroller.animateCamera(CameraUpdate.newCameraPosition(_home));
  }

  Future<void> _getLocation() async {
    try {
      setState(() {
        markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: 'New Location',
            snippet: 'New Select Location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        ));
      });

      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) async {
        _currentPosition = position;
        if (_currentPosition != null) {
          final coordinates =
              new Coordinates(latitude, longitude); //_currentPosition.
          var addresses =
              await Geocoder.local.findAddressesFromCoordinates(coordinates);
          setState(() {
            var first = addresses.first;
            _homeloc = first.addressLine;
            if (_homeloc != null) {
              latitude = latitude; //_currentPosition.
              longitude = longitude; //_currentPosition.
              return;
            }
          });
        }
      }).catchError((e) {
        print(e);
      });
    } catch (exception) {
      print(exception.toString());
    }
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/constants/utils.dart';
import 'package:okoagirl/pages/sidebar.dart';
import 'package:okoagirl/services/authentication.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:okoagirl/services/crud.dart';

// ignore: must_be_immutable
class StudyPage extends StatefulWidget {
  final BaseAuth auth;
  final logoutCallback;
  final LocationData location;
  Key mapKey = UniqueKey();

  StudyPage({Key key, this.auth, this.logoutCallback, this.location})
      : super(key: key);
  void _signOut() async {
    try {
      await auth.signOut();
      logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  _StudyPageState createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  BitmapDescriptor solvedLocationIcon, unsolvedLocationIcon;
  Set<Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Stream<dynamic> query;
  GoogleMapController mapController;
  Location location = new Location();
  Geoflutterfire geo = Geoflutterfire();
  PermissionStatus _permissionGranted;
  LocationData currentLocation;
  StreamSubscription<LocationData> locationsubs;
  List<LatLng> latLng = List<LatLng>();
  double radius = 100.0;
  double zoomSize = 15;
  double tiltAngle = 80;
  double bearingAngle = 30;
  CrudMethods crudObj = new CrudMethods();
  String fullNames, userId;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  // double _originLatitude = -0.418893, _originLongitude = 36.948815;
  // double _destLatitude = 0.01388, _destLongitude = 37.077157;
  var pos;

  @override
  void initState() {
    super.initState();
    location = new Location();
    locationsubs = location.onLocationChanged.listen((LocationData cLoc) {
      setState(() {
        currentLocation = cLoc;
      });
      updatePinOnMap();
    });
    setCustomMapPin();
    _checkLocationPermission();
    _requestPermission();
    initialLocation();
  }

  @override
  void dispose() {
    locationsubs.cancel();
    super.dispose();
    // subscription.cancel();
  }

  void updatePinOnMap() async {
    CameraPosition cPosition = CameraPosition(
      zoom: zoomSize,
      tilt: tiltAngle,
      bearing: bearingAngle,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    setState(() {
      var pinPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);
      _markers.removeWhere((m) => m.markerId.value == 'pinLocationIcon');
      _markers.add(Marker(
          markerId: MarkerId('pinLocationIcon'),
          position: pinPosition, // updated position
          icon: BitmapDescriptor.defaultMarker));
    });
  }

  void initialLocation() async {
    pos = await location.getLocation();
  }

  void setCustomMapPin() async {
    solvedLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/icons/destination_map_marker.png');
    unsolvedLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/icons/pin.png');
  }

  Future<void> _checkLocationPermission() async {
    final PermissionStatus permissionGrantedResult =
        await location.hasPermission();
    setState(() {
      _permissionGranted = permissionGrantedResult;
    });
  }

  Future<void> _requestPermission() async {
    if (_permissionGranted != PermissionStatus.granted) {
      final PermissionStatus permissionRequestedResult =
          await location.requestPermission();
      setState(() {
        _permissionGranted = permissionRequestedResult;
      });
      if (permissionRequestedResult != PermissionStatus.granted) {
        return;
      }
    }
  }

  showInSnackBar(value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        style: TextStyle(fontSize: 20, color: Colors.white),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Theme.of(context).accentColor,
      duration: new Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    LatLng pinPosition = LatLng(-0.418893, 36.948815);
    CameraPosition initialLocation;
    if (currentLocation != null) {
      initialLocation = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: zoomSize,
          tilt: tiltAngle,
          bearing: bearingAngle);
    } else {
      initialLocation = CameraPosition(zoom: zoomSize, target: pinPosition);
    }
    return Scaffold(
      drawer: SideBar(
        logoutCallback: widget._signOut,
      ),
      appBar: new AppBar(
        title: Text(
          'Study Cases',
          style: kAppBarstyle,
        ),
        centerTitle: true,
        iconTheme: new IconThemeData(color: Colors.white),
        elevation: 0.0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              kPrimaryColor,
              kSecondaryColor,
            ],
          )),
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('cases').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return GoogleMap(
                key: widget.mapKey,
                myLocationEnabled: true,
                tiltGesturesEnabled: true,
                compassEnabled: false,
                mapType: MapType.normal,
                mapToolbarEnabled: true,
                markers: _markers,
                initialCameraPosition: initialLocation,
                zoomControlsEnabled: true,
                polylines: Set<Polyline>.of(polylines.values),
                onMapCreated: (GoogleMapController controller) {
                  controller.setMapStyle(Utils.mapStyles);
                  mapController = controller;
                  _controller.complete(controller);
                },
                onCameraMove: (CameraPosition cameraPosition) {
                  setState(() {
                    zoomSize = cameraPosition.zoom;
                    bearingAngle = cameraPosition.bearing;
                    tiltAngle = cameraPosition.tilt;
                  });
                },
              );
            } else if (snapshot.hasData) {
              for (int i = 0; i < snapshot.data.documents.length; i++) {
                _markers.add(Marker(
                    icon: snapshot.data.documents[i]['solved'] == true
                        ? solvedLocationIcon
                        : unsolvedLocationIcon,
                    markerId: MarkerId(
                        snapshot.data.documents[i]['crime'] + "$i" ?? ''),
                    position: LatLng(
                        snapshot.data.documents[i]['geolocation']['geopoint']
                            .latitude,
                        snapshot.data.documents[i]['geolocation']['geopoint']
                            .longitude),
                    draggable: false,
                    infoWindow: InfoWindow(
                        title: snapshot.data.documents[i]['crime'] ?? '')));
              }
              return GoogleMap(
                key: widget.mapKey,
                myLocationEnabled: true,
                tiltGesturesEnabled: true,
                compassEnabled: false,
                mapType: MapType.normal,
                mapToolbarEnabled: true,
                markers: _markers != null ? Set<Marker>.from(_markers) : null,
                initialCameraPosition: initialLocation,
                zoomControlsEnabled: true,
                polylines: Set<Polyline>.of(polylines.values),
                onMapCreated: (GoogleMapController controller) {
                  controller.setMapStyle(Utils.mapStyles);
                  mapController = controller;
                  _controller.complete(controller);
                  setState(() {});
                },
                onTap: (point) {
                  print(snapshot.data.documents.length);
                },
                onCameraMove: (CameraPosition cameraPosition) {
                  setState(() {
                    zoomSize = cameraPosition.zoom;
                    bearingAngle = cameraPosition.bearing;
                    tiltAngle = cameraPosition.tilt;
                  });
                },
              );
            }
            return Center(
                child: SizedBox(
                    height: 40, width: 40, child: CircularProgressIndicator()));
          }),
    );
  }

  Widget divider() {
    return Divider(
      color: Color(0xFF00bf72),
      height: 10,
      thickness: 3,
      indent: 80,
      endIndent: 80,
    );
  }
}

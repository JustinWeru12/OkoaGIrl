import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/models/counter.dart';
import 'package:okoagirl/pages/sidebar.dart';
import 'package:okoagirl/services/authentication.dart';
import 'package:okoagirl/services/crud.dart';
import 'package:okoagirl/services/reportData.dart';

class ReportPage extends StatefulWidget {
  final BaseAuth auth;
  final logoutCallback;

  const ReportPage({Key key, this.auth, this.logoutCallback}) : super(key: key);
  void _signOut() async {
    try {
      await auth.signOut();
      logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool more = false, anonym = false;
  CrudMethods crudObj = new CrudMethods();
  String greetingMes, _fullName = " ", image;
  bool isAdmin;
  String victimName,
      phone,
      location,
      assailantName,
      relationship,
      crime,
      persuing;
  List<String> actions = [
    "Legal Action",
    "Therapy",
    "Mass Information",
    "Medical Attention"
  ];

  Location geolocation = new Location();
  Geoflutterfire geo = Geoflutterfire();
  StreamSubscription<LocationData> locationsubs;
  PermissionStatus _permissionGranted;
  LocationData currentLocation;

  String greetingMessage() {
    var timeNow = DateTime.now().hour;

    if (timeNow <= 12) {
      return 'Good Morning';
    } else if ((timeNow > 12) && (timeNow <= 16)) {
      return 'Good Afternoon';
    } else if ((timeNow > 16) && (timeNow < 20)) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  String getImage() {
    var timeNow = DateTime.now().hour;
    print(timeNow);
    if (timeNow <= 12) {
      return 'assets/images/1.jpg';
    } else if ((timeNow > 12) && (timeNow <= 16)) {
      return 'assets/images/2.jpg';
    } else {
      return 'assets/images/3.jpg';
    }
  }

  @override
  void initState() {
    greetingMes = greetingMessage();
    image = getImage();
    _checkLocationPermission();
    _requestPermission();
    geolocation = new Location();
    locationsubs = geolocation.onLocationChanged.listen((LocationData cLoc) {
      setState(() {
        currentLocation = cLoc;
      });
    });
    crudObj.getDataFromUserFromDocument().then((value) {
      Map<String, dynamic> dataMap = value.data();
      setState(() {
        _fullName = dataMap['fullNames'];
        isAdmin = dataMap['admin'];
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    locationsubs.cancel();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    final PermissionStatus permissionGrantedResult =
        await geolocation.hasPermission();
    setState(() {
      _permissionGranted = permissionGrantedResult;
    });
  }

  Future<void> _requestPermission() async {
    if (_permissionGranted != PermissionStatus.granted) {
      final PermissionStatus permissionRequestedResult =
          await geolocation.requestPermission();
      setState(() {
        _permissionGranted = permissionRequestedResult;
      });
      if (permissionRequestedResult != PermissionStatus.granted) {
        return;
      }
    }
  }

  addToList() async {
    GeoFirePoint point = geo.point(
      latitude: currentLocation.latitude,
      longitude: currentLocation.longitude,
    );
    print(point.data);
    return point.data;
  }

  int currentStep = 0;
  bool complete = false;
  List<bool> done = [false, false, false, false];

  static final _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
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

  next() {
    if (currentStep + 1 != 4) {
      goTo(currentStep + 1);
      done[currentStep - 1] = true;
    } else {
      setState(() {
        complete = true;
        done[currentStep] = true;
      });
    }
    print(done);
  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    setState(() => currentStep = step);
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      addToList().then((value) {
        addService(value);
      });
    }
  }

  void addService(value) {
    Report reportData = new Report(
        victimName: victimName ?? "Anonymous",
        phone: phone,
        location: location,
        assailantName: assailantName,
        relationship: relationship,
        crime: crime,
        persuing: persuing,
        geolocation: value,
        solved: false);
    crudObj.createCase(reportData.getDataMap()).whenComplete(() {
      showInSnackBar("Case Reported ");
      _formKey.currentState.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        key: _scaffoldKey,
        drawer: SideBar(
          logoutCallback: widget._signOut,
        ),
        appBar: new AppBar(
          title: Text(
            'Report Case',
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
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                image,
                height: size.height * 0.3,
                width: size.width,
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(42),
                    topRight: Radius.circular(42)),
                child: SingleChildScrollView(
                  child: Container(
                    height: size.height * 0.84,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(42),
                            topRight: Radius.circular(42)),
                        color: kBackgroundColor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0, top: 8.0),
                          child: Text(
                            "$greetingMes, " +
                                _fullName.substring(0, _fullName.indexOf(' ')),
                            style: Theme.of(context)
                                .textTheme
                                .headline3
                                .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: kTextColor,
                                    fontSize: 20),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                "Our Cases",
                                style: kTitleTextstyle.copyWith(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        customDivider(size),
                        cases(),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "You are now in a safe environment.",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    .copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: kTextColor,
                                        fontFamily: "HelveticaNeueCyr",
                                        fontSize: 17),
                              ),
                              FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      more = !more;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        !more ? "More" : "Less",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3
                                            .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: kPrimaryColor,
                                                fontSize: 16),
                                      ),
                                      Icon(
                                        !more
                                            ? Icons.keyboard_arrow_down_rounded
                                            : Icons.keyboard_arrow_up_rounded,
                                        color: kPrimaryColor,
                                        size: 20,
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        ),
                        more
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Report any Gender Based discrimination that you or a female friend has faced or is going through and our experts will help you work towards a solution or persue legal action where necessary.",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline3
                                      .copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: kTextColor,
                                          fontFamily: "HelveticaNeueCyr",
                                          fontSize: 16),
                                ),
                              )
                            : Container(),
                        Expanded(
                          flex: 4,
                          child: Form(
                            key: _formKey,
                            child: Stepper(
                              physics: BouncingScrollPhysics(),
                              currentStep: currentStep,
                              onStepContinue: next,
                              onStepTapped: (step) => goTo(step),
                              onStepCancel: cancel,
                              steps: [
                                Step(
                                  title: const Text('Biodata'),
                                  isActive: done[0],
                                  state: done[0]
                                      ? StepState.complete
                                      : StepState.editing,
                                  content: Column(
                                    children: <Widget>[
                                      !anonym
                                          ? TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: 'Name of Victim'),
                                              validator: (String value) {
                                                if (value.isEmpty) {
                                                  return 'Enter Victim Name';
                                                }
                                                return null;
                                              },
                                              onSaved: (value) =>
                                                  victimName = value)
                                          : Container(),
                                      TextFormField(
                                        decoration: InputDecoration(
                                            labelText: 'Phone Number',
                                            hintText: '0712345678'),
                                        validator: (value) {
                                          if (value.isEmpty ||
                                              value.length < 10) {
                                            return 'Enter a valid Phone Number';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          phone = value;
                                        },
                                      ),
                                      TextFormField(
                                        decoration: InputDecoration(
                                            labelText: 'Location'),
                                        validator: (String value) {
                                          if (value.isEmpty) {
                                            return 'Enter the Location';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) => location = value,
                                      ),
                                    ],
                                  ),
                                ),
                                Step(
                                  title: const Text('Report'),
                                  isActive: done[1],
                                  state: done[1]
                                      ? StepState.complete
                                      : StepState.editing,
                                  content: Column(
                                    children: <Widget>[
                                      TextFormField(
                                        decoration: InputDecoration(
                                            labelText: 'Name of Assailant'),
                                        validator: (String value) {
                                          if (value.isEmpty) {
                                            return 'Enter Assailant Name';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) =>
                                            assailantName = value,
                                      ),
                                      TextFormField(
                                        decoration: InputDecoration(
                                            labelText:
                                                'Relationship to Assailant'),
                                        validator: (String value) {
                                          if (value.isEmpty) {
                                            return 'Relationship to Assailant';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) =>
                                            relationship = value,
                                      ),
                                      TextFormField(
                                        decoration: InputDecoration(
                                            labelText: 'Crime/Rights Violated'),
                                        validator: (String value) {
                                          if (value.isEmpty) {
                                            return 'Crime/Rights Violated';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) => crime = value,
                                      ),
                                    ],
                                  ),
                                ),
                                Step(
                                  isActive: done[2],
                                  state: done[2]
                                      ? StepState.complete
                                      : StepState.editing,
                                  title: const Text('Persuing'),
                                  content: Column(
                                    children: <Widget>[
                                      DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          contentPadding:
                                              EdgeInsets.fromLTRB(10, 0, 10, 0),
                                          filled: false,
                                          hintText: 'Help Needed',
                                        ),
                                        value: persuing,
                                        icon: Icon(Icons.arrow_drop_down),
                                        iconSize: 24,
                                        elevation: 16,
                                        style: TextStyle(color: Colors.black),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            persuing = newValue;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null) {
                                            return "Select Action";
                                          }
                                          return null;
                                        },
                                        items: actions
                                            .map<DropdownMenuItem<String>>(
                                                (action) {
                                          return DropdownMenuItem<String>(
                                            value: action,
                                            child: Text(action),
                                          );
                                        }).toList(),
                                      )
                                    ],
                                  ),
                                ),
                                Step(
                                  isActive: done[3],
                                  state: done[3]
                                      ? StepState.complete
                                      : StepState.editing,
                                  title: const Text('Done'),
                                  subtitle: const Text("Report!"),
                                  content: Column(
                                    children: <Widget>[
                                      CircleAvatar(
                                          backgroundColor: Colors.green,
                                          child: Icon(
                                            Icons.done_rounded,
                                            color: Colors.white,
                                          ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        FlatButton(
                            onPressed: () {
                              setState(() {
                                anonym = !anonym;
                              });
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  !anonym
                                      ? Icons.check_box_outline_blank_rounded
                                      : Icons.check_box_rounded,
                                  color: kPrimaryColor,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Report Anonymously",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline3
                                      .copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: kPrimaryColor,
                                          fontSize: 16),
                                )
                              ],
                            )),
                        Center(
                          child: RaisedButton(
                            elevation: 5.0,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(20.0)),
                            color: kSecondaryColor,
                            child: Text("Report",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            onPressed: validateAndSubmit,
                          ),
                        ),
                        Spacer(flex: 1)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget cases() {
    var reported = 0, solved = 0,pending=0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 30,
              color: kShadowColor,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('cases').snapshots(),
                builder: (context, snapshot) {
                  reported =
                      snapshot.hasData ? snapshot.data.documents.length : 0;
                  return Counter(
                    color: kInfectedColor,
                    number: reported,
                    title: "Reported",
                  );
                }),
            StreamBuilder(
                stream: FirebaseFirestore.instance.collection('cases').where("solved",isEqualTo: true).snapshots(),
                builder: (context, snapshot) {
                  solved =
                      snapshot.hasData ? snapshot.data.documents.length : 0;
                  return Counter(
                    color: kRecovercolor,
                    number: solved,
                    title: "Solved",
                  );
                }),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('cases').where("solved",isEqualTo: false).snapshots(),
              builder: (context, snapshot) {
                pending =
                      snapshot.hasData ? snapshot.data.documents.length : 0;
                return Counter(
                  color: kDeathColor,
                  number: pending,
                  title: "In Progress",
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget customDivider(size) {
    return Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 5.0, bottom: 5.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              height: 5,
              width: size.width * 0.2,
              decoration: BoxDecoration(
                  color: kSecondaryColor,
                  borderRadius: BorderRadius.circular(10))),
          Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                  height: 5,
                  width: size.width * 0.08,
                  decoration: BoxDecoration(
                      color: kSecondaryColor,
                      borderRadius: BorderRadius.circular(10))))
        ]));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:okoagirl/constants/dividers.dart';
import 'package:okoagirl/models/counter.dart';
import 'package:okoagirl/services/crud.dart';
import 'package:okoagirl/constants/constants.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  var email = TextEditingController();
  var profid = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String image, userDataId = '', description, name;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  CrudMethods crudObj = CrudMethods();
  List<String> list = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text(
          'Panel',
          style: kAppBarstyle,
        ),
        centerTitle: true,
        iconTheme: new IconThemeData(color: Colors.white),
        elevation: 0.0,
        backgroundColor: kSecondaryColor,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
              child: Text(
                "Users.",
                style: kHeadingTextStyle,
              ),
            ),
            CustomDivider(),
            DashBoard(),
            SizedBox(height: 10),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
              child: Text(
                "Manage Profiles.",
                style: kHeadingTextStyle,
              ),
            ),
            CustomDivider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 4),
                        blurRadius: 30,
                        color: kTextColor,
                      ),
                    ],
                  ),
                  child: _adminButton(context)),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _adminButton(context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
          child: Text(
            'You are registered with admin privileges, you are mandated with responsibilities to verify Health Practioner/Legal Officers Profiles for all users.\nYou can also register another user as an Administrator',
            style: TextStyle(fontFamily: 'Nexa', fontSize: 16.0),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 10.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Expanded(
                child: RaisedButton(
                  onPressed: () {
                    addAdmin(context);
                  },
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                  color: kSecondaryColor,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "ADD ADMIN",
                        style: TextStyle(
                            color: kBackgroundColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: InkWell(
                  onTap: () {
                    _addLawVerify(context);
                  },
                  child: Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: kSecondaryColor),
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          "VERIFY LAW PROFILE",
                          style: TextStyle(
                              color: kSecondaryColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: InkWell(
            onTap: () {
              _addVerify(context);
            },
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                border: Border.all(color: kSecondaryColor),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "VERIFY HEALTH PROFILE",
                    style: TextStyle(
                        color: kSecondaryColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> addAdmin(context) async {
    Size size = MediaQuery.of(context).size;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            backgroundColor: Colors.white,
            title: Text(
              'Enter the User\'s Email',
              style: TextStyle(
                  fontSize: 15.0,
                  fontFamily: 'Nexa',
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal),
              textAlign: TextAlign.center,
            ),
            content: Container(
              width: size.width * 0.7,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                        autofocus: false,
                        decoration: new InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
                          labelText: 'Email',
                          hintText: 'name@example.com',
                          hintStyle: TextStyle(
                              fontFamily: "WorkSansSemiLight",
                              fontSize: 17.0,
                              fontStyle: FontStyle.italic),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(5.0),
                            borderSide: new BorderSide(),
                          ),
                        ),
                        validator: (value) {
                          if (value.isEmpty)
                            return 'Please Enter an Email';
                          else if (!RegExp(
                                  r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                              .hasMatch(value)) {
                            return 'Please Enter a Valid Email';
                          } else {
                            return null; // print(_email);
                          }
                        },
                        controller: email,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      color: Theme.of(context).accentColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Text(
                        'Add Admin',
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.bold),
                      ),
                      textColor: Colors.white,
                      onPressed: () {
                        String _email = email.text.toString();
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          FirebaseFirestore.instance
                              .collection('user')
                              .where('email', isEqualTo: _email)
                              .get()
                              .then((querySnapshot) {
                            querySnapshot.docs.forEach((documentSnapshot) {
                              documentSnapshot.reference
                                  .update({'admin': true});
                            });
                          });
                          Navigator.of(context).pop();
                          print(_email);
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<bool> _addVerify(context) async {
    Size size = MediaQuery.of(context).size;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            backgroundColor: Colors.white,
            title: Text(
              'Enter the Id from the Email',
              style: TextStyle(
                  fontSize: 15.0,
                  fontFamily: 'Nexa',
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal),
              textAlign: TextAlign.center,
            ),
            content: Container(
              width: size.width * 0.7,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                        autofocus: false,
                        decoration: new InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
                          labelText: 'Profile Id',
                          hintText: 'id from email',
                          hintStyle: TextStyle(
                              fontSize: 17.0, fontStyle: FontStyle.italic),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(5.0),
                            borderSide: new BorderSide(),
                          ),
                        ),
                        validator: (value) {
                          if (value.isEmpty)
                            return 'Please Enter an Id';
                          else {
                            return null; // print(_email);
                          }
                        },
                        controller: profid,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      color: Theme.of(context).accentColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Text(
                        'Verify',
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.bold),
                      ),
                      textColor: Colors.white,
                      onPressed: () {
                        String _id = profid.text.toString();
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          FirebaseFirestore.instance
                              .collection('health')
                              .doc(_id)
                              .set({'isVerified': true},
                                  SetOptions(merge: true)).catchError((e) {
                            print(e.code);
                          });
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<bool> _addLawVerify(context) async {
    Size size = MediaQuery.of(context).size;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            backgroundColor: Colors.white,
            title: Text(
              'Enter the Id from the Email',
              style: TextStyle(
                  fontSize: 15.0,
                  fontFamily: 'Nexa',
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal),
              textAlign: TextAlign.center,
            ),
            content: Container(
              width: size.width * 0.7,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                        autofocus: false,
                        decoration: new InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
                          labelText: 'Profile Id',
                          hintText: 'id from email',
                          hintStyle: TextStyle(
                              fontSize: 17.0, fontStyle: FontStyle.italic),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(5.0),
                            borderSide: new BorderSide(),
                          ),
                        ),
                        validator: (value) {
                          if (value.isEmpty)
                            return 'Please Enter an Id';
                          else {
                            return null; // print(_email);
                          }
                        },
                        controller: profid,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      color: Theme.of(context).accentColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Text(
                        'Verify',
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.bold),
                      ),
                      textColor: Colors.white,
                      onPressed: () {
                        String _id = profid.text.toString();
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          FirebaseFirestore.instance
                              .collection('ProfessionalProfile')
                              .doc(_id)
                              .set({'isVerified': true},
                                  SetOptions(merge: true)).catchError((e) {
                            print(e.code);
                          });
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}

class DashBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 30,
              color: kTextColor,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('lawyers')
                    .snapshots(),
                builder: (context, snapshot) {
                  return Counter(
                    color: kInfectedColor,
                    number:
                        snapshot.hasData ? snapshot.data.documents.length : 0,
                    title: "Legal Officers",
                  );
                }),
            StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('health').snapshots(),
                builder: (context, snapshot) {
                  return Counter(
                    color: kDeathColor,
                    number:
                        snapshot.hasData ? snapshot.data.documents.length : 0,
                    title: "Health Practioners",
                  );
                }),
            StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('user').snapshots(),
                builder: (context, snapshot) {
                  return Counter(
                    color: kRecovercolor,
                    number:
                        snapshot.hasData ? snapshot.data.documents.length : 0,
                    title: "Users",
                  );
                }),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:okoagirl/constants/dividers.dart';
import 'package:okoagirl/models/counter.dart';
import 'package:okoagirl/pages/allusers.dart';
import 'package:okoagirl/pages/budgetpage.dart';
import 'package:okoagirl/pages/donationspage.dart';
import 'package:okoagirl/pages/proprofiles.dart';
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
  String image, userDataId = '', description, name, budgetName, budgetDesc;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  int budgetAmt;
  CrudMethods crudObj = CrudMethods();
  List<String> list = [];
  List budget;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  addBudget() {
    Map<String, dynamic> budgetData = {
      "name": budgetName,
      "amount": budgetAmt,
      "desc": budgetDesc,
    };
    crudObj.getBudget().then((value) {
      Map<String, dynamic> dataMap = value.data();
      crudObj.updateDueList(dataMap['budget'] ?? []
        ..addAll([budgetAmt]));
    });

    crudObj.createBudget(budgetData);
  }

  showInSnackBar(value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        style: TextStyle(fontSize: 20, color: Colors.white),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Theme.of(context).accentColor,
      duration: new Duration(milliseconds: 1500),
    ));
  }

  _getBudget() {
    crudObj.getBudget().then((value) {
      Map<String, dynamic> dataMap = value.data();
      setState(() {
        budget = dataMap['budget'] ?? [];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getBudget();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    "Our Budget",
                    style: kTitleTextstyle.copyWith(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            CustomDivider(),
            budgetTab(),
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
              child: Text(
                "ADD.",
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: InkWell(
                    onTap: () {
                      _addBudget(context);
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
                            "ADD ITEM",
                            style: TextStyle(
                                color: kSecondaryColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfessionalProfiles(
                                  index: 0,
                                )));
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfessionalProfiles(
                            index: 1,
                          )));
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

  Widget budgetTab() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('finances')
          .doc('budget')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        var userData = snapshot.data;
        int budget = userData['budget']
            .fold(0, (previous, current) => previous + current);
        int donation = userData['donations'] != null
            ? userData['donations']
                .fold(0, (previous, current) => previous + current)
            : 0;
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => BudgetPage()));
                  },
                  child: Counter(
                    color: kInfectedColor,
                    number: budget ?? 0,
                    title: "Budget",
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DonationsPage()));
                  },
                  child: Counter(
                    color: kDeathColor,
                    number: !snapshot.hasError ? donation : 0,
                    title: "Donations",
                  ),
                ),
                Counter(
                  color: kRecovercolor,
                  number: !snapshot.hasError
                      ? budget < donation
                          ? (donation - budget)
                          : (budget - donation)
                      : 0,
                  title: budget > donation ? "Remainder" : "Surplus",
                ),
              ],
            ),
          ),
        );
      },
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

  // Future<bool> _addVerify(context) async {
  //   Size size = MediaQuery.of(context).size;
  //   return showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(20.0))),
  //           backgroundColor: Colors.white,
  //           title: Text(
  //             'Enter the Id from the Email',
  //             style: TextStyle(
  //                 fontSize: 15.0,
  //                 fontFamily: 'Nexa',
  //                 fontWeight: FontWeight.normal,
  //                 fontStyle: FontStyle.normal),
  //             textAlign: TextAlign.center,
  //           ),
  //           content: Container(
  //             width: size.width * 0.7,
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: <Widget>[
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Form(
  //                     key: _formKey,
  //                     child: TextFormField(
  //                       style: TextStyle(fontSize: 16.0, color: Colors.black),
  //                       autofocus: false,
  //                       decoration: new InputDecoration(
  //                         contentPadding:
  //                             EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
  //                         labelText: 'Profile Id',
  //                         hintText: 'id from email',
  //                         hintStyle: TextStyle(
  //                             fontSize: 17.0, fontStyle: FontStyle.italic),
  //                         border: new OutlineInputBorder(
  //                           borderRadius: new BorderRadius.circular(5.0),
  //                           borderSide: new BorderSide(),
  //                         ),
  //                       ),
  //                       validator: (value) {
  //                         if (value.isEmpty)
  //                           return 'Please Enter an Id';
  //                         else {
  //                           return null; // print(_email);
  //                         }
  //                       },
  //                       controller: profid,
  //                     ),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: RaisedButton(
  //                     color: Theme.of(context).accentColor,
  //                     shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(20.0)),
  //                     child: Text(
  //                       'Verify',
  //                       style: TextStyle(
  //                           fontSize: 15.0, fontWeight: FontWeight.bold),
  //                     ),
  //                     textColor: Colors.white,
  //                     onPressed: () {
  //                       String _id = profid.text.toString();
  //                       if (_formKey.currentState.validate()) {
  //                         _formKey.currentState.save();
  //                         FirebaseFirestore.instance
  //                             .collection('health')
  //                             .doc(_id)
  //                             .set({'isVerified': true},
  //                                 SetOptions(merge: true)).catchError((e) {
  //                           print(e.code);
  //                         });
  //                         Navigator.of(context).pop();
  //                       }
  //                     },
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  // }

  // Future<bool> _addLawVerify(context) async {
  //   Size size = MediaQuery.of(context).size;
  //   return showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(20.0))),
  //           backgroundColor: Colors.white,
  //           title: Text(
  //             'Enter the Id from the Email',
  //             style: TextStyle(
  //                 fontSize: 15.0,
  //                 fontFamily: 'Nexa',
  //                 fontWeight: FontWeight.normal,
  //                 fontStyle: FontStyle.normal),
  //             textAlign: TextAlign.center,
  //           ),
  //           content: Container(
  //             width: size.width * 0.7,
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: <Widget>[
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Form(
  //                     key: _formKey,
  //                     child: TextFormField(
  //                       style: TextStyle(fontSize: 16.0, color: Colors.black),
  //                       autofocus: false,
  //                       decoration: new InputDecoration(
  //                         contentPadding:
  //                             EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
  //                         labelText: 'Profile Id',
  //                         hintText: 'id from email',
  //                         hintStyle: TextStyle(
  //                             fontSize: 17.0, fontStyle: FontStyle.italic),
  //                         border: new OutlineInputBorder(
  //                           borderRadius: new BorderRadius.circular(5.0),
  //                           borderSide: new BorderSide(),
  //                         ),
  //                       ),
  //                       validator: (value) {
  //                         if (value.isEmpty)
  //                           return 'Please Enter an Id';
  //                         else {
  //                           return null; // print(_email);
  //                         }
  //                       },
  //                       controller: profid,
  //                     ),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: RaisedButton(
  //                     color: Theme.of(context).accentColor,
  //                     shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(20.0)),
  //                     child: Text(
  //                       'Verify',
  //                       style: TextStyle(
  //                           fontSize: 15.0, fontWeight: FontWeight.bold),
  //                     ),
  //                     textColor: Colors.white,
  //                     onPressed: () {
  //                       String _id = profid.text.toString();
  //                       if (_formKey.currentState.validate()) {
  //                         _formKey.currentState.save();
  //                         FirebaseFirestore.instance
  //                             .collection('ProfessionalProfile')
  //                             .doc(_id)
  //                             .set({'isVerified': true},
  //                                 SetOptions(merge: true)).catchError((e) {
  //                           print(e.code);
  //                         });
  //                         Navigator.of(context).pop();
  //                       }
  //                     },
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  // }

  void _addBudget(context) async {
    Size size = MediaQuery.of(context).size;
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: 10,
                    left: 30,
                    right: 30,
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                width: size.width * 0.9,
                // height: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(25.0),
                    topRight: const Radius.circular(25.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Enter the Budget Information',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: 'Nexa',
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.normal),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                                autofocus: false,
                                decoration: new InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
                                  labelText: 'Budget Item',
                                  hintText: 'Sanitation',
                                  hintStyle: TextStyle(
                                      fontSize: 17.0,
                                      fontStyle: FontStyle.italic),
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(),
                                  ),
                                ),
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Please Enter an Item Name';
                                  else {
                                    return null; // print(_email);
                                  }
                                },
                                onSaved: (value) => budgetName = value,
                              )),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                                autofocus: false,
                                keyboardType: TextInputType.number,
                                decoration: new InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
                                  labelText: 'Budget Amount',
                                  hintText: '123',
                                  hintStyle: TextStyle(
                                      fontSize: 17.0,
                                      fontStyle: FontStyle.italic),
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(),
                                  ),
                                ),
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Please Enter an Amount';
                                  else {
                                    return null; // print(_email);
                                  }
                                },
                                onSaved: (value) =>
                                    budgetAmt = int.tryParse(value),
                              )),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                                autofocus: false,
                                decoration: new InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
                                  labelText: 'Description',
                                  hintStyle: TextStyle(
                                      fontSize: 17.0,
                                      fontStyle: FontStyle.italic),
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(),
                                  ),
                                ),
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Please Enter a Description';
                                  else {
                                    return null; // print(_email);
                                  }
                                },
                                onSaved: (value) => budgetDesc = value,
                              )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                                color: Theme.of(context).accentColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: Text(
                                  'Add Item',
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                textColor: Colors.white,
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    addBudget();
                                    showInSnackBar("Item Added");
                                  }
                                  Navigator.of(context).pop();
                                }),
                          )
                        ]),
                  ),
                ),
              ),
            );
          });
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
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfessionalProfiles(
                                    index: 0,
                                  )));
                    },
                    child: Counter(
                      color: kInfectedColor,
                      number:
                          snapshot.hasData ? snapshot.data.documents.length : 0,
                      title: "Legal Officers",
                    ),
                  );
                }),
            StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('health').snapshots(),
                builder: (context, snapshot) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfessionalProfiles(
                                    index: 1,
                                  )));
                    },
                    child: Counter(
                      color: kDeathColor,
                      number:
                          snapshot.hasData ? snapshot.data.documents.length : 0,
                      title: "Health Practioners",
                    ),
                  );
                }),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('user')
                    .where("admin", isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AllUsersPage()));
                    },
                    child: Counter(
                      color: kRecovercolor,
                      number:
                          snapshot.hasData ? snapshot.data.documents.length : 0,
                      title: "Users",
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

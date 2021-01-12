import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/pages/addItems.dart';
import 'package:okoagirl/pages/sidebar.dart';
import 'package:okoagirl/services/authentication.dart';
import 'package:okoagirl/services/crud.dart';
import 'package:okoagirl/services/selectProfilPicture.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final logoutCallback;
  final BaseAuth auth = new Auth();
  void _signOut() async {
    try {
      await auth.signOut();
      logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  ProfilePage({Key key, this.logoutCallback}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String data = "";
  String userId = 'userId';
  CrudMethods crudObj = new CrudMethods();
  String userMail = 'userMail';
  String profilPicture, _phone;
  String _fullNames;
  bool isHealth = false, isLegal = false;
  final _formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
    widget.auth.currentUser().then((id) {
      setState(() {
        userId = id;
      });
    });
    widget.auth.userEmail().then((mail) {
      setState(() {
        userMail = mail;
      });
    });

    crudObj.getDataFromUserFromDocument().then((value) {
      Map<String, dynamic> dataMap = value.data();
      setState(() {
        _fullNames = dataMap['fullNames'];
        profilPicture = dataMap['picture'];
        isHealth = dataMap['isHealth'];
        isLegal = dataMap['isLegal'];
      });
    });
  }

  String validateEmail(String value) {
    if (value.isEmpty ||
        !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(value)) {
      return 'Enter a Valid email';
    } else
      return null;
  }

  String validatePhone(String value) {
    if (value.length != 10)
      return 'Enter a valid Phone Number';
    else
      return null;
  }

  String validateName(String value) {
    if (!value.contains(' ') || (value.length < 5))
      return 'Enter a Full Name';
    else
      return null;
  }

  void _openModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            child: SelectProfilPicture(),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(25.0),
                topRight: const Radius.circular(25.0),
              ),
            ),
          );
        });
  }

  Widget pageConstruct(userData, context) {
    Widget fullNames() {
      return ListTile(
        onTap: () {
          print('height = ' + MediaQuery.of(context).size.height.toString());
          print('width = ' + MediaQuery.of(context).size.width.toString());
        },
        leading: Icon(
          Icons.person,
          color: Colors.yellow,
          size: 20,
        ),
        title: Text(
          "Full Name",
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Colors.yellow),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    content: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                              decoration:
                                  InputDecoration(hintText: 'Full Names'),
                              onSaved: (value) => _fullNames = value,
                              validator: validateName,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              color: kPrimaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
                              child: Text(
                                "Validate",
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                  crudObj.createOrUpdateUserData({
                                    'fullNames': _fullNames,
                                    'date':
                                        DateTime.now().millisecondsSinceEpoch
                                  });
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                });
          },
        ),
        subtitle: Text(
          userData['fullNames'] ?? '',
          style: TextStyle(
            fontSize: 15.0,
            color: Colors.white,
          ),
        ),
      );
    }

    Widget phone() {
      return ListTile(
        leading: Icon(
          Icons.supervisor_account,
          color: Colors.yellow,
          size: 20,
        ),
        title: Text(
          "Phone No.",
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Colors.yellow),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    content: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                              decoration: InputDecoration(hintText: 'Phone No'),
                              keyboardType: TextInputType.number,
                              onSaved: (value) => _phone = value,
                              validator: validatePhone,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RaisedButton(
                              color: kPrimaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
                              child: Text(
                                "Validate",
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                  crudObj.createOrUpdateUserData(
                                      {'phone': _phone});
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                });
          },
        ),
        subtitle: Text(
          userData['phone'],
          style: TextStyle(fontSize: 15.0, color: Colors.white),
        ),
      );
    }

    Widget mail() {
      return ListTile(
        leading: Icon(
          Icons.mail,
          color: Colors.yellow,
          size: 20,
        ),
        title: Text(
          'Mail',
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
        subtitle: Text(
          userData['email'] ?? '',
          style: TextStyle(fontSize: 15.0, color: Colors.white),
        ),
      );
    }

    return Scaffold(
      drawer: SideBar(
        logoutCallback: widget._signOut,
      ),
      appBar: new AppBar(
        title: Text(
          'Account',
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Positioned.fill(
            //   child: Container(
            //     child: Image.asset(
            //       'assets/images/bg.png',
            //       fit: BoxFit.cover,
            //     ),
            //   ),
            // ),
            Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment(0, -0.5),
                  child: ClipPath(
                    clipper: BackgroundClipper(),
                    child: Hero(
                      tag: 'background',
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.75,
                        padding: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              kPrimaryColor,
                              kSecondaryColor,
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            fullNames(),
                            divider(),
                            phone(),
                            divider(),
                            mail(),
                            divider(),
                            // address(),
                            // divider(),
                            // notification(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0, -0.78),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.yellow,
                        width: 6,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _openModalBottomSheet(context);
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(userData['picture']),
                        minRadius: 30,
                        maxRadius: 83,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _addButton(),
          ],
        ),
      ),
    );
  }

  Widget _addButton() {
    return Container(
      width: 300.0,
      margin: EdgeInsets.only(top: 15),
      child: isHealth
          ? RaisedButton(
              onPressed: () {},
              padding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              child: Container(
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kPrimaryColor, kSecondaryColor],
                  ),
                ),
                child: Center(
                  child: Text(
                    "Already Registered ",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0),
                  ),
                ),
              ),
            )
          : isLegal
              ? RaisedButton(
                  onPressed: () {},
                  padding: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [kPrimaryColor, kSecondaryColor],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Already Register  ",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0),
                      ),
                    ),
                  ),
                )
              : RaisedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AddProfile()));
                  },
                  padding: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [kPrimaryColor, kSecondaryColor],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Register \nLegal/Health ",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget divider() {
    return Divider(
      color: Colors.yellow,
      height: 15,
      indent: 70,
      endIndent: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('user').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
              height: 40, width: 40, child: CircularProgressIndicator());
        }
        var userData = snapshot.data;
        return pageConstruct(userData, context);
      },
    );
  }
}

class BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var roundnessFactor = 50.0;

    var path = Path();

    path.moveTo(0, size.height * 0.33);
    path.lineTo(0, size.height - roundnessFactor);
    path.quadraticBezierTo(0, size.height, roundnessFactor, size.height);
    path.lineTo(size.width - roundnessFactor, size.height);
    path.quadraticBezierTo(
        size.width, size.height, size.width, size.height - roundnessFactor);
    path.lineTo(size.width, roundnessFactor * 2);
    path.quadraticBezierTo(size.width - 10, roundnessFactor,
        size.width - roundnessFactor * 1.5, roundnessFactor * 1.5);
    path.lineTo(
        roundnessFactor * 0.6, size.height * 0.33 - roundnessFactor * 0.3);
    path.quadraticBezierTo(
        0, size.height * 0.33, 0, size.height * 0.33 + roundnessFactor);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

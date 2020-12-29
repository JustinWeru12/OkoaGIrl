import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/pages/adminpanel.dart';
import 'package:okoagirl/pages/donate.dart';
import 'package:okoagirl/pages/help.dart';
import 'package:okoagirl/pages/profile.dart';
import 'package:okoagirl/pages/report.dart';
import 'package:okoagirl/services/authentication.dart';
import 'package:okoagirl/services/crud.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SideBar extends StatefulWidget {
  SideBar({Key key, this.userId, this.logoutCallback}) : super(key: key);

  final BaseAuth auth = new Auth();

  final String userId;
  final VoidCallback logoutCallback;
  void _signOut() async {
    try {
      await auth.signOut();
      logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  String userId;
  CrudMethods crudObj = new CrudMethods();
  String userMail;
  String _fullNames;
  String profilPicture;
  String image;
  bool isDriver = false, isAdmin = false, isSeller = false;
  @override
  void initState() {
    super.initState();
    crudObj.getDataFromUserFromDocument().then((value) {
      Map<String, dynamic> dataMap = value.data();
      print(value);
      setState(() {
        userId = dataMap['userId'];
        userMail = dataMap['email'];
        _fullNames = dataMap['fullNames'];
        profilPicture = dataMap['picture'];
        isAdmin = dataMap['admin'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0.0),
            color: kBackgroundColor,
            // image: DecorationImage(
            //     image: AssetImage('assets/images/bg.png'), fit: BoxFit.cover),
                ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new UserAccountsDrawerHeader(
                    accountEmail: new Text(
                      userMail ?? '',
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                    accountName: Row(
                      children: <Widget>[
                        new Text(
                          _fullNames ?? '',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ],
                    ),
                    currentAccountPicture: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kPrimaryColor,
                          width: 4,
                        ),
                      ),
                      child: new GestureDetector(
                        child: profilPicture != null
                            ? Center(
                                child: new CircleAvatar(
                                  backgroundImage:
                                      new NetworkImage(profilPicture),
                                  maxRadius: 70.0,
                                  minRadius: 60.0,
                                ),
                              )
                            : CircleAvatar(
                                child: Image.asset('assets/images/profile.png'),
                                minRadius: 60,
                                maxRadius: 93,
                              ),
                        onTap: () => {
                          Navigator.of(context).pop(),
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage()))
                        },
                      ),
                    ),
                    decoration: new BoxDecoration(
                        image: new DecorationImage(
                            image: AssetImage("assets/images/landscape.png"),
                            fit: BoxFit.fill)),
                  ),
                  ListTile(
                    leading: Icon(Icons.home, color: kTextColor),
                    title: Text('Home',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () => {
                      Navigator.of(context).pop(),
                      Navigator.pushReplacementNamed(context, '/'),
                    },
                  ),
                  isAdmin ? divider() : Container(),
                  isAdmin
                      ? ListTile(
                          leading: Icon(Icons.admin_panel_settings_rounded, color: kTextColor),
                          title: Text('Admin',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          onTap: () => {
                            Navigator.of(context).pop(),
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdminPanel()))
                          },
                        )
                      : Container(),
                  divider(),
                  ListTile(
                    leading: Icon(Icons.report, color: kTextColor),
                    title: Text('Report',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () => {
                      Navigator.of(context).pop(),
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ReportPage()))
                    },
                  ),
                  divider(),
                  ListTile(
                    leading: Icon(Icons.monetization_on, color: kTextColor),
                    title: Text('Donate',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () => {
                      Navigator.of(context).pop(),
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => DonatePage()))
                    },
                  ),
                  divider(),
                  ListTile(
                    leading: Icon(Icons.person, color: kTextColor),
                    title: Text('My Account',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () => {
                      Navigator.of(context).pop(),
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()))
                    },
                  ),
                  divider(),
                  ListTile(
                    leading: Icon(Icons.help, color: kTextColor),
                    title: Text('Get in Touch',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () => {
                      Navigator.of(context).pop(),
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HelpPage())),
                    },
                  ),
                  divider(),
                  ListTile(
                    leading: Icon(Icons.exit_to_app, color: kTextColor),
                    title: Text('Logout',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () async {
                      widget._signOut();
                      // Navigator.of(context).pop();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                ],
              ),
              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: Image.asset(
              //     'assets/icons/icon.png',
              //     height: MediaQuery.of(context).size.width * 0.2,
              //     width: MediaQuery.of(context).size.width * 0.2,
              //     fit: BoxFit.fitHeight,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget divider() {
    return Divider(
      color: Colors.blue.withOpacity(0.85),
      height: 10,
      indent: 50,
      endIndent: 20,
    );
  }
}

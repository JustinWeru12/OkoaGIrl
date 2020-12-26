import 'package:flutter/material.dart';
import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/pages/sidebar.dart';
import 'package:okoagirl/services/authentication.dart';

class StudyPage extends StatefulWidget {
   final BaseAuth auth;
  final logoutCallback;

  const StudyPage({Key key, this.auth, this.logoutCallback}) : super(key: key);
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
  @override
  Widget build(BuildContext context) {
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
    );
  }
}
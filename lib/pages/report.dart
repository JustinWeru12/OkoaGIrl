import 'package:flutter/material.dart';
import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/pages/sidebar.dart';
import 'package:okoagirl/services/authentication.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

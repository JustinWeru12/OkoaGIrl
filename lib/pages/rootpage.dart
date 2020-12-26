import 'package:okoagirl/pages/homepage.dart';
import 'package:okoagirl/pages/loginpage.dart';
import 'package:okoagirl/pages/onboarding.dart';
import 'package:okoagirl/services/authentication.dart';
import 'package:okoagirl/services/crud.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";
  CrudMethods crudObj = new CrudMethods();
  int check = 0;

  @override
  void initState() {
    super.initState();
    getDone();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  getDone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      check = prefs.getInt('counter');
      print(check);
    });
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
        authStatus = AuthStatus.LOGGED_IN;
        Navigator.of(context).pushReplacementNamed('/');
      });
    });
    setState(() {
      crudObj.getDataFromUserFromDocument().then((value) {
        authStatus = AuthStatus.LOGGED_IN;
        // Navigator.of(context).pushReplacementNamed('/');
      });
    });
  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 70.0,
          child: Image.asset('assets/icons/icon.png'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginSignUpPage(
          auth: widget.auth,
          loginCallback: loginCallback,
          title: "okoagirl",
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return check == 1
              ? new HomePage(
                  userId: _userId,
                  auth: widget.auth,
                  logoutCallback: logoutCallback,
                )
              : check == null
                  ? OnboardingScreen(
                      userId: _userId,
                      auth: widget.auth,
                      logoutCallback: logoutCallback,
                    )
                  : buildWaitingScreen();
        } else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }
  }
}

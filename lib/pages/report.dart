import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/models/counter.dart';
import 'package:okoagirl/pages/sidebar.dart';
import 'package:okoagirl/services/authentication.dart';
import 'package:okoagirl/services/crud.dart';

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
  String greetingMes, _fullName = " ", _userId, image;
  bool isAdmin;
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
    crudObj.getDataFromUserFromDocument().then((value) {
      Map<String, dynamic> dataMap = value.data();
      setState(() {
        _fullName = dataMap['fullNames'];
        isAdmin = dataMap['admin'];
        _userId = dataMap['userId'];
      });
    });
    super.initState();
  }

  int currentStep = 0;
  bool complete = false;

  next() {
    currentStep + 1 != 4
        ? goTo(currentStep + 1)
        : setState(() => complete = true);
  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    setState(() => currentStep = step);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                                  "Repoprt any Gender Based discrimination that you or a female friend has faced or is going through and our experts will help you work towards a solution or persue legal action where necessary.",
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
                          child: Stepper(
                            physics: BouncingScrollPhysics(),
                            currentStep: currentStep,
                            onStepContinue: next,
                            onStepTapped: (step) => goTo(step),
                            onStepCancel: cancel,
                            steps: [
                              Step(
                                title: const Text('Biodata'),
                                isActive: true,
                                state: StepState.complete,
                                content: Column(
                                  children: <Widget>[
                                    !anonym
                                        ? TextFormField(
                                            decoration: InputDecoration(
                                                labelText: 'Name of Victim'),
                                          )
                                        : Container(),
                                    !anonym
                                        ? TextFormField(
                                            decoration: InputDecoration(
                                                labelText: 'Phone Number'),
                                          )
                                        : Container(),
                                    TextFormField(
                                      decoration: InputDecoration(
                                          labelText: 'Location'),
                                    ),
                                  ],
                                ),
                              ),
                              Step(
                                title: const Text('Report'),
                                isActive: true,
                                state: StepState.complete,
                                content: Column(
                                  children: <Widget>[
                                    TextFormField(
                                      decoration: InputDecoration(
                                          labelText: 'Name of Assailant'),
                                    ),
                                    TextFormField(
                                      decoration: InputDecoration(
                                          labelText:
                                              'Relationship to Assailant'),
                                    ),
                                    TextFormField(
                                      decoration: InputDecoration(
                                          labelText: 'Crime/Rights Violated'),
                                    ),
                                  ],
                                ),
                              ),
                              Step(
                                isActive: false,
                                state: StepState.editing,
                                title: const Text('Persuing'),
                                content: Column(
                                  children: <Widget>[
                                    TextFormField(
                                      decoration: InputDecoration(
                                          labelText: 'Help Needed'),
                                    ),
                                  ],
                                ),
                              ),
                              Step(
                                state: StepState.complete,
                                title: const Text('Done'),
                                subtitle: const Text("Report!"),
                                content: Column(
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor: Colors.green,
                                    )
                                  ],
                                ),
                              ),
                            ],
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
                            onPressed: () {},
                          ),
                        ),
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
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('cases')
          .doc('cases')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        var userData = snapshot.data;
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
                Counter(
                  color: kInfectedColor,
                  number: userData['reported'],
                  title: "Reported",
                ),
                Counter(
                  color: kRecovercolor,
                  number: userData['solved'],
                  title: "Solved",
                ),
                Counter(
                  color: kDeathColor,
                  number: userData['reported'] - userData['solved'],
                  title: "In Progress",
                ),
              ],
            ),
          ),
        );
      },
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/models/counter.dart';
import 'package:okoagirl/pages/sidebar.dart';
import 'package:okoagirl/services/authentication.dart';
import 'package:okoagirl/services/crud.dart';

class DonatePage extends StatefulWidget {
  DonatePage({Key key, this.auth, this.logoutCallback}) : super(key: key);
  final BaseAuth auth;
  final logoutCallback;
  void _signOut() async {
    try {
      await auth.signOut();
      logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  _DonatePageState createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  int tip = 0;
  bool customTip = false, more = false, anonym = false;
  List<String> tipPic = [
    'assets/icons/cookie.png',
    'assets/icons/cup.png',
    'assets/icons/muffin.png',
    'assets/icons/choco.png',
    'assets/icons/burger.png',
    'assets/icons/present.png',
  ];
  List<int> prices = [], tips = [50, 100, 200, 500, 1000, 0];
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        drawer: SideBar(
          logoutCallback: widget._signOut,
        ),
        resizeToAvoidBottomInset: true,
        appBar: new AppBar(
          title: Text(
            'Donate',
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
                            style: Theme.of(context).textTheme.headline3.copyWith(
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
                                "Our Budget",
                                style: kTitleTextstyle.copyWith(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        customDivider(size),
                        budget(),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "A Little Help Goes a Long Way.",
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
                                  "Help facilitate change by making a small contribution towards helping a girl. A shilling towards a difference.\nAll proceeds go to helping the girl child fight for her rights or helping a girl in need",
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
                        Padding(
                          padding: const EdgeInsets.all(0),
                          child: GridView.builder(
                              padding: const EdgeInsets.all(8.0),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: size.width > 400 ? 3 : 2,
                                crossAxisSpacing: 6,
                                mainAxisSpacing: 10,
                                childAspectRatio: 2.75,
                              ),
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: tips.length,
                              itemBuilder: (BuildContext context, int i) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      tip = tips[i];
                                      if (tips[i] != 0) {
                                        if (customTip == true) {
                                          customTip = false;
                                        }
                                      } else
                                        customTip = true;
                                    });
                                  },
                                  child: TipButton(
                                    text: tips[i] != 0
                                        ? tips[i].toString()
                                        : 'Custom',
                                    image: tipPic[i],
                                    color: tip == tips[i]
                                        ? Colors.green
                                        : kBackgroundColor,
                                  ),
                                );
                              }),
                        ),
                        customTip ? _buildTipField() : Container(),
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
                                  "Donate Anonymously",
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
                            child: Text("Donate",
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

  Widget _buildTipField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 10.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        initialValue: '100',
        keyboardType: TextInputType.number,
        key: new Key('tip'),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
          labelText: 'CustomTip',
          hintText: '100',
          hintStyle: kSubTextStyle,
          labelStyle: kSubTextStyle,
          prefixIcon: new Icon(
            Icons.phone,
            color: kSecondaryColor,
          ),
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(42),
            borderSide: new BorderSide(),
          ),
          filled: true,
          fillColor: kBackgroundColor.withOpacity(0.75),
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Enter a valid Amount';
          }
          return null;
        },
        onSaved: (value) {
          tip = int.tryParse(value);
        },
        onChanged: (value) {
          tip = int.tryParse(value);
        },
      ),
    );
  }

  Widget budget() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('budget')
          .doc('budget')
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
                  number: userData['budget'],
                  title: "Budget",
                ),
                Counter(
                  color: kDeathColor,
                  number: userData['donated'],
                  title: "Donations",
                ),
                Counter(
                  color: kRecovercolor,
                  number: userData['budget'] - userData['donated'],
                  title: "Remainder",
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

class TipButton extends StatelessWidget {
  final String text, image;
  final Color color;

  const TipButton({Key key, this.text, this.image, this.color})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              offset: Offset(2, 4),
              blurRadius: 6,
              color: Colors.green,
            ),
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Image.asset(
            image,
            height: 25,
            width: 25,
            fit: BoxFit.contain,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(text == 'Custom' ? "$text" : "Kshs. $text",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                )),
          ),
          Container()
        ]));
  }
}

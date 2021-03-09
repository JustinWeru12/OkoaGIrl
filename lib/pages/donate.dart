import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/models/counter.dart';
import 'package:okoagirl/pages/budgetpage.dart';
import 'package:okoagirl/pages/donationspage.dart';
import 'package:okoagirl/pages/sidebar.dart';
import 'package:okoagirl/services/authentication.dart';
import 'package:okoagirl/services/crud.dart';
import 'package:okoagirl/services/stripeservice.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:progress_dialog/progress_dialog.dart';

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
  bool customTip = true, more = false, anonym = false;
  List<String> tipPic = [
    'assets/icons/cookie.png',
    'assets/icons/cup.png',
    'assets/icons/muffin.png',
    'assets/icons/choco.png',
    'assets/icons/burger.png',
    'assets/icons/present.png',
  ];
  List<int> prices = [], tips = [50, 100, 200, 500, 1000, 0];
  List<int> amounts = [];
  CrudMethods crudObj = new CrudMethods();
  String greetingMes, _fullName = " ", image, userId;
  bool isAdmin;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String greetingMessage() {
    var timeNow = DateTime.now().hour;

    if ((timeNow > 3) && (timeNow <= 12)) {
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

  showInSnackBar(value) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        value,
        style: TextStyle(fontSize: 20, color: Colors.white),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Theme.of(context).accentColor,
      duration: new Duration(milliseconds: 1500),
    ));
  }

  String convertCardNumber(String src, String divider) {
    String newStr = '';
    int step = 4;
    for (int i = 0; i < src.length; i += step) {
      newStr += src.substring(i, math.min(i + step, src.length));
      if (i + step < src.length) newStr += divider;
    }
    return newStr;
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
      });
    });
    getCurrentUID().then((value) {
      setState(() {
        userId = value;
      });
    });
    StripeService.init();
    super.initState();
  }

  addDonation() {
    Map<String, dynamic> budgetData = {
      "name": !anonym ? _fullName : "Anonymous",
      "amount": tip,
      "desc": '',
    };
    crudObj.getBudget().then((value) {
      Map<String, dynamic> dataMap = value.data();
      crudObj.updatePaidList(dataMap['donations'] ?? []
        ..addAll([tip]));
    });

    crudObj.createDonation(
        budgetData, DateTime.now().millisecondsSinceEpoch.toString());
  }

  Future<String> getCurrentUID() async {
    return (FirebaseAuth.instance.currentUser).uid;
  }

  Future<bool> payViaNewCard(BuildContext context) async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    int _amount = tip * 100;
    var response = await StripeService.payWithNewCard(
      amount: _amount.toString(),
      currency: 'KES',
    );
    if (response.success) {
      addDonation();
      showInSnackBar("Donation Made");
    }
    await dialog.hide();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response.message),
      duration:
          new Duration(milliseconds: response.success == true ? 1200 : 3000),
    ));
    return response.success;
  }

  Future<bool> payViaExistingCard(BuildContext context, card) async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var expiryArr = card['expiryDate'].split('/');
    int _amount = tip * 100;
    CreditCard stripeCard = CreditCard(
      number: card['cardNumber'],
      expMonth: int.parse(expiryArr[0]),
      expYear: int.parse(expiryArr[1]),
    );
    var response = await StripeService.payViaExistingCard(
        amount: _amount.toString(), currency: 'KES', card: stripeCard);
    if (response.success) {
      addDonation();
      showInSnackBar("Donation Made");
    }
    await dialog.hide();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response.message),
      duration: new Duration(milliseconds: 1200),
    ));
    return response.success;
  }

  void openCheckoutSheet(context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20.0),
                    topRight: const Radius.circular(20.0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              payViaNewCard(context).then((val) {
                                if (val) {}
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                padding:
                                    EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0)),
                                primary: kSecondaryColor),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                "NEW CARD",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 16.0),
                              ),
                            ),
                          ),
                          Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              openCardSheet(context);
                            },
                            style: ElevatedButton.styleFrom(
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0)),
                                primary: kSecondaryColor,
                                padding:
                                    EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0)),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                "SAVED CARD",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 16.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ));
          });
        });
  }

  void openCardSheet(context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(25.0),
                topRight: const Radius.circular(25.0),
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.27,
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(25.0),
                    topRight: const Radius.circular(25.0),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.27,
                      width: MediaQuery.of(context).size.width,
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("user")
                              .doc(userId)
                              .collection("cards")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container(
                                child: Center(
                                  child: Text("You do not have a saved card"),
                                ),
                              );
                            } else if (snapshot.data.documents.length <= 0) {
                              return Container(
                                child: Center(
                                  child: Text("You do not have a saved card"),
                                ),
                              );
                            }
                            return ListView.builder(
                              itemCount: snapshot.data.documents.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int i) {
                                var card = {
                                  'cardNumber': snapshot.data.documents[i]
                                      ['cardNumber'],
                                  'expiryDate': snapshot.data.documents[i]
                                      ['expiryDate'],
                                  'cardHolderName': snapshot.data.documents[i]
                                      ['cardHolderName'],
                                  'cvvCode': snapshot.data.documents[i]
                                      ['cvvCode'],
                                  'color': snapshot.data.documents[i]['color'],
                                  'showBackView': false,
                                };
                                return InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    payViaExistingCard(context, card)
                                        .then((val) {
                                      if (val) {}
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.25,
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      padding: EdgeInsets.all(32.0),
                                      decoration: BoxDecoration(
                                          color: card['color'] != null
                                              ? Color(card['color'])
                                              : Colors.purple[700],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'CREDIT CARD',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          SizedBox(height: 16.0),
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                height: 50,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        fit: BoxFit.contain,
                                                        image: AssetImage(
                                                            'assets/icons/chip.png'))),
                                              ),
                                              Flexible(
                                                  child: Center(
                                                      child: Text(
                                                          convertCardNumber(
                                                              card[
                                                                  'cardNumber'],
                                                              '-'),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  18.0)))),
                                            ],
                                          ),
                                          Spacer(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(card['expiryDate'],
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(card['cvvCode'],
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ],
                                          ),
                                          Spacer(),
                                          Text(card['cardHolderName'],
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0))
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                    ),
                  ],
                ),
              ),
            );
          });
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
                              TextButton(
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
                        TextButton(
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
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 5.0,
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(20.0)),
                              primary: kSecondaryColor,
                            ),
                            child: Text("Donate",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            onPressed: () {
                              if (customTip) {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                  openCheckoutSheet(context);
                                }
                              } else {
                                openCheckoutSheet(context);
                              }
                            },
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
    return Form(
      key: _formKey,
      child: Padding(
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
      ),
    );
  }

  Widget budget() {
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

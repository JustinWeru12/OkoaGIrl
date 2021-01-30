import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/services/cardData.dart';
import 'package:okoagirl/services/crud.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Color active = Colors.red;
  TextEditingController cardNumber = TextEditingController();
  TextEditingController year = TextEditingController();
  TextEditingController month = TextEditingController();
  TextEditingController cvc = TextEditingController();
  TextEditingController cardHolder = TextEditingController();

  ScrollController scrollController = ScrollController();
  String cardNo, cardYear, cardMonth, cardCVV, cardHolderName;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  CrudMethods crudObj = new CrudMethods();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection.index == 1) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
    });
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

  void addCard() {
    CardData cardData = new CardData(
        cardHolderName: cardHolderName,
        cvvCode: cardCVV,
        cardNumber: cardNo,
        expiryDate: convertMonthYear(cardMonth, cardYear),
        color: int.tryParse('0x${active.value.toRadixString(16)}'));
    crudObj.createOrUpdateCardData(cardData.getCardDataMap());
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

  String convertMonthYear(String month, String year) {
    if (month.isNotEmpty)
      return month + '/' + year;
    else
      return '';
  }

  @override
  Widget build(BuildContext context) {
    Widget addThisCard = InkWell(
      onTap: () {
        if (_formKey.currentState.validate()) {
          _formKey.currentState.save();
          addCard();
          showInSnackBar("ADDED");
        }
      },
      child: Container(
        height: 80,
        width: MediaQuery.of(context).size.width / 1.5,
        decoration: BoxDecoration(
            color: kActionColor,
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.16),
                offset: Offset(0, 5),
                blurRadius: 10.0,
              )
            ],
            borderRadius: BorderRadius.circular(9.0)),
        child: Center(
          child: Text("Save This Card",
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                  fontSize: 20.0)),
        ),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (_, constraints) => GestureDetector(
          onPanDown: (val) {
//            FocusScope.of(context).requestFocus(FocusNode());
          },
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            controller: scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Container(
                margin: const EdgeInsets.only(top: kToolbarHeight),
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'CARD',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CloseButton()
                      ],
                    ),
                    Container(
                      height: 220,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                          color: active,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'CREDIT CARD',
                            style: TextStyle(color: Colors.white),
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
                                              cardNumber.text, '-'),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0)))),
                            ],
                          ),
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(convertMonthYear(month.text, year.text),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text(cvc.text,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                          Spacer(),
                          Text(cardHolder.text,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Colors.red,
                          Colors.blue,
                          Colors.purple[700],
                          Colors.green[700],
                          Colors.lightBlueAccent
                        ]
                            .map((c) => InkWell(
                                  onTap: () {
                                    setState(() {
                                      active = c;
                                    });
                                  },
                                  child: Transform.scale(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ColorOption(c),
                                      ),
                                      scale: active == c ? 1.2 : 1),
                                ))
                            .toList(),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black,
                                blurRadius: 4,
                                spreadRadius: 1,
                                offset: Offset(0, 1))
                          ],
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10))),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: 16.0),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: Colors.grey[200],
                              ),
                              child: TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(16)
                                ],
                                controller: cardNumber,
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  return val.length != 16
                                      ? "Enter a Valid Card Number"
                                      : null;
                                },
                                onSaved: (val) {
                                  setState(() {
                                    cardNo = val;
                                  });
                                },
                                onChanged: (val) {
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Card Number'),
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.only(left: 16.0),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: Colors.grey[200],
                                    ),
                                    child: TextFormField(
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(2)
                                      ],
                                      controller: month,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Month'),
                                      validator: (val) {
                                        if (val.length != 2) {
                                          return "Enter a Month of Expiry e.g 01";
                                        } else if (int.tryParse(val) > 12) {
                                          return "Enter a Valid Month";
                                        } else {
                                          return null;
                                        }
                                      },
                                      onSaved: (val) {
                                        setState(() {
                                          cardMonth = val;
                                        });
                                      },
                                      onChanged: (val) {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 8.0,
                                ),
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.only(left: 16.0),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: Colors.grey[200],
                                    ),
                                    child: TextFormField(
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(2)
                                      ],
                                      controller: year,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Year'),
                                      validator: (val) {
                                        return val.length != 2
                                            ? "Enter a Year of Expiry e.g 22"
                                            : null;
                                      },
                                      onSaved: (val) {
                                        setState(() {
                                          cardYear = val;
                                        });
                                      },
                                      onChanged: (val) {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 8.0,
                                ),
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.only(left: 16.0),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: Colors.grey[200],
                                    ),
                                    child: TextFormField(
                                      controller: cvc,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'CVV'),
                                      validator: (val) {
                                        return val.length != 3
                                            ? "Enter a Valid CVV"
                                            : null;
                                      },
                                      onSaved: (val) {
                                        setState(() {
                                          cardCVV = val;
                                        });
                                      },
                                      onChanged: (val) {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 16.0),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: Colors.grey[200],
                              ),
                              child: TextFormField(
                                controller: cardHolder,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Name on card'),
                                validator: (val) {
                                  return !val.contains(" ")
                                      ? "Enter a Valid Name"
                                      : null;
                                },
                                onSaved: (val) {
                                  setState(() {
                                    cardHolderName = val;
                                  });
                                },
                                onChanged: (val) {
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: addThisCard,
                    ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ColorOption extends StatelessWidget {
  final Color color;

  const ColorOption(this.color, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)), color: color),
    );
  }
}

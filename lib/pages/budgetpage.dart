import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/services/crud.dart';

class BudgetPage extends StatefulWidget {
  BudgetPage({Key key}) : super(key: key);

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  CrudMethods crudObj = new CrudMethods();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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

  void _showDialogDelete(id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "You are about to delete this Record",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Are you sure you want to proceed?",
                  textAlign: TextAlign.justify,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    child: new Text(
                      "Ok",
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: () {
                      crudObj.deleteBudget(id);
                      Navigator.of(context).pop();
                      showInSnackBar("Deleted");
                    },
                  ),
                  Spacer(),
                  FlatButton(
                    child: new Text(
                      "Cancel",
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: new AppBar(
        title: Text(
          'Budget',
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
        child: Container(
          height: size.height,
          child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection("budget").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data.documents.length != 0
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.documents.length,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, i) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    onTap: () {
                                      showInSnackBar("LongPress to Delete");
                                    },
                                    onLongPress: () {
                                      _showDialogDelete(
                                          snapshot.data.documents[i].id);
                                    },
                                    title: Text(
                                        snapshot.data.documents[i]["name"],
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0)),
                                    subtitle: Text(
                                        snapshot.data.documents[i]["desc"],
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 16.0)),
                                    trailing: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: kPrimaryColor),
                                      child: Center(
                                        child: Text(
                                            "Ksh. ${snapshot.data.documents[i]["amount"]}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                Divider()
                              ],
                            );
                          })
                      : ListTile(
                          title: Text("There are no items in the budget",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0)),
                        );
                } else {
                  return Container();
                }
              }),
        ),
      ),
    );
  }
}

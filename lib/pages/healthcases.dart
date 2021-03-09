import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/services/crud.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthCasesPage extends StatefulWidget {
  @override
  _HealthCasesPageState createState() => _HealthCasesPageState();
}

class _HealthCasesPageState extends State<HealthCasesPage> {
  CrudMethods crudObj = new CrudMethods();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showDialogVerify(id) {
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
                  "You are about to mark this case as Complete",
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
                  TextButton(
                    child: new Text(
                      "Ok",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      crudObj.updateCaseData(id, {"solved": true});
                      Navigator.of(context).pop();
                      showInSnackBar("Solved");
                    },
                  ),
                  Spacer(),
                  TextButton(
                    child: new Text(
                      "Cancel",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w600),
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
      appBar: new AppBar(
        title: Text(
          'Cases',
          style: kAppBarstyle,
        ),
        bottomOpacity: 1,
        centerTitle: true,
        iconTheme: new IconThemeData(color: Colors.green),
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
              stream: FirebaseFirestore.instance
                  .collection("cases")
                  .where("solved", isEqualTo: false)
                  .where("persuing", isNotEqualTo: "Legal Action")
                  .snapshots(),
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
                                      showInSnackBar("LongPress to Complete");
                                    },
                                    onLongPress: () {
                                      _showDialogVerify(
                                          snapshot.data.documents[i].id);
                                    },
                                    title: Text(
                                        snapshot.data.documents[i]["crime"],
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0)),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Text(
                                              snapshot.data.documents[i]
                                                      ["persuing"] +
                                                  " - " +
                                                  snapshot.data.documents[i]
                                                      ["location"],
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16.0)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Text(
                                              "Phone: " +
                                                  snapshot.data.documents[i]
                                                      ["phone"],
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16.0)),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.phone),
                                      onPressed: () => {
                                        _makePhoneCall(
                                            'tel:${snapshot.data.documents[i]["phone"]}'),
                                      },
                                    ),
                                  ),
                                ),
                                Divider()
                              ],
                            );
                          })
                      : Center(
                          child: Text("There are no unsolved cases",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0)),
                        );
                } else {
                  return Container(
                      height: 40,
                      width: 40,
                      child: Center(child: CircularProgressIndicator()));
                }
              }),
        ),
      ),
    );
  }
}

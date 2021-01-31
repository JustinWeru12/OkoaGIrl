import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:okoagirl/constants/constants.dart';

class CasesPage extends StatefulWidget {
  @override
  _CasesPageState createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage> {
  TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(
            title: Text(
              'Cases',
              style: kAppBarstyle,
            ),
            bottomOpacity: 1,
            bottom: TabBar(
              isScrollable: true,
              unselectedLabelColor: Colors.white,
              labelColor: Colors.green,
              labelStyle:
                  TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              controller: _tabController,
              tabs: <Widget>[
                new Tab(
                    child: SizedBox(
                  width: size.width * 0.5,
                  child: Align(
                    alignment: Alignment.center,
                    child: new Row(
                      children: <Widget>[
                        new SizedBox(
                          width: size.width * 0.15,
                        ),
                        new Icon(Icons.book, size: 15),
                        new SizedBox(width: 5.0),
                        new Text(
                          'Unsolved',
                          textScaleFactor: 0.7,
                        ),
                      ],
                    ),
                  ),
                )),
                new Tab(
                    child: SizedBox(
                  width: size.width * 0.5,
                  child: Align(
                    alignment: Alignment.center,
                    child: new Row(
                      children: <Widget>[
                        new SizedBox(
                          width: size.width * 0.15,
                        ),
                        new Icon(Icons.healing_rounded, size: 15),
                        new SizedBox(
                          width: 5.0,
                        ),
                        new Text(
                          'Solved',
                          textScaleFactor: 0.7,
                        ),
                      ],
                    ),
                  ),
                )),
              ],
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: kBackgroundColor),
            ),
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
          body: TabBarView(
            controller: _tabController,
            children: [
              SingleChildScrollView(
                child: Container(
                  height: size.height,
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("cases")
                          .where("solved", isEqualTo: false)
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
                                            title: Text(
                                                snapshot.data.documents[i]
                                                    ["crime"],
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.0)),
                                            subtitle: Text(
                                                snapshot.data.documents[i]
                                                    ["persuing"]+" - "+snapshot.data.documents[i]
                                                    ["location"],
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16.0)),
                                          ),
                                        ),
                                        Divider()
                                      ],
                                    );
                                  })
                              : ListTile(
                                  title: Text("There are no unsolved cases",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0)),
                                );
                        } else {
                          return Container(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator());
                        }
                      }),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  height: size.height,
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("cases")
                          .where("solved", isEqualTo: true)
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
                                            title: Text(
                                                snapshot.data.documents[i]
                                                    ["crime"],
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.0)),
                                            subtitle: Text(
                                                snapshot.data.documents[i]
                                                    ["persuing"]+" - "+snapshot.data.documents[i]
                                                    ["location"],
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16.0)),
                                          ),
                                        ),
                                        Divider()
                                      ],
                                    );
                                  })
                              : ListTile(
                                  title: Text("There are no solved cases",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0)),
                                );
                        } else {
                          return Container(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator());
                        }
                      }),
                ),
              ),
            ],
          ),
        ));
  }
}

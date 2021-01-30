import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:okoagirl/constants/constants.dart';

class DonationsPage extends StatefulWidget {
  DonationsPage({Key key}) : super(key: key);

  @override
  _DonationsPageState createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: new AppBar(
        title: Text(
          'Donations',
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
                  FirebaseFirestore.instance.collection("donation").snapshots(),
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
                          title: Text("There are no donations",
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

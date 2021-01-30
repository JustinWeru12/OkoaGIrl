import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:okoagirl/constants/constants.dart';

class AllUsersPage extends StatefulWidget {
  @override
  _AllUsersPageState createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: new AppBar(
        title: Text(
          'Users',
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
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .where("admin", isEqualTo: false)
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
                                        snapshot.data.documents[i]["fullNames"],
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0)),
                                    subtitle: Text(
                                        snapshot.data.documents[i]["email"],
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 16.0)),
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

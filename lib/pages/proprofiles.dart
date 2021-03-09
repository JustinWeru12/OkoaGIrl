import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/services/crud.dart';
import 'package:okoagirl/services/profileData.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class ProfessionalProfiles extends StatefulWidget {
  final int index;

  const ProfessionalProfiles({Key key, this.index}) : super(key: key);
  @override
  _ProfessionalProfilesState createState() => _ProfessionalProfilesState();
}

class _ProfessionalProfilesState extends State<ProfessionalProfiles> {
  TabController _tabController;
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

  emailSender(recipient, name) async {
    final Email email = Email(
      body:
          'Welcome to Okoa Girl Child $name.\n Your Professional Profile in Okoa Girl Child has been carefully reviewed and approved.\n You can now view cases and case information.It\'s our hope that you can help the girl child.\n\nRegards,\n Administrator - Okoa Girl Child',
      subject: 'Account Verification',
      recipients: [recipient],
      isHTML: false,
    );
    await FlutterEmailSender.send(email);
  }

  void _showDialogVerify(id, coll, val, email, name, bool pType) {
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
                  pType
                      ? "You are abou to unverify this User"
                      : "You are about to Verify this User",
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
                      crudObj.createOrUpdateProData(id, coll, val);
                      if (!pType) {
                        emailSender(email, name);
                      }
                      Navigator.of(context).pop();
                      showInSnackBar(pType ? "Unverified" : "Verified");
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

  void _reviewUser(context, ProfileData user, id, coll, val) async {
    Size size = MediaQuery.of(context).size;
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: 10,
                    left: 30,
                    right: 30,
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                width: size.width * 0.96,
                height: size.height * 0.7,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(25.0),
                    topRight: const Radius.circular(25.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Name:  " + user.name,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0)),
                        Divider(),
                        Text("Email:  " + user.email,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0)),
                        Divider(),
                        Text("Bio: " + user.bio,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0)),
                        Divider(),
                        Text("License:  " + user.licenseNo ?? "",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0)),
                        Divider(),
                        Text("Phone:  " + user.phone,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0)),
                        Divider(),
                        Text("Docs",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 16.0)),
                        Center(
                          child: SizedBox(
                            height: size.height * 0.3,
                            child: ListView.builder(
                              itemCount: user.pictures.length,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemBuilder: (context, i) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: size.height * 0.3,
                                    width: size.width * 0.4,
                                    child: FadeInImage.memoryNetwork(
                                      placeholder: kTransparentImage,
                                      image: user.pictures[i],
                                      fit: BoxFit.cover,
                                      // height: 250,
                                      // width: 130.0,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Divider(),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).accentColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0))),
                                ),
                                child: Text(
                                  user.isVerified ? "Unverify" : 'Verify',
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _showDialogVerify(id, coll, val, user.email,
                                      user.name, user.isVerified);
                                }),
                          ),
                        )
                      ]),
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return DefaultTabController(
        length: 2,
        initialIndex: widget.index ?? 0,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(
            title: Text(
              'Verify',
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
                    // icon: Icon(Icons.hotel,size: 15,),
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
                          'Legal',
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
                          'Health',
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
                          .collection("lawyers")
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
                                              showInSnackBar(
                                                  "LongPress to Review");
                                            },
                                            onLongPress: () {
                                              ProfileData profileData =
                                                  ProfileData(
                                                name: snapshot.data.documents[i]
                                                    ["name"],
                                                bio: snapshot.data.documents[i]
                                                    ["bio"],
                                                idNo: snapshot.data.documents[i]
                                                    ["idNo"],
                                                phone: snapshot
                                                    .data.documents[i]["phone"],
                                                licenseNo: snapshot.data
                                                    .documents[i]["licenseNo"],
                                                email: snapshot
                                                    .data.documents[i]["email"],
                                                isVerified: snapshot.data
                                                    .documents[i]["isVerified"],
                                                pictures: snapshot.data
                                                    .documents[i]["pictures"],
                                              );
                                              _reviewUser(
                                                context,
                                                profileData,
                                                snapshot.data.documents[i].id,
                                                "lawyers",
                                                {
                                                  "isVerified": !snapshot
                                                          .data.documents[i]
                                                      ["isVerified"],
                                                },
                                              );
                                            },
                                            title: Text(
                                                snapshot.data.documents[i]
                                                    ["name"],
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.0)),
                                            subtitle: Text(
                                                snapshot.data.documents[i]
                                                    ["email"],
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16.0)),
                                            trailing: Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color:
                                                      snapshot.data.documents[i]
                                                              ["isVerified"]
                                                          ? Colors.orange
                                                          : kPrimaryColor),
                                              child: Center(
                                                child: Text(
                                                    snapshot.data.documents[i]
                                                            ["isVerified"]
                                                        ? "Verified"
                                                        : "Unverified",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                  title: Text("There are no registered Lawyers",
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
                          .collection("health")
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
                                              showInSnackBar(
                                                  "LongPress to Review");
                                            },
                                            onLongPress: () {
                                              ProfileData profileData =
                                                  ProfileData(
                                                name: snapshot.data.documents[i]
                                                    ["name"],
                                                bio: snapshot.data.documents[i]
                                                    ["bio"],
                                                idNo: snapshot.data.documents[i]
                                                    ["idNo"],
                                                phone: snapshot
                                                    .data.documents[i]["phone"],
                                                licenseNo: snapshot.data
                                                    .documents[i]["licenseNo"],
                                                email: snapshot
                                                    .data.documents[i]["email"],
                                                isVerified: snapshot.data
                                                    .documents[i]["isVerified"],
                                                pictures: snapshot.data
                                                    .documents[i]["pictures"],
                                              );
                                              _reviewUser(
                                                context,
                                                profileData,
                                                snapshot.data.documents[i].id,
                                                "health",
                                                {
                                                  "isVerified": !snapshot
                                                          .data.documents[i]
                                                      ["isVerified"],
                                                },
                                              );
                                            },
                                            title: Text(
                                                snapshot.data.documents[i]
                                                    ["name"],
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.0)),
                                            subtitle: Text(
                                                snapshot.data.documents[i]
                                                    ["email"],
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16.0)),
                                            trailing: Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color:
                                                      snapshot.data.documents[i]
                                                              ["isVerified"]
                                                          ? Colors.orange
                                                          : kPrimaryColor),
                                              child: Center(
                                                child: Text(
                                                    snapshot.data.documents[i]
                                                            ["isVerified"]
                                                        ? "Verified"
                                                        : "Unverified",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                  title: Text(
                                      "There are no registered Health Officers",
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

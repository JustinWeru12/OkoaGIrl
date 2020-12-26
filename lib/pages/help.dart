import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/pages/sidebar.dart';
import 'package:okoagirl/services/crud.dart';
import 'package:flutter/material.dart';
import 'package:okoagirl/services/authentication.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelpPage extends StatefulWidget {
  HelpPage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final logoutCallback;
  final String userId;

  void _signOut() async {
    try {
      await auth.signOut();
      logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final String _fullName = "Waweru Ndirangu";
  final String _status = "Software Developer";
  final String _bio =
      "\"Hi, I am a Freelance developer working under the banner Orion Industries. If you want to contact me or Get help about this product leave a message.\"";
  List<String> attachments = [];
  bool isHTML = false;
  var email = TextEditingController();
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String photo, scores, repos, followers, background, phone;
  int amount;

  updateAdmin(selectedDoc, newValues) {
    FirebaseFirestore.instance
        .collection('user')
        .doc(selectedDoc)
        .update(newValues)
        .catchError((e) {
      print(e);
    });
  }

  var userDocument = FirebaseFirestore.instance.collection('user').snapshots();

  CrudMethods crudObj = new CrudMethods();

  bool myAdmin;
  String userNames, userEmail;

  dynamic transactionInitialisation;

  setIndex(index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('index', index);
  }
  // TextEditingController email = TextEditingController();

  @override
  void initState() {
    crudObj.getDataFromUserFromDocument().then((value) {
      Map<String, dynamic> dataMap = value.data();
      setState(() {
        myAdmin = dataMap['admin'];
        userNames = dataMap['fullNames'];
        userEmail = dataMap['email'];

        print(myAdmin);
      });
    });
    // crudObj.getDeveloperData().then((value) {
    //   Map<String, dynamic> dataMap = value.data();
    //   setState(() {
    //     photo = dataMap['photo'];
    //     scores = dataMap['scores'];
    //     repos = dataMap['repos'];
    //     background = dataMap['bg'];
    //     followers = dataMap['followers'];
    //   });
    // });
    super.initState();
  }

  Widget _buildCoverImage(Size screenSize) {
    return Container(
      height: screenSize.height / 2.6,
      width: screenSize.width,
      child: FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image:
            'https://firebasestorage.googleapis.com/v0/b/nightlyfe-9fe92.appspot.com/o/private%2Fhome.png?alt=media&token=900267d4-25d9-4144-b7de-53b3f559804d',
        fit: BoxFit.cover,
        // height: 250,
        // width: 130.0,
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Container(
        width: 140.0,
        height: 140.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/me.jpeg'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(80.0),
          border: Border.all(
            color: Colors.white,
            width: 5.0,
          ),
        ),
      ),
    );
  }

  Widget _buildFullName() {
    TextStyle _nameTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.white,
      fontSize: 28.0,
      fontWeight: FontWeight.w700,
    );

    return Text(
      _fullName,
      style: _nameTextStyle,
    );
  }

  Widget _buildStatus(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        _status,
        style: TextStyle(
          fontFamily: 'Spectral',
          // color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String count) {
    TextStyle _statLabelTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 16.0,
      fontWeight: FontWeight.w200,
    );

    TextStyle _statCountTextStyle = TextStyle(
      color: Colors.black54,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count,
          style: _statCountTextStyle,
        ),
        Text(
          label,
          style: _statLabelTextStyle,
        ),
      ],
    );
  }

  Widget _buildStatContainer() {
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFEFF4F7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildStatItem("Followers", '500'),
          _buildStatItem("Repositories", '22'),
          _buildStatItem("Scores", '700'),
        ],
      ),
    );
  }

  Widget _buildBio(BuildContext context) {
    TextStyle bioTextStyle = TextStyle(
      // fontFamily: 'Spectral',
      fontWeight: FontWeight.w400, //try changing weight to w500 if not thin
      fontStyle: FontStyle.italic,
      color: Color(0xFF799497),
      fontSize: 16.0,
    );

    return Container(
      // color: kPrimaryColor,
      padding: EdgeInsets.all(8.0),
      child: Text(
        _bio,
        textAlign: TextAlign.center,
        style: bioTextStyle,
      ),
    );
  }

  Widget _buildSeparator(Size screenSize) {
    return Container(
      width: screenSize.width / 1.6,
      height: 2.0,
      color: Colors.black54,
      margin: EdgeInsets.only(top: 4.0),
    );
  }

  Widget _buildGetInTouch(BuildContext context) {
    return Container(
      // color: kPrimaryColor,
      padding: EdgeInsets.only(top: 8.0),
      child: Text(
        "Get in Touch with ${_fullName.split(" ")[0]},",
        style: TextStyle(fontFamily: 'Roboto', fontSize: 16.0),
      ),
    );
  }

  Widget _buildButtons() {
    // var width = MediaQuery.of(context).size.width * 0.5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () async {
                    _openModalBottomSheet(context);
                  },
                  child: Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: Color(0xFF404A5C),
                    ),
                    child: Center(
                      child: Text(
                        "FOLLOW",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: InkWell(
                  onTap: () {
                    // Wiredash.of(context).setUserProperties(
                    //     userEmail: userEmail, userId: userNames);
                    // Wiredash.of(context).show();
                    // emailSender();
                  },
                  child: Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          "MESSAGE",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      drawer: SideBar(logoutCallback: widget._signOut),
      appBar: new AppBar(
        title: Text(
          'Get in Touch',
          style: kAppBarstyle,
        ),
        centerTitle: true,
        iconTheme: new IconThemeData(color: Colors.green),
        elevation: 0.0,
        flexibleSpace: Container(
          color: kSecondaryColor,
        ),
      ),
      body: Stack(
        children: <Widget>[
          _buildCoverImage(screenSize),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: screenSize.height / 6.4),
                  _buildProfileImage(),
                  _buildFullName(),
                  _buildStatus(context),
                  _buildStatContainer(),
                  _buildBio(context),
                  _buildSeparator(screenSize),
                  SizedBox(height: 10.0),
                  _buildGetInTouch(context),
                  SizedBox(height: 8.0),
                  _buildButtons(),
                  myAdmin == true ? _buildSeparator(screenSize) : Container(),
                  SizedBox(height: 10.0),
                  _buildSeparator(screenSize),
                  SizedBox(height: 10.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(25.0),
                topRight: const Radius.circular(25.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(FontAwesomeIcons.githubAlt,
                            color: Color(0xFF051937)),
                        onPressed: () async {
                          const url = 'https://github.com/JustinWeru12';

                          if (await canLaunch(url)) {
                            await launch(url, forceSafariVC: false);
                          } else {
                            throw 'Could not launch $url';
                          }
                        }),
                    IconButton(
                        icon: Icon(
                          FontAwesomeIcons.bitbucket,
                          color: Color(0xFF004d7a),
                        ),
                        onPressed: () async {
                          const url = 'https://bitbucket.org/JustinWeru12/';

                          if (await canLaunch(url)) {
                            await launch(url, forceSafariVC: false);
                          } else {
                            throw 'Could not launch $url';
                          }
                        }),
                    IconButton(
                        icon: Icon(
                          FontAwesomeIcons.stackOverflow,
                          color: Color(0xFF008793),
                        ),
                        onPressed: () async {
                          const url =
                              'https://stackoverflow.com/users/13128818/king-mort';

                          if (await canLaunch(url)) {
                            await launch(url, forceSafariVC: false);
                          } else {
                            throw 'Could not launch $url';
                          }
                        }),
                    IconButton(
                        icon: Icon(
                          FontAwesomeIcons.instagram,
                          color: Color(0xFF00bf72),
                        ),
                        onPressed: () async {
                          const url =
                              'https://www.instagram.com/_justinweru.ke_/';

                          if (await canLaunch(url)) {
                            await launch(url, forceSafariVC: false);
                          } else {
                            throw 'Could not launch $url';
                          }
                        })
                  ]),
            ),
          );
        });
  }
}

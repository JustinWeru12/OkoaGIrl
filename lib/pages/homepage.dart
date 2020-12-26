import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/models/readmore.dart';
import 'package:okoagirl/pages/donate.dart';
import 'package:okoagirl/pages/report.dart';
import 'package:okoagirl/pages/sidebar.dart';
import 'package:okoagirl/pages/study.dart';
import 'package:okoagirl/services/authentication.dart';

class HomePage extends StatefulWidget {
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

  const HomePage({Key key, this.auth, this.logoutCallback, this.userId})
      : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> carousselText = [
    'Brave & Bold',
    'Girl Power',
    'Equal Participation',
    'Representation'
  ];
  List<String> carousselImages = [
    'assets/images/1.jpg',
    'assets/images/2.jpg',
    'assets/images/3.jpg',
    'assets/images/4.jpg',
  ];
  List<String> bottomImages = [
    'assets/images/a1.jpg',
    'assets/images/a2.jpg',
    'assets/images/a3.png',
    'assets/images/a4.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        drawer: SideBar(
          logoutCallback: widget._signOut,
        ),
        appBar: new AppBar(
          title: Text(
            'DashBoard',
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
          child: Column(children: [
            _carousel(carousselImages, carousselText),
            SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    "Time to Make a Difference",
                    style: kTitleTextstyle.copyWith(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            customDivider(size),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10.0,
                runSpacing: 10.0,
                children: [
                  _buildTabTile(
                      'Report',
                      "Repoprt any Gender Based discrimination that you or a female friend is going through and our experts will help you work towards a solution.",
                      ReportPage()),
                  _buildTabTile(
                      'Donate',
                      "Help facilitate change by making a small contribution towards this goal. A shilling towards a difference",
                      DonatePage()),
                  _buildTabTile(
                      'Study',
                      "From a collective of cases reported or solved by our experts, Learn more about the issues that the Girl is facing in the society and maybe make a difference.",
                      StudyPage())
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    "Our Projects & Patnerships",
                    style: kTitleTextstyle.copyWith(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            customDivider(size),
            _bottomImages(bottomImages),
          ]),
        ));
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

  Widget _carousel(images, text) {
    return CarouselSlider(
      options: CarouselOptions(
          height: MediaQuery.of(context).size.width * 0.65,
          viewportFraction: 0.8,
          enableInfiniteScroll: true,
          reverse: false,
          enlargeCenterPage: true,
          autoPlay: true),
      items: [0, 1, 2, 3].map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 10.0),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.asset(
                        images[i],
                        height: MediaQuery.of(context).size.height * 0.45,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.45,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(32),
                              bottomRight: Radius.circular(32)),
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                                Colors.black
                              ])),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            text[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ));
          },
        );
      }).toList(),
    );
  }

  Widget _bottomImages(images) {
    return CarouselSlider(
      options: CarouselOptions(
          height: MediaQuery.of(context).size.width * 0.45,
          viewportFraction: 0.8,
          enableInfiniteScroll: false,
          reverse: false,
          enlargeCenterPage: true,
          autoPlay: false),
      items: [0, 1, 2, 3].map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 10.0,left:10,right: 10),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.asset(
                        images[i],
                        height: MediaQuery.of(context).size.height * 0.45,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ));
          },
        );
      }).toList(),
    );
  }

  Widget _buildTabTile(title, subtitle, func) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => func));
      },
      child: Container(
        width: size.width * 0.45,
        decoration: new BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: new BorderRadius.circular(20.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 8.0,
            ),
            Container(
              height: 40.0,
              child: new RaisedButton(
                elevation: 5.0,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
                color: kSecondaryColor,
                child: Text(title,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => func));
                },
              ),
            ),
            SizedBox(height: 10.0),
            Center(
              child: Container(
                width: size.width * 0.4,
                child: new ReadMoreText(
                  subtitle,
                  textAlign: TextAlign.center,
                  trimLines: 3,
                  colorClickableText: kSecondaryColor,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: ' ...Read more',
                  trimExpandedText: ' Less',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

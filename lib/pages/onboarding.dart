import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/pages/homepage.dart';
import 'package:okoagirl/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final BaseAuth auth;
  final logoutCallback;
  final String userId;

  const OnboardingScreen({Key key, this.auth, this.logoutCallback, this.userId})
      : super(key: key);
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  setDone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', 1);
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 10.0,
      width: isActive ? 24.0 : 10.0,
      decoration: BoxDecoration(
        color: isActive ? kSecondaryColor : Color(0xFF959595),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

    Widget _showLogo() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Container(
          height: 150,
          width: 150,
          color: Colors.transparent,
          child: Hero(
            tag: 'hero',
            child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 10.0),
              child: Image.asset(
                'assets/icons/icon.png',
                // width: 50,
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _showLogo(),
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                child: PageView(
                  physics: ClampingScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/images/onboarding1.png',
                                ),
                                height: 200,
                                width: 200,
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Text(
                              'Okoa Girl Child',
                              style: kBoardingTextStyle,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 50),
                            Text(
                              'We Bring you a way to help the Girl.\n\n REPORT, DONATE\n & STUDY.',
                              style: kContentTextstyle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/images/onboarding2.png',
                                ),
                                height: 200,
                                width: 200,
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Text(
                              'REPORT CASES',
                              style: kBoardingTextStyle,
                            ),
                            SizedBox(height: 50),
                            Text(
                              'Log into your account anytime,report a case and our Team of Experts will follow up.',
                              style: kContentTextstyle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/images/onboarding3.png',
                                ),
                                height: 200,
                                width: 200,
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Text(
                              'DONATE',
                              style: kBoardingTextStyle,
                            ),
                            SizedBox(height: 50.0),
                            Text(
                              'Help make a Difference.\nMake a Donation.',
                              style: kContentTextstyle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: _buildPageIndicator(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: _currentPage == _numPages - 1 ? 170 : 60,
                          child: RaisedButton(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 8.0),
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            onPressed: () {
                              if (_currentPage == _numPages - 1) {
                                setDone();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage(
                                              userId: widget.userId,
                                              auth: widget.auth,
                                              logoutCallback:
                                                  widget.logoutCallback,
                                            )));
                              } else {
                                _pageController.nextPage(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == _numPages - 1
                                      ? 'GET STARTED'
                                      : "",
                                  style: TextStyle(
                                    color: kSecondaryColor,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_right,
                                  color: kSecondaryColor,
                                  size: 40.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

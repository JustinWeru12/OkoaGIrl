import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/constants/primary_button.dart';
import 'package:okoagirl/services/authentication.dart';
import 'package:okoagirl/services/crud.dart';
import 'package:okoagirl/services/user.dart';
import 'package:flutter/material.dart';

enum FormType { login, register, reset, phone }

class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({Key key, this.title, this.auth, this.loginCallback})
      : super(key: key);

  final String title;
  final BaseAuth auth;
  final VoidCallback loginCallback;

  @override
  _LoginSignUpPageState createState() => _LoginSignUpPageState();
}

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  static final _formKey = new GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  CrudMethods crudObj = new CrudMethods();
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'displayName'],
  );
  String _email;
  String _fullNames;
  DateTime dob;
  File picture;
  bool admin;
  double offset = 0;
  String _authHint = '';
  FormType _formType = FormType.login;
  String _password, phoneNo, verificationId, smsCode;
  bool _isLoading = false, codeSent = false;
  Color dobColor = kSecondaryColor;
  // Check if form is valid before perform login or signup
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void validateAndSubmit() async {
    if (validateAndSave()) {
      setState(() {
        _isLoading = true;
      });
      try {
        String userId;
        if (_formType == FormType.login) {
          userId = await widget.auth.signIn(_email, _password);
        } else if (_formType == FormType.phone) {
          Auth().signInWithOTP(smsCode, verificationId);
        } else {
          userId = await widget.auth.signUp(_email, _password);
        }
        setState(() {
          _isLoading = false;
        });
        if (_formType == FormType.register) {
          UserData userData = new UserData(
            fullNames: _fullNames,
            email: _email,
            phone: "",
            picture:
                "https://firebasestorage.googleapis.com/v0/b/enroute-25815.appspot.com/o/restaurant-red-beans-coffee.jpg?alt=media&token=a75145f8-1351-4335-bc75-432849dac887",
            isDriver: false,
            isSeller: false,
            admin: false,
          );
          crudObj.createOrUpdateUserData(userData.getDataMap());
        }
        //  else if (_formType == FormType.phone) {
        //   UserData userData = new UserData(
        //     fullNames: 'Anonymous',
        //     email: "",
        //     phone: phoneNo,
        //     picture:
        //         "https://firebasestorage.googleapis.com/v0/b/enroute-25815.appspot.com/o/restaurant-red-beans-coffee.jpg?alt=media&token=a75145f8-1351-4335-bc75-432849dac887",
        //     isDriver: false,
        //     isSeller: false,
        //     admin: false,
        //   );
        //   crudObj.createOrUpdateUserData(userData.getDataMap());
        // }

        if (userId == null && _formType == FormType.login) {
          print("EMAIL NOT VERIFIED");
          setState(() {
            _authHint = 'Check your email for a verify link';
            _isLoading = false;
            _formType = FormType.login;
          });
        } else {
          _isLoading = false;
          _authHint = '';
          widget.loginCallback();
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          switch (e.code) {
            case "invalid-email":
              _authHint = "Your email address appears to be malformed.";
              break;
            case "email-already-exists":
              _authHint = "Email address already used in a different account.";
              break;
            case "wrong-password":
              _authHint = "Your password is wrong.";
              break;
            case "user-not-found":
              _authHint = "User with this email doesn't exist.";
              break;
            default:
              _authHint = "An undefined Error happened.";
          }
        });
        print(e.code);
      }
    } else {
      setState(() {
        _authHint = '';
      });
    }
  }

  void moveToRegister() {
    _formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
      _authHint = '';
    });
  }

  void moveToReset() {
    _formKey.currentState.reset();
    setState(() {
      _formType = FormType.reset;
      _authHint = '';
    });
  }

  void moveToLogin() {
    _formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
      _authHint = '';
    });
  }

  // void moveToPhone() {
  //   _formKey.currentState.reset();
  //   setState(() {
  //     _formType = FormType.phone;
  //     _authHint = '';
  //   });
  // }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        key: new Key('email'),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
          filled: true,
          fillColor: kBackgroundColor.withOpacity(0.75),
          labelText: 'Email',
          labelStyle: kSubTextStyle,
          prefixIcon: new Icon(
            Icons.mail,
            color: kSecondaryColor,
          ),
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(42),
            borderSide: new BorderSide(),
          ),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (String value) {
          if (value.isEmpty ||
              !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                  .hasMatch(value)) {
            return 'Enter a valid email';
          }
          return null;
        },
        onSaved: (value) => _email = value.replaceAll(" ", ''),
      ),
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        key: new Key('namefield'),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
          filled: true,
          fillColor: kBackgroundColor.withOpacity(0.75),
          labelText: 'Full Name',
          labelStyle: kSubTextStyle,
          prefixIcon: new Icon(
            Icons.perm_identity,
            color: kSecondaryColor,
          ),
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(42),
            borderSide: new BorderSide(),
          ),
        ),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Enter your Name';
          }
          return null;
        },
        onSaved: (value) => _fullNames = value,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        key: new Key('password'),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
          filled: true,
          fillColor: kBackgroundColor.withOpacity(0.75),
          labelText: 'Password',
          labelStyle: kSubTextStyle,
          prefixIcon: new Icon(
            Icons.lock,
            color: kSecondaryColor,
          ),
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(42),
            borderSide: new BorderSide(),
          ),
        ),
        controller: _passwordTextController,
        obscureText: true,
        validator: (String value) {
          if (value.isEmpty || value.length < 6) {
            return 'Enter a minimum of 6 characters';
          }
          return null;
        },
        onSaved: (value) => _password = value,
      ),
    );
  }

  Widget _builConfirmPasswordTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
          filled: true,
          fillColor: kBackgroundColor.withOpacity(0.75),
          labelText: 'Confirm Password',
          labelStyle: kSubTextStyle,
          prefixIcon: new Icon(
            Icons.lock,
            color: kSecondaryColor,
          ),
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(42),
            borderSide: new BorderSide(),
          ),
        ),
        obscureText: true,
        validator: (String value) {
          if (_passwordTextController.text != value) {
            return 'Passwords don\'t correspond';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 10.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        initialValue: '+254',
        keyboardType: TextInputType.number,
        key: new Key('phone'),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
          labelText: 'Phone',
          hintText: '+254700000000',
          hintStyle: kSubTextStyle,
          labelStyle: kSubTextStyle,
          prefixIcon: new Icon(
            Icons.phone,
            color: kSecondaryColor,
          ),
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(42),
            borderSide: new BorderSide(),
          ),
          filled: true,
          fillColor: kBackgroundColor.withOpacity(0.75),
        ),
        validator: (value) {
          if (value.isEmpty || value.length < 10) {
            return 'Enter a valid Phone Number';
          }
          return null;
        },
        onSaved: (value) {
          phoneNo = value;
        },
      ),
    );
  }

  Widget _buildCodeField() {
    return codeSent
        ? Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 15.0, 10.0, 0.0),
            child: TextFormField(
              maxLines: 1,
              key: new Key('namefield'),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
                labelText: 'Sms Code',
                labelStyle: kSubTextStyle,
                prefixIcon: new Icon(
                  Icons.keyboard,
                  color: kSecondaryColor,
                ),
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(42),
                  borderSide: new BorderSide(),
                ),
                filled: true,
                fillColor: kBackgroundColor.withOpacity(0.75),
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  value = "None";
                }
                return null;
              },
              onSaved: (value) => smsCode = value,
            ),
          )
        : Container();
  }

  Widget submitWidgets() {
    switch (_formType) {
      case FormType.login:
        return ListView(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          children: <Widget>[
            PrimaryButton(
              key: new Key('login'),
              text: 'Login',
              height: 44.0,
              onPressed: validateAndSubmit,
            ),
            SizedBox(height: 10.0),
            FlatButton(
                key: new Key('reset-account'),
                child: Text(
                  "Reset Password",
                ),
                onPressed: moveToReset),
            // SizedBox(height: 10),
            FlatButton(
                key: new Key('need-account'),
                child: Text("Create a New Account"),
                onPressed: moveToRegister),
            SizedBox(height: 20.0),
          ],
        );
      case FormType.reset:
        return ListView(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          children: <Widget>[
            PrimaryButton(
                key: new Key('reset'),
                text: 'Reset Password',
                height: 44.0,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    widget.auth.resetPassword(_email);
                    setState(() {
                      _authHint = 'Reset Link Sent, Check your email';
                      _formType = FormType.login;
                    });
                  }
                }),
            SizedBox(height: 20.0),
            FlatButton(
                key: new Key('need-login'),
                child: Text("Already Have an Account ? Login"),
                onPressed: moveToLogin),
            SizedBox(height: 20.0),
          ],
        );
      case FormType.phone:
        return ListView(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          children: <Widget>[
            codeSent
                ? PrimaryButton(
                    key: new Key('registerphone'),
                    text: 'Sign In',
                    height: 44.0,
                    onPressed: validateAndSubmit)
                : PrimaryButton(
                    key: new Key('registerphone'),
                    text: 'Send Code',
                    height: 44.0,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        verifyPhone(phoneNo);
                        // widget.loginCallback();
                      }
                    }),
            SizedBox(height: 20.0),
            FlatButton(
                key: new Key('need-login'),
                child: Text(
                  "Use Different Account",
                  style: TextStyle(
                      color: kSecondaryColor, fontWeight: FontWeight.w600),
                ),
                onPressed: moveToLogin),
            SizedBox(height: 20.0),
          ],
        );
      default:
        return ListView(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          children: <Widget>[
            PrimaryButton(
              key: new Key('register'),
              text: 'Sign Up',
              height: 44.0,
              onPressed: validateAndSubmit,
            ),
            SizedBox(height: 20.0),
            FlatButton(
                key: new Key('need-login'),
                child: Text("Already Have an Account ? Login"),
                onPressed: moveToLogin),
            SizedBox(height: 20.0),
          ],
        );
    }
  }

  Widget _showCircularProgress() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _showLogo(Size size) {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Container(
          height: size.width * 0.4,
          width: size.width * 0.4,
          // decoration: BoxDecoration(
          //   color: Colors.white.withOpacity(0.1),
          //   borderRadius: BorderRadius.circular(50)
          // ),
          child: Hero(
            tag: 'hero',
            child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
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

  Widget hintText() {
    return Container(
        //height: 80.0,
        padding: const EdgeInsets.all(10.0),
        child: Text(_authHint,
            key: new Key('hint'),
            style: kAlertTextStyle,
            textAlign: TextAlign.center));
  }

  // Container _buildGoogleLoginButton() {
  //   return Container(
  //     width: 120.0,
  //     height: 48.0,
  //     margin: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),
  //     child: ButtonTheme(
  //         height: 48,
  //         child: SignInButton(
  //           Buttons.Google,
  //           text: "Google",
  //           onPressed: () {
  //             _handleSignIn();
  //           },
  //         )),
  //   );
  // }

  // Future<void> _handleSignIn() async {
  //   try {
  //     await googleSignIn.signIn().then((value) {
  //       if (value != null) {
  //         UserData userData = new UserData(
  //           fullNames: value.displayName,
  //           email: value.email,
  //           phone: "",
  //           picture: value.photoUrl,
  //           isDriver: false,
  //           isSeller: false,
  //           admin: false,
  //         );
  //         crudObj.createOrUpdateUserData(userData.getDataMap());
  //         Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) => HomePage(userId: value.id)));
  //       }
  //     });
  //   } catch (error) {
  //     print(error);
  //   }
  // }

  // Container _buildPhoneLoginButton() {
  //   return Container(
  //     width: 120.0,
  //     height: 48.0,
  //     margin: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),
  //     child: ButtonTheme(
  //         height: 48,
  //         child: RaisedButton(
  //             child: Row(children: <Widget>[
  //               Icon(Icons.phone),
  //               Text("\tPhone"),
  //             ]),
  //             onPressed: moveToPhone)),
  //   );
  // }

  Widget _buildForm() {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            hintText(),
            _formType == FormType.register
                ? _buildNameField()
                : Container(height: 0.0),
            SizedBox(
              height: 10.0,
            ),
            _formType != FormType.phone ? _buildEmailField() : Container(),
            SizedBox(
              height: 10.0,
            ),
            _formType != FormType.reset && _formType != FormType.phone
                ? _buildPasswordField()
                : Container(),
            SizedBox(
              height: 10.0,
            ),
            _formType == FormType.register && _formType != FormType.phone
                ? _builConfirmPasswordTextField()
                : Container(),
            SizedBox(
              height: 10.0,
            ),
            _formType == FormType.phone ? _buildPhoneField() : Container(),
            _formType == FormType.phone
                ? SizedBox(
                    height: 10.0,
                  )
                : Container(),
            _formType == FormType.phone ? _buildCodeField() : Container(),
            _formType == FormType.phone
                ? SizedBox(
                    height: 10.0,
                  )
                : Container(),
            _isLoading == false
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                    child: submitWidgets(),
                  )
                : _showCircularProgress(),
            // _formType == FormType.login
            //     ? Center(
            //         child: new Text(
            //           'Sign in with',
            //           textAlign: TextAlign.center,
            //           style: TextStyle(
            //               fontSize: 18.0,
            //               fontWeight: FontWeight.bold,
            //               color: kBackgroundColor),
            //         ),
            //       )
            //     : Container(),
            // SizedBox(
            //   height: 10,
            // ),
            // _formType == FormType.login
            //     ? Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceAround,
            //         children: <Widget>[
            //           // _buildGoogleLoginButton(),
            //           // _buildFacebookLoginButton(),
            //           _buildPhoneLoginButton(),
            //         ],
            //       )
            //     : Container(),
            SizedBox(
              height: 20.0,
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kPrimaryColor,
                    kSecondaryColor,
                  ],
                ),
              ),
              child: Column(
                children: [
                  _showLogo(size),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text("Welcome to Okoa Girl Child",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: size.width * 0.8,
                    child: Text(
                      "The next generation of Female Empowerment and Gender Equality.\n Bringing you the best way to do something for the Girl.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                width: size.width,
                // height: size.height * 0.5,
                decoration: BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(42))),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildForm(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> verifyPhone(phoneNo) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      FirebaseAuth.instance.signInWithCredential(authResult);
    };

    final PhoneVerificationFailed verificationfailed =
        (FirebaseAuthException authException) {
      setState(() {
        _authHint = authException.message;
      });
      print('${authException.message}');
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      setState(() {
        this.codeSent = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
      setState(() {
        verificationId = verId;
      });
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verified,
        verificationFailed: verificationfailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }
}

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/constants/primary_button.dart';
import 'package:okoagirl/services/authentication.dart';
import 'package:okoagirl/services/crud.dart';
import 'package:okoagirl/services/profileData.dart';
import 'package:okoagirl/services/user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum FormType { login, register, reset, pro1, pro }

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
  String _password, phoneNo = "", verificationId, smsCode;
  bool _isLoading = false, codeSent = false;
  Color dobColor = kSecondaryColor;
  String _licensceNo, _location, _phone = "", _idNo, _bio, _insurance;
  List<File> bisPictureFile = new List<File>(3);
  List photoDescription = ["PassPort Photo", "ID/License", "Other"];
  bool isLaw = true, isHealth = false;
  final picker = ImagePicker();
  // Check if form is valid before perform login or signup
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  bool validateAndConfirm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndRegisterLaw() async {
    List pics = [];
    if (validateAndSave()) {
      setState(() {
        _isLoading = true;
      });
      User user = FirebaseAuth.instance.currentUser;
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('lawyers').doc(user.uid);
      uploadLawPictures(docRef.id).then((val) {
        ProfileData bisData = new ProfileData(
          name: _fullNames,
          bio: _bio,
          idNo: _idNo,
          phone: _phone,
          email: _email,
          licenseNo: _licensceNo,
          insurance: _insurance,
          location: _location,
          pictures: val,
        );
        setState(() {
          pics = val;
          crudObj.updateLawPictures(val, user.uid);
          crudObj.createOrUpdateUserData({'isLegal': true});
        });
        docRef
            .set(bisData.getProfileDataMap(), SetOptions(merge: true))
            .whenComplete(() => {
                  crudObj.createOrUpdateUserData({'isLegal': true}),
                  widget.loginCallback()
                });
      });
    }
  }

  void validateAndRegisterHealth() async {
    var pics = [];
    if (validateAndConfirm()) {
      setState(() {
        _isLoading = true;
      });
      User user = FirebaseAuth.instance.currentUser;
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('health').doc(user.uid);
      uploadHealthPictures(docRef.id).then((val) {
        ProfileData bisData = new ProfileData(
          name: _fullNames,
          bio: _bio,
          idNo: _idNo,
          phone: _phone,
          email: _email,
          licenseNo: _licensceNo,
          insurance: _insurance,
          location: _location,
          pictures: val,
        );
        setState(() {
          debugPrint(val.toString());
          crudObj.updateHealthPictures(val, user.uid);
          pics = val;
          crudObj.createOrUpdateUserData({'isHealth': true});
        });
        docRef
            .set(bisData.getProfileDataMap(), SetOptions(merge: true))
            .whenComplete(() => {
                  crudObj.createOrUpdateUserData({'isHealth': true}),
                  widget.loginCallback()
                });
      });
    }
  }

  Future getImageFromGallery(picNumber) async {
    var pickedImage = await picker.getImage(source: ImageSource.gallery);
    var tempImage = File(pickedImage.path);
    if (picNumber == 0) {
      setState(() {
        bisPictureFile[0] = tempImage;
      });
    }
    if (picNumber == 1) {
      setState(() {
        bisPictureFile[1] = tempImage;
      });
    }
    if (picNumber == 2) {
      setState(() {
        bisPictureFile[2] = tempImage;
      });
    }
  }

  Future<List<String>> uploadLawPictures(bisID) async {
    List<String> urlList = [];
    for (int i = 0; i < bisPictureFile.length; i++) {
      if (bisPictureFile[i] != null) {
        final StorageReference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('lawPics/$bisID/$i.jpg');
        final StorageUploadTask task =
            firebaseStorageRef.putFile(bisPictureFile[i]);
        var downloadUrl = await (await task.onComplete).ref.getDownloadURL();
        var url = downloadUrl.toString();
        urlList.add(url);
        print(urlList);
      }
    }
    setState(() {
      _isLoading = false;
    });
    return urlList;
  }

  Future<List<String>> uploadHealthPictures(bisID) async {
    List<String> urlList = [];
    for (int i = 0; i < bisPictureFile.length; i++) {
      if (bisPictureFile[i] != null) {
        final StorageReference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('healthPics/$bisID/$i.jpg');
        final StorageUploadTask task =
            firebaseStorageRef.putFile(bisPictureFile[i]);
        var downloadUrl = await (await task.onComplete).ref.getDownloadURL();
        var url = downloadUrl.toString();
        urlList.add(url);
      }
    }
    // updateHealthPictures(urlList, bisID);
    setState(() {
      _isLoading = false;
    });
    return urlList;
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
            phone: _phone,
            picture:
                "https://firebasestorage.googleapis.com/v0/b/nightlyfe-9fe92.appspot.com/o/private%2Fhome.png?alt=media&token=900267d4-25d9-4144-b7de-53b3f559804d",
            isHealth: false,
            isLegal: false,
            admin: false,
          );
          crudObj.createOrUpdateUserData(userData.getDataMap());
        } else if (_formType == FormType.pro) {
          UserData userData = new UserData(
            fullNames: _fullNames,
            email: _email,
            phone: _phone,
            picture:
                "https://firebasestorage.googleapis.com/v0/b/nightlyfe-9fe92.appspot.com/o/private%2Fhome.png?alt=media&token=900267d4-25d9-4144-b7de-53b3f559804d",
            isHealth: isHealth,
            isLegal: isLaw,
            admin: false,
          );
          crudObj.createOrUpdateUserData(userData.getDataMap());
          if (isLaw) {
            validateAndRegisterLaw();
          } else {
            validateAndRegisterHealth();
          }
        }

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
          if (_formType != FormType.pro) {
            widget.loginCallback();
          }
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

  void moveToPro() {
    _formKey.currentState.reset();
    setState(() {
      _formType = FormType.pro;
      _authHint = '';
    });
  }

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

  Widget _toggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Lawyer Profile", style: kSubTextStyle),
          Switch(
            value: isLaw,
            onChanged: (val) {
              setState(() {
                isLaw = !isLaw;
                if (isHealth) {
                  isHealth = false;
                }
              });
            },
          ),
          Spacer(),
          Text("Health Profile", style: kSubTextStyle),
          Switch(
            value: isHealth,
            onChanged: (val) {
              setState(() {
                isHealth = !isHealth;
                if (isLaw) {
                  isLaw = false;
                }
              });
            },
          )
        ],
      ),
    );
  }

  Widget _bisBio() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        key: new Key('description'),
        style: kSubTextStyle,
        decoration: InputDecoration(
          labelText: 'Biography',
          contentPadding: EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
          filled: true,
          fillColor: kBackgroundColor.withOpacity(0.75),
          labelStyle: kSubTextStyle,
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(42),
            borderSide: new BorderSide(),
          ),
          prefixIcon: new Icon(
            FontAwesomeIcons.solidClipboard,
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
        ),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Add a little catchy description';
          }
          return null;
        },
        onSaved: (value) => _bio = value,
      ),
    );
  }

  Widget _bisId() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        key: new Key('id'),
        style: kSubTextStyle,
        decoration: InputDecoration(
          labelText: 'ID Number',
          contentPadding: EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
          filled: true,
          fillColor: kBackgroundColor.withOpacity(0.75),
          labelStyle: kSubTextStyle,
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(42),
            borderSide: new BorderSide(),
          ),
          prefixIcon: new Icon(
            FontAwesomeIcons.compass,
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
        ),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Enter Id No';
          } else if (value.length < 8) {
            return 'Enter a Valid Id No';
          }
          return null;
        },
        onSaved: (value) => _idNo = value,
      ),
    );
  }

  Widget _bisPhone() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        key: new Key('bisPhone'),
        style: kSubTextStyle,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Mobile',
          contentPadding: EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
          filled: true,
          fillColor: kBackgroundColor.withOpacity(0.75),
          labelStyle: kSubTextStyle,
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(42),
            borderSide: new BorderSide(),
          ),
          prefixIcon: new Icon(
            FontAwesomeIcons.phone,
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
        ),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Enter a Phone Number';
          }
          return null;
        },
        onSaved: (value) => _phone = value,
      ),
    );
  }

  Widget _bisLicense() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            key: new Key('license'),
            keyboardType: TextInputType.text,
            style: kSubTextStyle,
            decoration: InputDecoration(
              labelText: 'License No.',
              contentPadding: EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
              filled: true,
              fillColor: kBackgroundColor.withOpacity(0.75),
              labelStyle: kSubTextStyle,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(42),
                borderSide: new BorderSide(),
              ),
              prefixIcon: new Icon(
                FontAwesomeIcons.dollarSign,
                size: 24,
                color: Theme.of(context).primaryColor,
              ),
            ),
            validator: (String value) {
              if (value.isEmpty) {
                return 'Enter a valid License';
              }
              return null;
            },
            onSaved: (value) => _licensceNo = value,
          ),
        ],
      ),
    );
  }

  Widget _bisInsurance() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        key: new Key('bisinsurance'),
        style: kSubTextStyle,
        decoration: InputDecoration(
          labelText: 'Insurance',
          contentPadding: EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
          filled: true,
          fillColor: kBackgroundColor.withOpacity(0.75),
          labelStyle: kSubTextStyle,
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(42),
            borderSide: new BorderSide(),
          ),
          prefixIcon: new Icon(
            FontAwesomeIcons.link,
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
        ),
        onSaved: (value) => _insurance = value,
      ),
    );
  }

  Widget _selectionPictures() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 50.0, 10.0, 0.0),
      child: Container(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: bisPictureFile.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              key: Key('pic$index'),
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.grey[300]),
                  margin: EdgeInsets.only(right: 10),
                  width: 250,
                  height: 200,
                  child: bisPictureFile[index] == null
                      ? TextButton(
                          onPressed: () {
                            getImageFromGallery(index);
                          },
                          child: Icon(Icons.add_circle_outline),
                        )
                      : InkWell(
                          onTap: () {
                            getImageFromGallery(index);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.file(
                              bisPictureFile[index],
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ),
                Text(
                  photoDescription[index],
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showDialogMissingPhoto() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(top: 8.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Photo missing",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Legal document photos are required!",
                  textAlign: TextAlign.justify,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: new Text(
                      "Ok",
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
            TextButton(
                key: new Key('reset-account'),
                child: Text(
                  "Reset Password",
                ),
                onPressed: moveToReset),
            // SizedBox(height: 10),
            TextButton(
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
            TextButton(
                key: new Key('need-login'),
                child: Text("Already Have an Account ? Login"),
                onPressed: moveToLogin),
            SizedBox(height: 20.0),
          ],
        );
      case FormType.pro:
        return ListView(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          children: <Widget>[
            PrimaryButton(
                key: new Key('registerphone'),
                text: 'Register',
                height: 44.0,
                onPressed: () {
                  if (bisPictureFile[0] == null) {
                    validateAndSave();
                    _showDialogMissingPhoto();
                  } else {
                    validateAndSubmit();
                  }
                }),
            SizedBox(height: 20.0),
            TextButton(
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
            SizedBox(height: 10.0),
            TextButton(
                key: new Key('need-login'),
                child: Text("Already Have an Account ? Login"),
                onPressed: moveToLogin),
            SizedBox(height: 10.0),
            TextButton(
                key: new Key('need-pro'),
                child: Text("Pro account"),
                onPressed: moveToPro),
            SizedBox(height: 10.0),
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

  Widget _buildForm() {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            hintText(),
            _formType == FormType.register || _formType == FormType.pro
                ? _buildNameField()
                : Container(height: 0.0),
            SizedBox(
              height: 5.0,
            ),
            _buildEmailField(),
            SizedBox(
              height: 5.0,
            ),
            _formType == FormType.pro ? _bisBio() : Container(),
            _formType == FormType.pro ? _toggle() : Container(),
            _formType == FormType.pro ? _bisId() : Container(),
            _formType == FormType.register || _formType == FormType.pro
                ? _bisPhone()
                : Container(),
            _formType != FormType.reset ? _buildPasswordField() : Container(),
            SizedBox(
              height: 5.0,
            ),
            _formType == FormType.register || _formType == FormType.pro
                ? _builConfirmPasswordTextField()
                : Container(),
            _formType == FormType.pro ? _bisLicense() : Container(),
            _formType == FormType.pro ? _bisInsurance() : Container(),
            _formType == FormType.pro ? _selectionPictures() : Container(),
            SizedBox(
              height: 10.0,
            ),
            _isLoading == false
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                    child: submitWidgets(),
                  )
                : _showCircularProgress(),
            SizedBox(
              height: 10.0,
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

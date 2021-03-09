import 'dart:io';
import 'dart:async';
import 'package:okoagirl/constants/constants.dart';
import 'package:okoagirl/constants/primary_button.dart';
import 'package:okoagirl/services/authentication.dart';
import 'package:okoagirl/services/crud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:okoagirl/services/profileData.dart';

class AddProfile extends StatefulWidget {
  AddProfile({this.onSignOut});

  final VoidCallback onSignOut;

  final BaseAuth auth = new Auth();

  @override
  State<StatefulWidget> createState() {
    return _AddProfileState();
  }
}

class _AddProfileState extends State<AddProfile> {
  String userMail = 'userMail';
  String userId = 'userId';
  static final formKey = new GlobalKey<FormState>();
  static final _formKey = new GlobalKey<FormState>();
  CrudMethods crudObj = new CrudMethods();
  Location location = new Location();
  Geoflutterfire geo = Geoflutterfire();
  StreamSubscription<LocationData> locationsubs;
  PermissionStatus _permissionGranted;
  LocationData currentLocation;
  bool _isLoading = false;
  String _name, _licensceNo, _location, _phone, _idNo, _bio, _insurance;
  List<File> bisPictureFile = new List<File>(3);
  List photoDescription = ["PassPort Photo", "ID/License", "Other"];
  var pointdata;
  final picker = ImagePicker();
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _requestPermission();
    location = new Location();
    locationsubs = location.onLocationChanged.listen((LocationData cLoc) {
      setState(() {
        currentLocation = cLoc;
      });
    });
    widget.auth.currentUser().then((id) {
      setState(() {
        userId = id;
      });
    });
    widget.auth.userEmail().then((mail) {
      setState(() {
        userMail = mail;
      });
    });
  }

  @override
  void dispose() {
    locationsubs.cancel();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    final PermissionStatus permissionGrantedResult =
        await location.hasPermission();
    setState(() {
      _permissionGranted = permissionGrantedResult;
    });
  }

  Future<void> _requestPermission() async {
    if (_permissionGranted != PermissionStatus.granted) {
      final PermissionStatus permissionRequestedResult =
          await location.requestPermission();
      setState(() {
        _permissionGranted = permissionRequestedResult;
      });
      if (permissionRequestedResult != PermissionStatus.granted) {
        return;
      }
    }
  }

  addToList() async {
    GeoFirePoint point = geo.point(
      latitude: currentLocation.latitude,
      longitude: currentLocation.longitude,
    );
    print(point.data);
    return point.data;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      setState(() {
        _isLoading = true;
      });
      addToList().then((value) async {
        ProfileData bisData = new ProfileData(
          name: _name,
          bio: _bio,
          idNo: _idNo,
          phone: _phone,
          email: userMail,
          licenseNo: _licensceNo,
          insurance: _insurance,
          location: _location,
          pictures: [],
        );
        User user = FirebaseAuth.instance.currentUser;
        DocumentReference docRef =
            FirebaseFirestore.instance.collection('lawyers').doc(user.uid);
        uploadLawPictures(docRef.id);
        return docRef
            .set(bisData.getProfileDataMap(), SetOptions(merge: true))
            .whenComplete(
                () => crudObj.createOrUpdateUserData({'isLegal': true}));
      });

//      setState(() {
//        _isLoading = false;
//      });

    } else {
//      setState(() {
//        _authHint = '';
//      });
    }
  }

  void validateAndRegister() async {
    if (validateAndConfirm()) {
      setState(() {
        _isLoading = true;
      });
      addToList().then((value) async {
        ProfileData bisData = new ProfileData(
          name: _name,
          bio: _bio,
          idNo: _idNo,
          phone: _phone,
          email: userMail,
          licenseNo: _licensceNo,
          insurance: _insurance,
          location: _location,
          pictures: [],
        );
        User user = FirebaseAuth.instance.currentUser;
        DocumentReference docRef =
            FirebaseFirestore.instance.collection('health').doc(user.uid);
        uploadHealthPictures(docRef.id);
        return docRef
            .set(bisData.getProfileDataMap(), SetOptions(merge: true))
            .whenComplete(
                () => crudObj.createOrUpdateUserData({'isHealth': true}));
      });

//      setState(() {
//        _isLoading = false;
//      });

    } else {
//      setState(() {
//        _authHint = '';
//      });
    }
  }

  Widget submitLawWidget() {
    return PrimaryButton(
        key: new Key('submitLawyer'),
        text: 'Create Profile',
        height: 44.0,
        onPressed: () {
          if (bisPictureFile[0] == null) {
            validateAndSave();
            _showDialogMissingPhoto();
          } else {
            validateAndSubmit();
          }
        });
  }

  Widget submitHealthWidget() {
    return PrimaryButton(
        key: new Key('submitHealth'),
        text: 'Create Profile',
        height: 44.0,
        onPressed: () {
          if (bisPictureFile[0] == null) {
            validateAndConfirm();
            _showDialogMissingPhoto();
          } else {
            validateAndRegister();
          }
        });
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
                  "Legal business document photos are required!",
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

  Widget _bisNameField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 20.0, 10.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        key: new Key('name'),
        style: kFormTextstyle,
        decoration: InputDecoration(
          labelText: 'Full Name',
          labelStyle: kFormTextstyle,
          icon: new Icon(
            FontAwesomeIcons.home,
            size: 24,
            color: Theme.of(context).primaryColor,
          ),
        ),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Enter a Name';
          } else if (!value.contains(" ")) {
            return 'Enter Full Name';
          }
          return null;
        },
        onSaved: (value) => _name = value.capitalizeFirst(),
      ),
    );
  }

  Widget _bisBio() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 30.0, 10.0, 15.0),
      child: TextFormField(
        maxLength: 200,
        key: new Key('description'),
        style: kFormTextstyle,
        decoration: InputDecoration(
          labelText: 'Biography',
          labelStyle: kFormTextstyle,
          icon: new Icon(
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
      padding: const EdgeInsets.fromLTRB(5.0, 30.0, 10.0, 0.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        key: new Key('id'),
        style: kFormTextstyle,
        decoration: InputDecoration(
          labelText: 'ID Number',
          labelStyle: kFormTextstyle,
          icon: new Icon(
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
      padding: const EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 0.0),
      child: TextFormField(
        key: new Key('bisPhone'),
        style: kFormTextstyle,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Mobile',
          labelStyle: kFormTextstyle,
          icon: new Icon(
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
      padding: const EdgeInsets.fromLTRB(5.0, 20.0, 10.0, 25.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            key: new Key('license'),
            keyboardType: TextInputType.text,
            style: kFormTextstyle,
            decoration: InputDecoration(
              labelText: 'License No.',
              labelStyle: kFormTextstyle,
              icon: new Icon(
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
      padding: const EdgeInsets.fromLTRB(5.0, 20.0, 10.0, 25.0),
      child: TextFormField(
        key: new Key('bisinsurance'),
        style: kFormTextstyle,
        decoration: InputDecoration(
          labelText: 'Insurance',
          labelStyle: kFormTextstyle,
          icon: new Icon(
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

  Widget notifyLocationCollection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
      child: Center(
        child: Text(
          "Your current location will be recorded as the Geo-Location of the Business you add. Please be within 10mtrs of the place you want to add",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: kBackgroundColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
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

  uploadLawPictures(bisID) async {
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
      }
    }
    setState(() {
      _isLoading = false;
    });
    updatePictures(urlList, bisID);
  }

  updatePictures(picUrlList, bisID) {
    FirebaseFirestore.instance
        .collection('lawyers')
        .doc(bisID)
        .update({"pictures": picUrlList});
    Navigator.pushReplacementNamed(context, "/");
  }

  uploadHealthPictures(bisID) async {
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
    setState(() {
      _isLoading = false;
    });
    updateHealthPictures(urlList, bisID);
  }

  updateHealthPictures(picUrlList, bisID) {
    FirebaseFirestore.instance
        .collection('health')
        .doc(bisID)
        .update({"pictures": picUrlList});
    Navigator.pushReplacementNamed(context, "/");
  }

  Widget _bisPictures() {
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
                            getBisImageFromGallery(index);
                          },
                          child: Icon(Icons.add_circle_outline),
                        )
                      : InkWell(
                          onTap: () {
                            getBisImageFromGallery(index);
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

  Future getBisImageFromGallery(picNumber) async {
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

  uploadBisPictures(bisID) async {
    List<String> urlList = [];
    for (int i = 0; i < bisPictureFile.length; i++) {
      if (bisPictureFile[i] != null) {
        final StorageReference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('BusinessPics/$_name/$i.jpg');
        final StorageUploadTask task =
            firebaseStorageRef.putFile(bisPictureFile[i]);
        var downloadUrl = await (await task.onComplete).ref.getDownloadURL();
        var url = downloadUrl.toString();
        urlList.add(url);
      }
    }
    setState(() {
      _isLoading = false;
    });
    updateBisPictures(urlList, bisID);
  }

  updateBisPictures(picUrlList, bisID) {
    FirebaseFirestore.instance
        .collection('Businessbisile')
        .doc(bisID)
        .update({"pictures": picUrlList});
    Navigator.pushReplacementNamed(context, "/");
  }

  bool validateAndSave() {
    final form = formKey.currentState;
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

  Widget _showCircularProgress() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget buildForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  kPrimaryColor,
                  kSecondaryColor,
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(2.0, 5.0),
                  blurRadius: 7.0,
                )
              ],
            ),
            child: Column(
              children: <Widget>[
                _bisNameField(),
                _bisBio(),
              ],
            ),
          ),
          Container(
            height: 30,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  kPrimaryColor,
                  kSecondaryColor,
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(2.0, 5.0),
                  blurRadius: 10.0,
                )
              ],
            ),
            child: Column(
              children: <Widget>[
                // _notifyLocationCollection(),
                _bisPhone(),
                _bisId(),
                _bisInsurance(),
                // _bisPosition(),
              ],
            ),
          ),
          Container(
            height: 30,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  kPrimaryColor,
                  kSecondaryColor,
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(2.0, 5.0),
                  blurRadius: 10.0,
                )
              ],
            ),
            child: Column(
              children: <Widget>[
                _bisLicense(),
              ],
            ),
          ),
          _selectionPictures(),
          Container(
            height: 30,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(2.0, 5.0),
                  blurRadius: 10.0,
                )
              ],
            ),
            child: Column(
              children: <Widget>[
                // _checkboxMusicStyle(),
              ],
            ),
          ),
          _isLoading == false ? submitLawWidget() : _showCircularProgress(),
        ],
      ),
    );
  }

  Widget buildBusinessForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  kPrimaryColor,
                  kSecondaryColor,
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(2.0, 5.0),
                  blurRadius: 7.0,
                )
              ],
            ),
            child: Column(
              children: <Widget>[
                _bisNameField(),
                _bisBio(),
              ],
            ),
          ),
          Container(
            height: 30,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  kPrimaryColor,
                  kSecondaryColor,
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(2.0, 5.0),
                  blurRadius: 10.0,
                )
              ],
            ),
            child: Column(
              children: <Widget>[
                // _notifyLocationCollection(),
                _bisPhone(),
                _bisInsurance(),
                // _bisPosition(),
              ],
            ),
          ),
          Container(
            height: 30,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  kPrimaryColor,
                  kSecondaryColor,
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(2.0, 5.0),
                  blurRadius: 10.0,
                )
              ],
            ),
            child: Column(
              children: <Widget>[
                _bisLicense(),
              ],
            ),
          ),
          _bisPictures(),
          Container(
            height: 30,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(2.0, 5.0),
                  blurRadius: 10.0,
                )
              ],
            ),
            child: Column(
              children: <Widget>[
                // _checkboxMusicStyle(),
              ],
            ),
          ),
          _isLoading == false ? submitHealthWidget() : _showCircularProgress(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          title: Text(
            'Create',
            style: kAppBarstyle,
          ),
          bottomOpacity: 1,
          bottom: TabBar(
            isScrollable: true,
            unselectedLabelColor: Colors.white,
            labelColor: Colors.green,
            labelStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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
                color: Colors.white),
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
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: <Widget>[
                  Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Container(
                      child: buildForm(),
                    ),
                  ]),
                ]),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: <Widget>[
                  Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Container(
                      child: buildBusinessForm(),
                    ),
                  ]),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

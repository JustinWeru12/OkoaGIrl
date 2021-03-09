import 'package:okoagirl/services/crud.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class SelectProfilPicture extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SelectProfilPictureState();
  }
}

class _SelectProfilPictureState extends State<SelectProfilPicture> {
  bool _isLoading = false;
  File newProfilPic;
  CrudMethods crudObj = new CrudMethods();
  final picker = ImagePicker();

  updateProfilPicture(picUrl) {
    Map<String, dynamic> userMap = {'picture': picUrl};
    crudObj.createOrUpdateUserData(userMap);
  }

  Future getImageFromGallery() async {
    var tempImage = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      newProfilPic = File(tempImage.path);
    });
  }

  Future getImageFromCamera() async {
    var tempImage = await picker.getImage(source: ImageSource.camera);
    setState(() {
      newProfilPic = File(tempImage.path);
    });
  }

  uploadImage() async {
    User user = FirebaseAuth.instance.currentUser;
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('profilePics/${user.uid}.jpg');
    final StorageUploadTask task = firebaseStorageRef.putFile(newProfilPic);
    if (task.isInProgress) {
      setState(() {
        _isLoading = true;
      });
    }
    var downloadUrl = await (await task.onComplete).ref.getDownloadURL();
    var url = downloadUrl.toString();
    updateProfilPicture(url);
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
  }

  Widget enableUpload() {
    return Container(
      child: Column(
        children: <Widget>[
          Image.file(
            newProfilPic,
            height: 200,
            width: 200,
          ),
          _isLoading == false
              ? Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 5.0,
                      primary: Color(0xFFe0fcdf),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                    ),
                    child: Icon(
                      Icons.done,
                      color: Color(0xFF0fbc00),
                    ),
                    onPressed: uploadImage,
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(top: 18.0),
                  child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: newProfilPic == null
                      ? Text('Select picture')
                      : enableUpload(),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 5.0,
                  primary: Color(0xFFe0fcdf),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                ),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.folder,
                      color: Color(0xFF004d7a),
                    ),
                    Text('Gallery')
                  ],
                ),
                onPressed: getImageFromGallery,
              ),
              SizedBox(
                width: 25,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 5.0,
                  primary: Color(0xFFe0fcdf),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                ),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.camera_alt,
                      color: Color(0xFF008793),
                    ),
                    Text('Camera')
                  ],
                ),
                onPressed: getImageFromCamera,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

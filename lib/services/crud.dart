import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrudMethods {
  bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  getAdmin() async {
    User user = FirebaseAuth.instance.currentUser;
    var userDocument =
        await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
    bool _myAdmin = userDocument["admin"];
    print(_myAdmin);
  }

  getProfile() async {
    return FirebaseFirestore.instance.collection('profile').snapshots();
  }

  getDataFromUserFromDocument() async {
    User user = FirebaseAuth.instance.currentUser;
    return await FirebaseFirestore.instance
        .collection('user')
        .doc(user.uid)
        .get();
  }

  getDataFromUserFromDocumentWithID(userID) async {
    return await FirebaseFirestore.instance
        .collection('user')
        .doc(userID)
        .get();
  }

  getDataFromUser() async {
    User user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('user')
        .doc(user.uid)
        .snapshots();
  }

  createOrUpdateUserData(Map<String, dynamic> userDataMap) async {
    User user = FirebaseAuth.instance.currentUser;
//    print('USERID ' + user.uid);
    DocumentReference ref =
        FirebaseFirestore.instance.collection('user').doc(user.uid);
    return ref.set(userDataMap, SetOptions(merge: true));
  }

  createOrUpdateAdminData(Map<String, dynamic> userDataMap) async {
    DocumentReference ref = FirebaseFirestore.instance.collection('user').doc();
    return ref.set(userDataMap, SetOptions(merge: true));
  }

  Future<void> createCase(Map<String, dynamic> dataMap) async {
    FirebaseFirestore.instance.collection('cases').add(dataMap).catchError((e) {
      print(e);
    });
  }

  Future<void> createBudget(Map<String, dynamic> dataMap) async {
    FirebaseFirestore.instance
        .collection('budget')
        .add(dataMap)
        .catchError((e) {
      print(e);
    });
  }

  Future<void> createDonation(Map<String, dynamic> dataMap) async {
    FirebaseFirestore.instance
        .collection('donation')
        .add(dataMap)
        .catchError((e) {
      print(e);
    });
  }

  getBudget() async {
    return FirebaseFirestore.instance
        .collection('finances')
        .doc('budget')
        .get();
  }

  Future<void> updateDueList(data) async {
    DocumentReference ref =
        FirebaseFirestore.instance.collection("finances").doc("budget");
    return ref.set({"budget": data}, SetOptions(merge: true));
  }

  Future<void> updatePaidList(data) async {
    DocumentReference ref =
        FirebaseFirestore.instance.collection("finances").doc("budget");
    return ref.set({"donations": data}, SetOptions(merge: true));
  }

    createOrUpdateCardData(Map<String, dynamic> userDataMap) async {
    User user = FirebaseAuth.instance.currentUser;
//    print('USERID ' + user.uid);
    DocumentReference ref = FirebaseFirestore.instance
        .collection('user')
        .doc(user.uid)
        .collection("cards")
        .doc();
    return ref.set(userDataMap, SetOptions(merge: true));
  }

  getDeveloperData() async {
    return await FirebaseFirestore.instance
        .collection('res')
        .doc('developerdetails')
        .get();
  }
}

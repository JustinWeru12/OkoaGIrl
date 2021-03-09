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

  Future<void> createBudget(Map<String, dynamic> dataMap, id) async {
    DocumentReference ref =
        FirebaseFirestore.instance.collection('budget').doc(id);
    return ref.set(dataMap, SetOptions(merge: true));
  }

  deleteBudget(docID) {
    return FirebaseFirestore.instance.collection('budget').doc(docID).delete();
  }

  createOrUpdateProData(id, collname, Map<String, dynamic> userDataMap) async {
    DocumentReference ref =
        FirebaseFirestore.instance.collection(collname).doc(id);
    return ref.set(userDataMap, SetOptions(merge: true));
  }

  updateCaseData(id, Map<String, dynamic> userDataMap) async {
    DocumentReference ref =
        FirebaseFirestore.instance.collection('cases').doc(id);
    return ref.set(userDataMap, SetOptions(merge: true));
  }

  Future<void> createDonation(Map<String, dynamic> dataMap, id) async {
    DocumentReference ref =
        FirebaseFirestore.instance.collection('donation').doc(id);
    return ref.set(dataMap, SetOptions(merge: true));
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

  updateLawPictures(List<String> picUrlList, bisID) {
    DocumentReference ref =
        FirebaseFirestore.instance.collection('lawyers').doc(bisID);
    return ref.set({"pictures": picUrlList}, SetOptions(merge: true));
  }

  updateHealthPictures(List<String> picUrlList, bisID) {
    DocumentReference ref =
        FirebaseFirestore.instance.collection('health').doc(bisID);
    return ref.set({"pictures": picUrlList}, SetOptions(merge: true));
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

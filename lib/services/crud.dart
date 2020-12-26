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

  Future<void> createService(Map<String, dynamic> dataMap) async {
    FirebaseFirestore.instance
        .collection('categories')
        .add(dataMap)
        .catchError((e) {
      print(e);
    });
  }

  Future<void> createBusinessService(Map<String, dynamic> dataMap) async {
    FirebaseFirestore.instance
        .collection('services')
        .add(dataMap)
        .catchError((e) {
      print(e);
    });
  }

  Future<void> createBusinessSubService(
      Map<String, dynamic> dataMap, String docID) async {
    FirebaseFirestore.instance
        .collection("BusinessProfile")
        .doc(docID)
        .collection('subcategories')
        .add(dataMap)
        .catchError((e) {
      print(e);
    });
  }

  Future<void> createSubCategoryList(List<String> data, String docID) async {
    DocumentReference ref = FirebaseFirestore.instance
        .collection('BusinessProfile')
        .doc(docID);
    return ref
        .set({"SubCategories": FieldValue.arrayUnion(data)}, SetOptions(merge: true));
  }

  Future<void> createBanner(Map<String, dynamic> dataMap) async {
    FirebaseFirestore.instance
        .collection('popular')
        .add(dataMap)
        .catchError((e) {
      print(e);
    });
  }

  Future<void> createOrderItem(
      String collectionName, Map<String, dynamic> dataMap) async {
    FirebaseFirestore.instance
        .collection(collectionName)
        .add(dataMap)
        .catchError((e) {
      print(e);
    });
  }

  Future<void> createCategoryList(List<String> data) async {
    DocumentReference ref = FirebaseFirestore.instance
        .collection('categoriesList')
        .doc('ItemsList');
    return ref
        .set({"Items": FieldValue.arrayUnion(data)}, SetOptions(merge: true));
  }

  Future<void> createBusinessList(List<String> data) async {
    DocumentReference ref = FirebaseFirestore.instance
        .collection('categoriesList')
        .doc('BusinessList');
    return ref
        .set({"Items": FieldValue.arrayUnion(data)}, SetOptions(merge: true));
  }

  Future<void> updateDueList(
      List<int> data, String collname, String doc) async {
    DocumentReference ref =
        FirebaseFirestore.instance.collection(collname).doc(doc);
    return ref
        .set({"due": FieldValue.arrayUnion(data)}, SetOptions(merge: true));
  }

  Future<void> updatePaidList(
      List<int> data, String collname, String doc) async {
    DocumentReference ref =
        FirebaseFirestore.instance.collection(collname).doc(doc);
    return ref
        .set({"paid": FieldValue.arrayUnion(data)}, SetOptions(merge: true));
  }

  getBisDataFromDocumentWithID(iD) async {
    return await FirebaseFirestore.instance
        .collection('BusinessProfile')
        .doc(iD)
        .get();
  }

  getDriverDataFromDocumentWithID(iD) async {
    return await FirebaseFirestore.instance
        .collection('ProfessionalProfile')
        .doc(iD)
        .get();
  }

  createOrder(Map<String, dynamic> userDataMap) async {
    DocumentReference ref =
        FirebaseFirestore.instance.collection('orders').doc();
    return ref.set(userDataMap, SetOptions(merge: true));
  }

  updateOrder(Map<String, dynamic> userDataMap, docID) async {
    DocumentReference ref =
        FirebaseFirestore.instance.collection('orders').doc(docID);
    return ref.set(userDataMap, SetOptions(merge: true));
  }

  deleteOrderData(docId) async {
    FirebaseFirestore.instance
        .collection('orders')
        .doc(docId)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  addPopular(Map<String, dynamic> userDataMap) async {
    DocumentReference ref =
        FirebaseFirestore.instance.collection('popular').doc();
    return ref.set(userDataMap, SetOptions(merge: true));
  }

  deletePopular(docId) async {
    FirebaseFirestore.instance
        .collection('popular')
        .doc(docId)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  getDeveloperData() async {
    return await FirebaseFirestore.instance
        .collection('res')
        .doc('developerdetails')
        .get();
  }
}

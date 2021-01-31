// class User {
//   final String userId;
//   User({this.userId});
// }

class UserData {
  final String userId;
  final String fullNames;
  final String email;
  final String phone;
  final String picture;
  final String address;
  final bool admin, isHealth, isLegal;
  UserData(
      {this.userId,
      this.fullNames,
      this.email,
      this.phone,
      this.address,
      this.picture,
      this.admin,
      this.isHealth,
      this.isLegal});

  Map<String, dynamic> getDataMap() {
    return {
      "userId": userId,
      "fullNames": fullNames,
      "email": email,
      "phone": phone,
      "address": address,
      "picture": picture,
      "admin": admin,
      "isHealth": isHealth,
      "isLegal": isLegal
    };
  }
}

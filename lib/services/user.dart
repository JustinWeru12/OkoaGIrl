class User {
  final String userId;
  User({this.userId});
}

class UserData {
  final String userId;
  final String fullNames;
  final String email;
  final String phone;
  final String picture;
  final String address;
  final String product;
  final bool admin, isDriver, isSeller;
  UserData(
      {this.userId,
      this.fullNames,
      this.email,
      this.phone,
      this.address,
      this.picture,
      this.product,
      this.admin,
      this.isDriver,
      this.isSeller});

  Map<String, dynamic> getDataMap() {
    return {
      "userId": userId,
      "fullNames": fullNames,
      "email": email,
      "phone": phone,
      "address": address,
      "picture": picture,
      "admin": admin,
      "isDriver": isDriver,
      "isSeller": isSeller,
      "product": product,
    };
  }
}

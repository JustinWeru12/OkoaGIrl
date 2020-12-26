import 'dart:convert';

class CategoryData {
  CategoryData({
    this.description,
    this.name,
    this.pictures,
  });

  final String description;
  final String name;
  final String pictures;

  Map<String, dynamic> getCategoryDataMap() {
    return {
      "description": description,
      "name": name,
      "pictures": pictures,
    };
  }
}

class BusinessData {
  BusinessData({
    this.name,
    this.pictures,
  });

  final String name;
  final String pictures;

  Map<String, dynamic> getBusinessDataMap() {
    return {
      "name": name,
      "pictures": pictures,
    };
  }
}

class ItemData {
  ItemData(
      {this.description,
      this.name,
      this.pictures,
      this.category,
      this.subcategory,
      this.price,
      this.owner,
      this.ownerName,
      this.available});

  final String description;
  final String name, category, subcategory;
  final String pictures, owner, ownerName;
  final int price;
  final bool available;

  Map<String, dynamic> getItemDataMap() {
    return {
      "description": description,
      "name": name,
      "pictures": pictures,
      "category": category,
      "subcategory": subcategory,
      "price": price,
      "owner": owner,
      "ownerName": ownerName,
      "available": available
    };
  }
}

class CartData {
  CartData(
      {this.name,
      this.picture,
      this.category,
      this.price,
      this.quantity,
      this.fullName,
      this.ownerName,
      this.owner});

  final String name, category, picture, owner, fullName, ownerName;
  final int price;
  int quantity;

  Map<String, dynamic> getCartDataMap() {
    return {
      "name": name,
      "picture": picture,
      "category": category,
      "price": price,
      "quantity": quantity,
      "owner": owner,
      "ownerName": ownerName,
      "fullName": fullName
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "picture": picture,
      "category": category,
      "price": price,
      "quantity": quantity,
      "owner": owner,
      "ownerName": ownerName,
      "fullName": fullName
    };
  }

  factory CartData.fromJson(Map<String, dynamic> json) => CartData(
      name: json["name"],
      picture: json["picture"],
      category: json["category"],
      price: json["price"],
      quantity: json["quantity"],
      owner: json["owner"],
      ownerName: json["ownerName"],
      fullName: json["fullName"]);
}

List<CartData> cartDataFromJson(String str) =>
    List<CartData>.from(json.decode(str).map((x) => CartData.fromJson(x)));

String cartDataToJson(List<CartData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProfileData {
  final String name,
      bio,
      kraPin,
      idNo,
      phone,
      licenseNo,
      noPlate,
      email,
      scanId,
      address,
      scanLicense,
      insurance,
      category,
      busCategory,
      makeModel;
  final location;
  final bool isVerified;
  final List<String> pictures;
  final List<int> due;
  final List<int> paid;

  ProfileData(
      {this.name,
      this.bio,
      this.kraPin,
      this.idNo,
      this.phone,
      this.licenseNo,
      this.noPlate,
      this.email,
      this.scanId,
      this.address,
      this.scanLicense,
      this.insurance,
      this.category,
      this.busCategory,
      this.location,
      this.isVerified,
      this.makeModel,
      this.pictures,
      this.due, this.paid});

  Map<String, dynamic> getProfileDataMap() {
    return {
      "name": name,
      "bio": bio,
      "kraPin": kraPin,
      "idNo": idNo,
      "phone": phone,
      "licenseNo": licenseNo,
      "noPlate": noPlate,
      "email": email,
      "scanId": scanId,
      "address": address,
      "scanLicense": scanLicense,
      "insurance": insurance,
      "category": category,
      "businessCategory": busCategory,
      "location": location,
      "isVerified": isVerified,
      "makeModel": makeModel,
      "pictures": pictures,
      "paid": paid,
      "due": due,
    };
  }
}

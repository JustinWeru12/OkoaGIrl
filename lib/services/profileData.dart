class ProfileData {
  final String name,
      bio,
      kraPin,
      idNo,
      phone,
      licenseNo,
      email,
      scanId,
      address,
      scanLicense,
      insurance,
      makeModel;
  final location;
  final bool isVerified;
  final List<dynamic> pictures;
  final List<int> due;
  final List<int> paid;

  ProfileData(
      {this.name,
      this.bio,
      this.kraPin,
      this.idNo,
      this.phone,
      this.licenseNo,
      this.email,
      this.scanId,
      this.address,
      this.scanLicense,
      this.insurance,
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
      "email": email,
      "scanId": scanId,
      "address": address,
      "scanLicense": scanLicense,
      "insurance": insurance,
      "location": location,
      "isVerified": false,
      "pictures": pictures,
    };
  }
}

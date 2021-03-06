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
      this.pictures});

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

  factory ProfileData.fromJson(Map<String, dynamic> map) => ProfileData(
        name: map["name"],
        bio: map["bio"],
        kraPin: map["kraPin"],
        idNo: map["idNo"],
        phone: map["phone"],
        licenseNo: map["licenseNo"],
        email: map["email"],
        scanId: map["scanId"],
        address: map["address"],
        scanLicense: map["scanLicense"],
        insurance: map["insurance"],
        location: map["location"],
        isVerified: map["isVerified"],
        pictures: map["pictures"],
      );
}

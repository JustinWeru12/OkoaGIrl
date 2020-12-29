class DonationDataData {
  DonationDataData({
    this.name,
    this.amount,
  });

  final String name;
  final String amount;

  Map<String, dynamic> getDonationDataDataMap() {
    return {
      "amount": amount,
      "name": name,
    };
  }
}

class CardData {
  final String cardNumber, expiryDate, cardHolderName, cvvCode;
  final int color;

  CardData({
    this.cardNumber,
    this.expiryDate,
    this.cardHolderName,
    this.cvvCode,
    this.color,
  });

  Map<String, dynamic> getCardDataMap() {
    return {
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cardHolderName': cardHolderName,
      'cvvCode': cvvCode,
      'color': color,
    };
  }
}
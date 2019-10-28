import 'package:e_pay_gateway/e_pay_gateway.dart';

class FlutterwaveCardSerializer extends Serializable{

  String cardNo;
  String cvv;
  String expiryMonth;
  String expiryYear;
  String currency;
  String country;
  String amount;
  String email;


  @override
  Map<String, dynamic> asMap() {
    return {
      "cardNo": cardNo,
      "cvv": cvv,
      "expiryMonth": expiryMonth,
      "expiryYear": expiryYear,
      "currency": currency,
      "country": country,
      "amount": amount,
      "email": email,
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    cardNo = object['cardNo'].toString();
    cvv = object['cvv'].toString();
    expiryMonth = object['expiryMonth'].toString();
    expiryYear = object['expiryYear'].toString();
    currency = object['currency'].toString();
    country = object['country'].toString();
    amount = object['amount'].toString();
    email = object['email'].toString();
  }

}
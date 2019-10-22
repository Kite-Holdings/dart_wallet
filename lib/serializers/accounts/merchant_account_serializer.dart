import 'package:e_pay_gateway/e_pay_gateway.dart';

class MerchantAccountSerializer extends Serializable{
  String identifier;
  String identifierType = 'KRAPin';
  String username;
  String phoneNo;
  String email;
  String password;
  String accountType = "merchant";

  @override
  Map<String, dynamic> asMap() {
    return {
      "identifier": identifier,
      "username": username,
      "phoneNo": phoneNo,
      "email": email,
      "password": password,
      "accountType": accountType,
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    identifier = object['identifier'].toString();
    username = object['username'].toString();
    phoneNo = object['phoneNo'].toString();
    email = object['email'].toString();
    password = object['password'].toString();
  }


}
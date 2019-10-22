import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/accounts/account_model.dart';

class ConsumerAccountSerializer extends Serializable{
  String identifier;
  String identifierType;
  String username;
  String phoneNo;
  String email;
  String password;
  String accountType = "consumer";

  IdentifierType get getIdentifierType{
    switch (identifierType) {
      case 'NationalId':
        return IdentifierType.nationalId;
        break;
      case 'BirthCertificate':
        return IdentifierType.birthCertificate;
        break;
      case 'KRAPin':
        return IdentifierType.kraPin;
        break;
      case 'Passport':
        return IdentifierType.passport;
        break;
      default:
        return null;
    }
  }



  @override
  Map<String, dynamic> asMap() {
    return {
      "identifier": identifier,
      "identifierType": identifierType,
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
    identifierType = object['identifierType'].toString();
    username = object['username'].toString();
    phoneNo = object['phoneNo'].toString();
    email = object['email'].toString();
    password = object['password'].toString();
  }

}
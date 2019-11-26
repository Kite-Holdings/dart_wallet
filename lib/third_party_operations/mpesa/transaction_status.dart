import 'dart:convert';

import 'package:e_pay_gateway/third_party_operations/mpesa/fetch_mpesa_token.dart';
import 'package:e_pay_gateway/third_party_operations/mpesa/settings.dart';
import 'package:http/http.dart' as http;


class TransactionStatus{

  TransactionStatus({
    this.transactionID,
    this.partyA,
    this.identifierType = IdentifierType.organizationShortCode,
    this.remarks,
    this.occasion,
  });

  final String transactionID;
  final String partyA;
  final IdentifierType identifierType;
  final String remarks;
  final String occasion;


  String _initiator;
  String _securityCredential;
  final String _commandID = 'TransactionStatusQuery';
  String _resultURL;
  String _queueTimeOutURL;


  void process()async{
    _initiator = businessLabel;
    _securityCredential = securityCredential;
    _resultURL = mpesaCallBackURL;
    _queueTimeOutURL = mpesaCallBackURL;

    final String accessToken =await fetchMpesaToken();

    final Map<String, String> _payload = {
      "Initiator": _initiator,
      "SecurityCredential": _securityCredential,
      "CommandID": _commandID,
      "TransactionID": transactionID,
      "PartyA": partyA,
      "IdentifierType": identifierTypeValue(),
      "ResultURL": _resultURL,
      "QueueTimeOutURL": _queueTimeOutURL,
      "Remarks": remarks,
      "Occasion": occasion
    };

    final Map<String, String> headers = {
      'content-type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    final String url = transactionStatusURL;


    final http.Response r = await http.post(url, headers: headers, body: json.encode(_payload));
    print(r);

  }



  String identifierTypeValue(){
    switch (identifierType) {
      case IdentifierType.mSISDN: 
        return '1';
        break;
      case IdentifierType.tillNumber: 
        return '2';
        break;
      case IdentifierType.organizationShortCode: 
        return '4';
        break;
      default:
        return '0';
    }
  }
}

enum IdentifierType{
  mSISDN,
  tillNumber,
  organizationShortCode
}



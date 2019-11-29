import 'dart:convert';

import 'package:e_pay_gateway/models.dart/accounts/account_model.dart';
import 'package:e_pay_gateway/models.dart/companies%20models/company_model.dart';
import 'package:e_pay_gateway/models.dart/request_responses/requests_model.dart';
import 'package:e_pay_gateway/models.dart/request_responses/responses_model.dart';
import 'package:e_pay_gateway/third_party_operations/flutter_wave/encryp.dart';
import 'package:e_pay_gateway/third_party_operations/flutter_wave/settings.dart';
import 'package:http/http.dart' as http;
import 'package:pedantic/pedantic.dart';

class FlutterWaveCardDeposit{

  FlutterWaveCardDeposit({
    this.cardNo,
    this.cvv,
    this.expiryMonth,
    this.expiryYear,
    this.currency = 'KES',
    this.country = 'KE',
    this.amount,
    this.email,
    this.reference,
    this.callbackUrl,
    this.uid,
    this.requestTransactionType
  });

  final String cardNo;
  final String cvv;
  final String expiryMonth;
  final String expiryYear;
  final String currency;
  final String country;
  final String amount;
  final String email;
  final String reference;
  final String callbackUrl;
  final String uid;
  final RequestTransactionType requestTransactionType;

  final String _publicKey = flutterWavePubKey;
  final String _secretKey = flutterWaveSecurityKey;
  String txRef;
  String redirectUrl = flutterWaveCardredirect;

  Future flutterWaveCardTransact() async{

    // get client details
    String _client;
    final AccountModel _accountModel = AccountModel();
    final Map<String, dynamic> _account = await _accountModel.findById(uid);
    if(_account == null){
      final CompanyModel _companyModel = CompanyModel();
      final Map<String, dynamic> _company = await _companyModel.findById(uid);
      _client = _company['data']['name'].toString();
    } else {
      _client = _account['address']['email'].toString();
    }

    final RequestsModel _requestsModel = RequestsModel(
      url: '/thirdParties/cardPayment',
      requestType: RequestType.card,
      account: _client,
      transactionType: requestTransactionType,
      metadata: {
        'amount': amount,
        'cardNo': cardNo,
        'email': email,
        'currency': currency,
        'country': country,
        'reference': reference,
        'callbackUrl': callbackUrl 
      }
    );

    final String _id = await _requestsModel.save();


    txRef = _id;
    final Map<String, dynamic> _data = {
      "PBFPubKey": _publicKey,
      "cardno": cardNo,
      "cvv": cvv,
      "expirymonth": expiryMonth,
      "expiryyear": expiryYear,
      "currency": currency,
      "country": country,
      "amount": amount,
      "email": email,
      "txRef": txRef,
      "redirect_url": redirectUrl,
    };

    final String _hashedSecKey = getKey(_secretKey);
    final String encrypt3DESKey = encryptData(_hashedSecKey, json.encode(_data));
    final Map<String, dynamic> _payload = {
        "PBFPubKey": _publicKey,
        "client": encrypt3DESKey,
        "alg": "3DES-24"
    };

    const String url = flutterWaveCardUrl;
    final Map<String, String> headers = {
      'content-type': 'application/json',
    };
    
    final http.Response _flutterWaveRes = await http.post(url, headers: headers, body: json.encode(_payload));
    final _cardRes = json.decode(_flutterWaveRes.body);
    _cardRes['reqRef'] = _id;
    final ResponsesModel _responsesModel = ResponsesModel(
      requestId: _id,
      responseType: ResposeType.card,
      responseBody: _cardRes,
      status: ResponsesStatus.success
    );

    unawaited(_responsesModel.save());


    return _cardRes;


  }


}
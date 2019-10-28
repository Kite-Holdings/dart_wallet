import 'dart:convert';

import 'package:e_pay_gateway/third_party_operations/flutter_wave/encryp.dart';
import 'package:e_pay_gateway/third_party_operations/flutter_wave/settings.dart';
import 'package:e_pay_gateway/utils/database_bridge.dart';
import 'package:http/http.dart' as http;

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
  });

  final String cardNo;
  final String cvv;
  final String expiryMonth;
  final String expiryYear;
  final String currency;
  final String country;
  final String amount;
  final String email;

  final String _publicKey = flutterWavePubKey;
  final String _secretKey = flutterWaveSecurityKey;
  String txRef;
  String redirectUrl = flutterWaveCardredirect;

  Future flutterWaveCardTransact() async{
    ObjectId _objId = ObjectId();
    txRef = _objId.toString().split('"')[1];
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

    return json.decode(_flutterWaveRes.body);


  }


}
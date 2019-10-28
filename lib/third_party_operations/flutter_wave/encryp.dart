import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:tripledes/tripledes.dart';

String getKey(String secKey){
  final String _hashedseckey =  md5.convert(utf8.encode(secKey)).toString();
  final String _hashedseckeylast12 = _hashedseckey.substring(_hashedseckey.length -12, _hashedseckey.length);
  final String _seckeyadjusted = secKey.split('-')[1] + secKey.split('-')[2];
  final String _seckeyadjustedfirst12 = _seckeyadjusted.substring(0, 12);
  return _seckeyadjustedfirst12 + _hashedseckeylast12;
}

String encryptData(String key, String plainText){
  final BlockCipher _blockCipher = BlockCipher(DESEngine(), key);
  final String _ciphertext = _blockCipher.encodeB64(plainText);
  return _ciphertext;
}

void cardPay(){
  final Map<String, dynamic> _payload = {
    'PBFPubKey': 'FLWPUBK_TEST-0b4e4d179f388fbc087bc9664cce3949-X',
    "cardno": "54388980459253010016924414560229",
    "cvv": "637",
    "expirymonth": "01",
    "expiryyear": "21",
    "currency": "KES",
    "country": "KE",
    'suggested_auth': 'pin',
    'pin': '3310',
    "amount": "10",
    'txRef': 'MC-TESTREF-1234',
    "email": "maestrojolly@gmail.com",
    "phonenumber": "0902620185",
    "firstname": "maestro",
    "lastname": "jolly",
    "IP": "355426087298442",
    "device_fingerprint": "69e6b7f0b72037aa8428b70fbe03986c"
};
}
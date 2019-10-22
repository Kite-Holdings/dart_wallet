import 'package:e_pay_gateway/settings/settings.dart';
import 'package:e_pay_gateway/utils/database_bridge.dart';
import 'package:mongo_dart/mongo_dart.dart' show where, ObjectId;
import 'package:random_string/random_string.dart';

class TokenModel {
  String token;
  String ownerRef;
  int validTill;

  final DatabaseBridge _databaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'tokens');



  Future<Map<String, dynamic>> getToken({String owner, int duration = 300}) async{
    ownerRef = owner;
    token = randomAlphaNumeric(20);
    validTill = _getExpireDate(duration);

    await _databaseBridge.insert({
      'token': token,
      'ownerRef': ownerRef,
      'validTill': validTill
    });
    return {
      "status": "0",
      "data": {
        "token": token,
        "validTill": validTill,
      }
    };


    
  }

  Future<Map<String, dynamic>> verifyToken(String token)async{
    Map<String, dynamic> _responce = {};
    // bool _exists = await tokens
    Map<String, dynamic> _tokenInfo = await _databaseBridge.findOneBy(
      where.eq("token", token)
    );
    if(_tokenInfo['token'] != null){
      // TODO: check if token has expired
      bool _hasExpired = DateTime.now().millisecondsSinceEpoch/1000 > int.parse(_tokenInfo['validTill'].toString());


      // TODO: if not expired return owner obj
      if(!_hasExpired){
        final String _ref = _tokenInfo['ownerRef'].toString();
        final String _ownerId = _ref.split("/").last.toString();
        final String _collectionName = _ref.split("/")[1].toString();
        final DatabaseBridge _ownerConnection = DatabaseBridge(dbUrl: databaseUrl, collectionName: _collectionName);
        final Map<String, dynamic> _ownerInfo = await _ownerConnection.findOneBy(where.id(ObjectId.parse(_ownerId)));
        _responce['status'] = '0';
        _responce['data'] = _ownerInfo;
      }else{
        _responce['status'] = '1';
        _responce['data'] = 'expired token';
      }


    } else{
      _responce['status'] = '1';
      _responce['data'] = 'invalid token';
    }

    return _responce;
  }






  int _getExpireDate(int duration){
    double _duration = DateTime.now().millisecondsSinceEpoch/1000 + duration;

    return _duration.floor();
  }

}
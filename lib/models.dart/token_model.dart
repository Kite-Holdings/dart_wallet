import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:random_string/random_string.dart';

class TokenModel {
  String token;
  String ownerRef;
  int validTill;

  static Db db =  Db(databaseUrl);
  final DbCollection tokens = db.collection('tokens');



  Future<Map<String, dynamic>> getToken({String owner, int duration = 300}) async{
    ownerRef = owner;
    token = randomAlphaNumeric(20);
    validTill = _getExpireDate(duration);

    await db.open();
    
    try{
      await tokens.insert({
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

    } catch (e){
      await db.close();
      return {"status": "1", "data": {'error': "Server error occured"}};
    }
    
  }

  Future<Map<String, dynamic>> verifyToken(String token)async{
    Map<String, dynamic> _responce = {};
    await db.open();
    // bool _exists = await tokens
    Map<String, dynamic> _tokenInfo = await tokens.findOne(
      where.eq("token", token)
    );
    if(_tokenInfo['token'] != null){
      // TODO: check if token has expired
      bool _hasExpired = DateTime.now().millisecondsSinceEpoch/100 > int.parse(_tokenInfo['validTill'].toString());


      // TODO: if not expired return owner obj
      if(!_hasExpired){
        final String _ref = _tokenInfo['ownerRef'].toString();
        String _ownerId = _ref.split("/").last.toString();
        String _collectionName = _ref.split("/")[1].toString();
        DbCollection _ownerCollection = db.collection(_collectionName);
        Map<String, dynamic> _ownerInfo = await _ownerCollection.findOne(where.id(ObjectId.parse(_ownerId)));
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
    double _duration = DateTime.now().millisecondsSinceEpoch/100 + duration;

    return _duration.floor();
  }

}
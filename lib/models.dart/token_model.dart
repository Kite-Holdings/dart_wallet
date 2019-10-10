import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:random_string/random_string.dart';

class TokenModel {
  String token;
  String ownerRef;
  DateTime validTill;

  static Db db =  Db(databaseUrl);
  final DbCollection tokens = db.collection('tokens');



  Future<Map<String, dynamic>> getToken({String owner, int duration = 300}) async{
    ownerRef = owner;
    token = randomAlphaNumeric(10);
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

  Future verifyToken(String token)async{
    await db.open();
    // bool _exists = await tokens
    Map<String, dynamic> _tokenInfo = await tokens.findOne(
      where.eq("token", token)
    );
    if(_tokenInfo['token'] != null){
      final String _ref = _tokenInfo['ownerRef'].toString();
    }
  }






  DateTime _getExpireDate(int duration){
    DateTime _now = DateTime.now();
    int seconds = _now.second + duration;
    int _hr;
    int _min;
    if(seconds > 60){
      _min = _now.minute + 1;
      if(_min > 60){
        _hr = _now.hour + 1;
        _min = 60 - _min;
      }
      seconds = 60 - seconds;
    } else {
      _hr = _now.hour;
      _min = _now.minute;
    }
    return DateTime(
      _now.year,
      _now.month,
      _now.day,
      _hr,
      _min,
      seconds
    );
  }

}
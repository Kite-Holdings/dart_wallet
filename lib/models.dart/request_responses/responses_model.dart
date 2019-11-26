import 'package:e_pay_gateway/utils/database_bridge.dart';

class ResponsesModel{

  ResponsesModel({
    this.requestId,
    this.responseType,
    this.responseBody,
    this.statusCode,
    this.statusMessage,
  });

  final String requestId;
  final ResposeType responseType;
  final int statusCode;
  final String statusMessage;
  final dynamic responseBody;




    final DatabaseBridge _databaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'allResponses');


  Map<String, dynamic> asMap(){
    return{
      "requestId": requestId,
      "responseType": _stringReponseType(),
      "responseBody": responseBody,
    };
  }

  ResponsesModel fromMap(Map<String, dynamic> object){
    return ResponsesModel(
      requestId: object['requestId'].toString(),
      responseType: _toResponseType(object['responseType'].toString()),
      responseBody: object['responseBody'],
    );
  }


  Future<String> save() async{
    final ObjectId _id = ObjectId();
    await _databaseBridge.save({
      '_id': _id,
      "requestId": requestId,
      "responseType": _stringReponseType(),
      "responseBody": responseBody,
    });
    return _id.toJson();
  }

  Future<Map<String, dynamic>> getAll()async{
    final Map<String, dynamic> _res = await _databaseBridge.find();
    final _body = _res['body'].map((item){
      final ObjectId _id = ObjectId.parse(item['_id'].toString().split('"')[1]);
      item['date'] = _id.dateTime;
      return item;
    });
    _res['body'] = _body;
    return _res;
  }

  Future<Map<String, dynamic>> getById(ObjectId id)async{
    final Map<String, dynamic> _res = await _databaseBridge.findOneBy(where.id(id));
    return _res;
  }





  String _stringReponseType(){
    switch (responseType) {
      case ResposeType.callBack:
        return 'callBack';
        break;
      case ResposeType.card:
        return 'card';
        break;
      case ResposeType.mpesaStkPush:
        return 'mpesaStkPush';
        break;
      case ResposeType.stkQuery:
        return 'stkQuery';
        break;
      case ResposeType.token:
        return 'token';
        break;
      default:
        return 'notDefined';
    }
  }

  ResposeType _toResponseType(String value){
    switch (value) {
      case 'card':
        return ResposeType.card;
        break;
      case 'callBack':
        return ResposeType.callBack;
        break;
      case 'mpesaStkPush':
        return ResposeType.mpesaStkPush;
        break;
      case 'stkQuery':
        return ResposeType.stkQuery;
        break;
      case 'token':
        return ResposeType.token;
        break;
      default:
        return ResposeType.notDefined;
    }
  }
}

enum ResposeType{
  callBack,
  card,
  mpesaStkPush,
  stkQuery,
  token,
  notDefined
}
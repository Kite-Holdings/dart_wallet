import 'package:e_pay_gateway/utils/database_bridge.dart';

class RequestsModel{

  RequestsModel({
    this.url,
    this.requestType,
    this.metadata
  });

  final String url;
  final RequestType requestType;
  final dynamic metadata;

  final DatabaseBridge _databaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'allRequests');


  Map<String, dynamic> asMap(){
    return{
      "url": url,
      "requestType": _stringRequestType,
      "metadata": metadata,
    };
  }

  RequestsModel fromMap(Map<String, dynamic> object){
    return RequestsModel(
      url: object['url'].toString(),
      requestType: _toRequestType(object['metadata'].toString()),
      metadata: object['metadata'],
    );
  }


  Future<String> save() async{
    final ObjectId _id = ObjectId();
    await _databaseBridge.save({
      '_id': _id,
      "url": url,
      "requestType": _stringRequestType(),
      "metadata": metadata,
    });
    return _id.toJson();
  }

  Future<Map<String, dynamic>> getAll()async{
    final Map<String, dynamic> _res = await _databaseBridge.find();
    var _body = _res['body'].map((item){
      ObjectId _id = ObjectId.parse(item['_id'].toString().split('"')[1]);
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







  String _stringRequestType(){
    switch (requestType) {
      case RequestType.card:
        return 'card';
        break;
      case RequestType.mpesaStkPush:
        return 'mpesaStkPush';
        break;
      default:
        return 'notDefined';
    }
  }

  RequestType _toRequestType(String value){
    switch (value) {
      case 'card':
        return RequestType.card;
        break;
      case 'mpesaStkPush':
        return RequestType.mpesaStkPush;
        break;
      default:
        return RequestType.notDefined;
    }
  }
}

enum RequestType{
  mpesaStkPush,
  card,
  notDefined
}
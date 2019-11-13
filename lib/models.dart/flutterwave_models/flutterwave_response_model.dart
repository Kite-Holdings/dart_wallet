import 'package:e_pay_gateway/utils/database_bridge.dart';

class FlutterwaveResponseModel {
  FlutterwaveResponseModel({this.body});

  final DatabaseBridge _databaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'FlutterwaveResponses');
  final Map<String, dynamic> body;

  Future<String> save() async{
    final ObjectId _id = ObjectId();
    body['_id'] = _id;
    await _databaseBridge.save(body);
    return _id.toJson();
  }

  Future<Map<String, dynamic>> findAll() async {
    final Map<String, dynamic> _data = await _databaseBridge.findBy();
    return _data;
  }

}
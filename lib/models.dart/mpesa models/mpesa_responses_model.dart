import 'package:e_pay_gateway/settings/settings.dart';
import 'package:e_pay_gateway/utils/database_bridge.dart';
import 'package:mongo_dart/mongo_dart.dart' show where;

class MpesaResponsesModel{

  MpesaResponsesModel({this.body});

  final DatabaseBridge _databaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'mpesa_responses');
  final Map<String, dynamic> body;

  Future<String> save() async{
    final ObjectId _id = ObjectId();
    body['_id'] = _id;
    await _databaseBridge.save(body);
    return _id.toString().split('"')[1];
  }

  Future<Map<String, dynamic>> findAll() async {
    final Map<String, dynamic> _data = await _databaseBridge.findBy();
    return _data;
  }

  Future<Map<String, dynamic>> findByAccRef(String accRef) async {
    final Map<String, dynamic> _data = await _databaseBridge.findBy(where.eq("accRef", accRef));
    return _data;
  }

  Future<Map<String, dynamic>> findByMpesaReceiptNumber(String mpesaReceiptNumber) async {
    final Map<String, dynamic> _data = await _databaseBridge.findBy(where.eq("MpesaReceiptNumber", mpesaReceiptNumber));
    return _data;
  }

}
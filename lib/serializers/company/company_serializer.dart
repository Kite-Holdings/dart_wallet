import 'package:e_pay_gateway/controllers/utils/counter_intrement.dart';
import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/wallet_serializer.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';

class CompanySerializer extends Serializable{
  String name;
  
  String code;
  Map<String, dynamic> accounts;
  String walletRef;


  final Db db =  Db("mongodb://localhost:27017/wallet");

  @override
  Map<String, dynamic> asMap() {
    return {
      "name": name,
      "code": code,
      "accounts": accounts,
      "walletRef": walletRef
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    name = object['name'].toString();
  }
  String stringifyCount(int count){
    String c = count.toString();
    for(int i = c.length; i< 3; i++){
      c = '0' + c;
    }
    return c;
  }

  Future save()async{
    final int c = await companyCounter ('company_counter');
    final String _code = stringifyCount(c);
    final String _name = name;

    await db.open();
    try{
      final DbCollection companies = db.collection('companies');
      await companies.insert({
        'name': _name,
        'code': _code,
      });

      final Map<String, dynamic> account = await companies.findOne(where.eq('name', name));
      final _id = account['_id'];
      final String companyRef = '$databaseName + /companies/ + ${_id.toString()}';
      final WalletSerializer walletSerializer = WalletSerializer();
      final Map<String, dynamic> newWallet = await walletSerializer.save(accountRefference: companyRef, accountType: '1', companyCode: _code);
      final String walletRef = newWallet['ref'].toString();

      await companies.update(where.eq('_id', account['_id']), modify.set("wallet", walletRef));
      
      await db.close();

      return {
        "name": _name,
        "code": _code,
        "wallet": {
          "balance": newWallet["balance"],
          "walletAccountNo": newWallet["walletAccountNo"]
        },
      };

    }catch (e){
      await db.close();
      if(e['code'] == 11000){
        return {'error': "Name already taken"};
      }
      return {'error': "an error occured"};
    }
  }


  Future<List<Map<String, dynamic>>> getAll()async{
    await db.open();
    final List<Map<String, dynamic>> _companiesList = [];
    final DbCollection companies = db.collection('companies');
    final Stream<Map<String, dynamic>> _companiesStream = companies.find();

    
    await _companiesStream.forEach(_companiesList.add);
    
    await db.close();
    return _companiesList;
  }

  Future<Map<String, dynamic>> findByCode(String companyCode)async{
    await db.open();
    final DbCollection companies = db.collection('companies');
    final Map<String, dynamic> company = await companies.findOne(where.eq('code', companyCode));

    await db.close();
    return company;
  }

}

import 'package:e_pay_gateway/controllers/utils/counter_intrement.dart';
import 'package:e_pay_gateway/models.dart/utils/strigify_count.dart';
import 'package:e_pay_gateway/serializers/wallet_serializer.dart';
import 'package:e_pay_gateway/settings/settings.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:random_string/random_string.dart';

class CompanyModel{
 
  CompanyModel({
    this.name,
    this.code,
    this.consumerKey,
    this.secretKey,
    this.walletRef,
    this.dateCreated,
  });


  final String name;
  String code;
  String consumerKey;
  String secretKey;
  String walletRef;
  DateTime dateCreated;

  Map<String, dynamic> asMap(){
    return {
      'name': name,
      'code': code,
      'consumerKey': consumerKey,
      'secretKey': secretKey,
      'dateCreated': dateCreated,
    };
  }

  static Db db =  Db(databaseUrl);
  final DbCollection companies = db.collection('companies');

  Future<Map<String, dynamic>> create() async {
    final int c = await companyCounter ('company_counter');
    final String _code = code == null ? stringifyCount(c, 3) : code;
    final String _name = name;
    
    final String _secretKey = secretKey == null ? randomAlphaNumeric(10) : secretKey;
    final String _consumerKey = consumerKey == null ? name+_code : consumerKey;
    dateCreated = DateTime.now();

    await db.open();
    try{
      await companies.insert({
        'name': _name,
        'code': _code,
        'consumerKey': _consumerKey,
        'secretKey': _secretKey,
        'dateCreated': dateCreated
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
        "status": "0",
        "data": {
          "name": _name,
          "code": _code,
          "consumerKey": _consumerKey,
          "secretKey": _secretKey,
          "wallet": {
            "balance": newWallet["balance"],
            "walletAccountNo": newWallet["walletAccountNo"]
          },
      }
      };

    }catch (e){
      await db.close();
      if(e['code'] == 11000){
        return {"status": "1", "data": {'error': "Name already taken"}};
      }
      return {"status": "1", "data": {'error': "Server error occured"}};
    }
  }

  Future<Map<String, dynamic>> findByCode(String companyCode)async{
    await db.open();
    try{
      final DbCollection companies = db.collection('companies');
      final Map<String, dynamic> _company = await companies.findOne(where.eq('code', companyCode));

      await db.close();

      return {
        "status": "0",
        "data": _company
      };
    } catch (e){
      await db.close();
      return {"status": "1", "data": {'error': "Server error occured"}};
    }
    
  }

  Future<Map<String, dynamic>> getAll()async{
    await db.open();
    try{
      final List<Map<String, dynamic>> _companiesList = [];
      final DbCollection companies = db.collection('companies');
      final Stream<Map<String, dynamic>> _companiesStream = companies.find();

      
      await _companiesStream.forEach(_companiesList.add);
      
      await db.close();
      return {
        "status": "0",
        "data": _companiesList
      };

    } catch (e){
      await db.close();
      return {"status": "1", "data": {'error': "Server error occured"}};
    }
    
  }

}
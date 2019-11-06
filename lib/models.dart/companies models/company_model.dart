import 'package:e_pay_gateway/controllers/utils/counter_intrement.dart';
import 'package:e_pay_gateway/models.dart/utils/strigify_count.dart';
import 'package:e_pay_gateway/models.dart/wallets/wallet_model.dart';
import 'package:e_pay_gateway/utils/database_bridge.dart';
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

  final DatabaseBridge _databaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'companies');

  Future<Map<String, dynamic>> create() async {
    final int c = await companyCounter ('company_counter');
    final String _code = code == null ? stringifyCount(c, 3) : code;
    final String _name = name;
    
    final String _secretKey = secretKey == null ? randomAlphaNumeric(10) : secretKey;
    final String _consumerKey = consumerKey == null ? name+_code : consumerKey;
    dateCreated = DateTime.now();

    try{
      await _databaseBridge.insert({
        'name': _name,
        'code': _code,
        'consumerKey': _consumerKey,
        'secretKey': _secretKey,
        'dateCreated': dateCreated
      });

      final Map<String, dynamic> account = await _databaseBridge.findOneBy(where.eq('name', name));
      final _id = account['_id'].toString().split('"')[1];
      final String companyRef = '$databaseName/companies/${_id.toString()}';
      final WalletModel _walletModel = WalletModel(accountRefference: companyRef, accountType: '1', companyCode: _code);
      final Map<String, dynamic> newWallet = await _walletModel.save();
      final String walletRef = newWallet['ref'].toString();

      await _databaseBridge.update(where.eq('_id', account['_id']), modify.set("wallet", walletRef));
      

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
      if(e['code'] == 11000){
        return {"status": "1", "data": {'error': "Name already taken"}};
      }
      return {"status": "1", "data": {'error': "Server error occured"}};
    }
  }

  Future<Map<String, dynamic>> findByCode(String companyCode)async{
    
    final Map<String, dynamic> _company = await _databaseBridge.findOneBy(where.eq('code', companyCode));
    return {
      "status": "0",
      "data": _company
    };

    
  }

  Future<Map<String, dynamic>> getAll()async{
    final Map<String, dynamic> _companiesMap = await _databaseBridge.find();

    
    final _companiesList = _companiesMap['body'];
    
    return {
      "status": "0",
      "data": _companiesList
    };

    
  }

}

import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/accounts/account_model.dart';
import 'package:e_pay_gateway/serializers/accounts/consumer_account_serializer.dart';
import 'package:e_pay_gateway/serializers/accounts/merchant_account_serializer.dart';
import 'package:e_pay_gateway/utils/database_bridge.dart';

class MerchantAccountController extends ResourceController{

  @Operation.get()
  Future<Response> getAll()async{
    final AccountModel _accountModel = AccountModel();
    final _accountsList = await _accountModel.getAll();
    return Response.ok(_accountsList);
  }

  @Operation.get('accountId')
  Future<Response> getOne(@Bind.path("accountId") String accountId)async{
    final AccountModel _accountModel = AccountModel();
    final Map<String, dynamic> _account = await _accountModel.findByIdentifier(accountId);
    return Response.ok(_account);
  }

  @Operation.post()
  Future<Response> createUser(@Bind.body() MerchantAccountSerializer accountSerializer)async{
    final ObjectId _objectId = ObjectId.parse(request.authorization.clientID);
    final DatabaseBridge _databaseBridge = DatabaseBridge(dbUrl: databaseUrl, collectionName: 'companies');
    final Map<String, dynamic> _compay = await _databaseBridge.findOneBy(where.id(_objectId));
    final ConsumerAccountSerializer _account = ConsumerAccountSerializer();
    final AccountModel _accountModel = AccountModel(
      companyCode: _compay['code'].toString(),
      identifier: _account.identifier,
      identifierType: _account.getIdentifierType,
      username: _account.username,
      password: _account.password,
      phoneNo: _account.phoneNo,
      email: _account.email,
      accountType: AccountType.consumer,
    );
    return Response.ok(await _accountModel.save());
  }
}
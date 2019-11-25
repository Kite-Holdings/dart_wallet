import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/accounts/account_model.dart';
import 'package:e_pay_gateway/serializers/accounts/account_serializer.dart';
import 'package:e_pay_gateway/utils/database_bridge.dart';

class AccountController extends ResourceController{
  @Operation.get()
  Future<Response> getAccountDetails () async {
    final AccountModel _accountModel = AccountModel();
    final Map<String, dynamic> _account = await _accountModel.findById(request.authorization.clientID);
    return Response.ok(_account);
  }
  
  @Operation.put()
  Future<Response> updateAccountDetails (@Bind.body() AccountSerializer _accountSerializer) async {
    final ObjectId _objectId = ObjectId.parse(request.authorization.clientID);
    // TODO: update acc
    return Response.ok({'': ''});
  }

}
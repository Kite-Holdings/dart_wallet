import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/token_model.dart';

class AccountsLoginController extends ResourceController{
  @Operation.post()
  Future<Response> getToken()async{
    final TokenModel _tokenModel = TokenModel();
    
    return Response.ok(await _tokenModel.getToken(owner: 'wallet/accounts/${request.authorization.clientID}'));
  }

}
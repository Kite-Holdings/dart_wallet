import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/wallet_wallet.dart';

class WalletWalletController extends ResourceController{
  @Operation.post()
  Future<Response> transact(@Bind.body() WalletToWallet walletWalletSerializer)async{
    final Map<String, dynamic> _res = await walletWalletSerializer.performTransaction( companyCode: request.authorization.clientID);
    if(_res['statusCode'] == 0){
      return Response.ok(_res);
    } else{
      return Response.badRequest(body: _res);
    }
    
  }
}

import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/wallet_wallet.dart';

class WalletWalletController extends ResourceController{
  @Operation.post()
  Future<Response> createUser(@Bind.body() WalletToWallet walletWalletSerializer)async{
    return Response.ok(await walletWalletSerializer.performTransaction());
  }
}

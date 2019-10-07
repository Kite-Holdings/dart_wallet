import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/wallet/wallet_paybill.dart';

class WalletMpesaPaybillController extends ResourceController{
  @Operation.post()
  Future<Response> createUser(@Bind.body() WalletToPaybill walletPaybillSerializer)async{
    return Response.ok(await walletPaybillSerializer.performTransaction());
  }
}

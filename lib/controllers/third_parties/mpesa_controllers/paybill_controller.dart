import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:aqueduct/aqueduct.dart';
import 'package:e_pay_gateway/serializers/mpesa/wallet_paybill.dart';


class PaybillController extends ResourceController{
  @Operation.post()
  Future<Response> createUser(@Bind.body() WalletToPaybill walletPaybillSerializer)async{
    return Response.ok(await walletPaybillSerializer.performTransaction());
  }
}

import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:aqueduct/aqueduct.dart';
import 'package:e_pay_gateway/serializers/mpesa/wallet_phone.dart';


class TransferPhoneController extends ResourceController{
  @Operation.post()
  Future<Response> createUser(@Bind.body() WalletToPhoneNo walletPhoneSerializer)async{
    return Response.ok(await walletPhoneSerializer.performTransaction());
  }
}

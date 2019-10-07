import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/wallet/wallet_phone.dart';

class WalletMpesaPhoneNoController extends ResourceController{
  @Operation.post()
  Future<Response> createUser(@Bind.body() WalletToPhoneNo walletPHoneNoSerializer)async{
    return Response.ok(await walletPHoneNoSerializer.performTransaction());
  }
}


import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/accounts/merchant_account_serializer.dart';

class MerchantAccountController extends ResourceController{

  @Operation.get()
  Future<Response> getAll()async{
    final MerchantAccountSerializer accounts = MerchantAccountSerializer();
    final List<Map<String, dynamic>> _accountsList = await accounts.getAll();

    return Response.ok(_accountsList);
  }

  @Operation.get('accountId')
  Future<Response> getOne(@Bind.path("accountId") String accountId)async{
    final MerchantAccountSerializer accounts = MerchantAccountSerializer();
    final Map<String, dynamic> _account = await accounts.findBykraPin(accountId);
    return Response.ok(_account);
  }

  @Operation.post()
  Future<Response> createUser(@Bind.body() MerchantAccountSerializer accountSerializer)async{
    return Response.ok(await accountSerializer.save());
  }


}
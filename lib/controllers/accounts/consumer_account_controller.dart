
import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/accounts/consumer_account_serializer.dart';

class ConsumerAccountController extends ResourceController{

  @Operation.get()
  Future<Response> getAll()async{
    final ConsumerAccountSerializer accounts = ConsumerAccountSerializer();
    final List<Map<String, dynamic>> _accountsList = await accounts.getAll();

    return Response.ok(_accountsList);
  }

  @Operation.get('accountId')
  Future<Response> getOne(@Bind.path("accountId") String accountId)async{
    final ConsumerAccountSerializer accounts = ConsumerAccountSerializer();
    final Map<String, dynamic> _account = await accounts.findByIdentifier(accountId);
    return Response.ok(_account);
  }

  @Operation.post()
  Future<Response> createUser(@Bind.body() ConsumerAccountSerializer accountSerializer)async{
    return Response.ok(await accountSerializer.save());
  }


}
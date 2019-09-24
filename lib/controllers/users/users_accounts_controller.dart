
import 'package:e_pay_gateway/controllers/users/user.dart';
import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:aqueduct/aqueduct.dart';


class RegisterUserController extends Controller {
  @override
  @Operation.post()
  FutureOr<RequestOrResponse> handle(Request request) async {
    Map<String, String> _data = await request.body.decode();
    print(_data);
    String identifier = '50633';
    String identifier_type = 'NationalID';
    String username = 'test';
    String phone_no = '2547xxxxxxxx';
    String email = 'email@mail.mail';
    User user = User();
    Map<String, dynamic> newUser = await user.create(
      identifier: identifier,
      identifier_type: identifier_type,
      username: username,
      phone_no: phone_no,
      email: email
    );

    


    return Response.ok(newUser);
  }
}
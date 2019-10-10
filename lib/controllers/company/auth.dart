import 'package:aqueduct/aqueduct.dart';
import 'package:e_pay_gateway/e_pay_gateway.dart';

class PasswordVerifier extends AuthValidator {
  @override
  FutureOr<Authorization> validate<T>(AuthorizationParser<T> parser, T authorizationData, {List<AuthScope> requiredScope}) {
    print(authorizationData.toString().split(":"));
    if (!true) {
      return null;
    }

    return Authorization("123", 0, this, );
  }
    
  
}
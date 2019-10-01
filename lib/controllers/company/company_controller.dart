import 'package:e_pay_gateway/controllers/utils/counter_intrement.dart';
import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:aqueduct/aqueduct.dart';
import 'package:mongo_dart/mongo_dart.dart';




class RegisterCompanyController extends Controller {
  String stringifyCount(int count){
    String c = count.toString();
    for(int i = c.length; i< 3; i++){
      c = '0$c';
    }
    return c;
  }

  @override
  FutureOr<RequestOrResponse> handle(Request request) async{
    final Db db =  Db("mongodb://localhost:27017/wallet");
    final int c = await companyCounter ('company_counter');
    final String _code = stringifyCount(c);
    const String _name = 'Kite Holdings';

    await db.open();
    final DbCollection company = db.collection('company');
    await company.insert({
      'Name': _name,
      'code': _code,
    });
    await db.close();
    return Response.ok({'state': 'Success', 'code': '0'});
  }
}
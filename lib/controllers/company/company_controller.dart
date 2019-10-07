import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/serializers/company/company_serializer.dart';

class CompaniesController extends ResourceController{
  @Operation.get()
  Future<Response> getAll()async{
    final CompanySerializer companies = CompanySerializer();
    final List<Map<String, dynamic>> _companiesList = await companies.getAll();

    return Response.ok(_companiesList);
  }

  @Operation.get('companyId')
  Future<Response> getOne(@Bind.path("companyId") String companyId)async{
    final CompanySerializer companies = CompanySerializer();
    final Map<String, dynamic> _company = await companies.findById(companyId);
    return Response.ok(_company);
  }

  @Operation.post()
  Future<Response> createUser(@Bind.body() CompanySerializer companySerializer)async{
    return Response.ok(await companySerializer.save());
  }


}
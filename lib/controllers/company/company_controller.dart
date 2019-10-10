import 'package:e_pay_gateway/e_pay_gateway.dart';
import 'package:e_pay_gateway/models.dart/company_model.dart';
import 'package:e_pay_gateway/serializers/company/company_serializer.dart';

class CompaniesController extends ResourceController{
  @Operation.get()
  Future<Response> getAll()async{
    final CompanyModel companies = CompanyModel();
    final Map<String, dynamic> _res = await companies.getAll();

    if (_res['status'] == '0'){
      return Response.ok(_res['data']);
    }
    else {
      return Response.serverError();
    }

    
  }

  @Operation.get('companyId')
  Future<Response> getOne(@Bind.path("companyId") String companyId)async{
    final CompanyModel companies = CompanyModel();
    final Map<String, dynamic> _res = await companies.findByCode(companyId);

    if (_res['status'] == '0'){
      return Response.ok(_res['data']);
    }
    else {
      return Response.serverError();
    }
  }

  @Operation.post()
  Future<Response> createUser(@Bind.body() CompanySerializer _companySerializer)async{
    final CompanyModel companyModel = CompanyModel(name: _companySerializer.name);

    final Map<String, dynamic> _res = await companyModel.create();
    if (_res['status'] == '0'){
      return Response.ok(_res['data']);
    }
    else {
      return Response.serverError();
    }
  }


}

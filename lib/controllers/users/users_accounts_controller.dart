
// import 'package:e_pay_gateway/e_pay_gateway.dart';
// import 'package:aqueduct/aqueduct.dart';
// import 'package:e_pay_gateway/serializers/user_serializer.dart';


// class UsersController extends ResourceController{

//   @Operation.get()
//   Future<Response> getAll()async{
//     final UserSerializer users = UserSerializer();
//     final List<Map<String, dynamic>> _usersList = await users.getAll();

//     return Response.ok(_usersList);
//   }

//   @Operation.get('userId')
//   Future<Response> getOne()async{
//     final UserSerializer users = UserSerializer();
//     final Map<String, dynamic> _user = await users.findByIdentifier('1234567');
//     return Response.ok(_user);
//   }

//   @Operation.post()
//   Future<Response> createUser(@Bind.body() UserSerializer userSerializer)async{
//     return Response.ok(await userSerializer.save());
//   }


// }
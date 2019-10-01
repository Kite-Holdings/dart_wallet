import 'package:mongo_dart/mongo_dart.dart';

Future<int> companyCounter (String documentLabel)async {
  final Db db =  Db("mongodb://localhost:27017/wallet");
  await db.open();
  final DbCollection counterCollection = db.collection('counters');

  final doc = await counterCollection.findOne({'label': documentLabel});
  if(doc == null){
    await counterCollection.insert({
      'label': documentLabel,
      'value': 0,
    });
  }


  final Map<String, dynamic> newc =await counterCollection.findAndModify(
    query: {"label": documentLabel},
    update: {"\$inc":{'value':1}},
    returnNew: true,

  );
  await db.close();
  final value = newc['value'].toString();
  return int.parse(value);
}
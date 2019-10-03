String stringifyCount(int count){
  String c = count.toString();
  for(int i = c.length; i< 9; i++){
    c = '0' + c;
  }
  return c;
}
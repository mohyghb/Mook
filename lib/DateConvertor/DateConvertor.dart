class DateConvertor{

  ///these functions work together to make a DateTime into a json
  ///and then retrieve the information from it

  static String showDateTime(DateTime dateTime)
  {
    String dt_str = dateTime.toString();
    List<String> sep_dt_str = dt_str.split(" ");
    return sep_dt_str.first;
  }


  static DateTime getDateTimeFromString(String data)
  {
    List<String> split = data.split("-");
    return new DateTime(int.parse(split[0]),int.parse(split[1]),int.parse(split[2]),23,59,59);
  }


}
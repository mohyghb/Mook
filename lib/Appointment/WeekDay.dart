

import 'package:simin_saloon/Helpers.dart';


class WeekDay {

  String name;
  int index;
  bool notProvided;

  WeekDay(this.name, this.index, this.notProvided);


  toJson()
  {
    return {
      Helpers.NAME  :this.name,
      Helpers.INDEX : this.index,
      Helpers.NOT_PROVIDED : this.notProvided
    };
  }

  toWeekDay(dynamic data)
  {
    this.name = data[Helpers.NAME];
    this.index = data[Helpers.INDEX];
    this.notProvided = data[Helpers.NOT_PROVIDED];
  }

}
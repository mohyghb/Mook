import 'package:flutter/material.dart';
import 'package:simin_saloon/Helpers.dart';
import 'package:simin_saloon/Appointment/WeekDay.dart';

class TypeOfHairJob{

  String _name, _description, _gender,_id;
  String _price,_timeItTakes; // change them to double when you wanna use them
  bool _deleted;
  String _url;


  List<WeekDay> _notProvided;


  bool isInList;




  TypeOfHairJob(
      String n,
      String d,
      String g,
      String p,
      String t,
  )
  {
    this._name = n;
    this._description = d;
    this._price = p;
    this._timeItTakes = t;
    this._gender = g;
    this._deleted = false;
    this.isInList = true;
    this._id = Helpers.generateRandomId();
    this._url = "";
    this._notProvided = new List<WeekDay>();
  }


  bool get deleted => _deleted;

  set deleted(bool value) {
    _deleted = value;
  }

  List<WeekDay> get notProvided => _notProvided;

  set notProvided(List<WeekDay> value) {
    _notProvided = value;
  }


  get id => _id;

  set id(value) {
    _id = value;
  }

  String get price => _price;

  set price(String value) {
    _price = value;
  }

  String get description => _description;

  set description(value) {
    _description = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  get timeItTakes => _timeItTakes;

  set timeItTakes(value) {
    _timeItTakes = value;
  }


  String get gender => _gender;

  set gender(value) {
    _gender = value;
  }

  //delete this hair job by setting the deleted to true;
  void delete()
  {
    this._deleted = true;
  }

  //returns deleted
  bool isDeleted()
  {
    return this._deleted;
  }

  void setDeleted(bool b){
    this._deleted = b;
  }

  Widget getWidgetForMenuItem(Color c) {
    return new Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(child: getNameWidget(c)),
          Expanded(child: getMoneyWidget(c)),
          Expanded(child: getTimeWidget(c)),
        ],
      ),
    );

  }

  Widget getTypeOfHairJobWidget(BuildContext context,Color c)
  {
    return new Column(
        children: <Widget>[
          getNameWidget(c),
          new SizedBox(height: 3.2,),
          getDesWidget(c),
          new SizedBox(height: 10.0,),
          getBottomInfoWidget(c),
          new SizedBox(height: 10.0,),
          showImage(context,c),
        ],
      );
  }

  Widget showImage(BuildContext context,Color c)
  {
    if(this._url.isEmpty){
      return SizedBox();
//      var logo = new AssetImage("assets/logo_simin.png");
//      return Padding(
//        padding: const EdgeInsets.all(8.0),
//        child: new Image(image: logo,color: c,),
//      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
          borderRadius: new BorderRadius.circular(8.0),
          child: Image(image: new NetworkImage(this._url) ,)
      ),
    );
//    return Card(
//      elevation: 0.0,
//      color: Theme.of(context).primaryColor,
//      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//        child: Padding(
//          padding: const EdgeInsets.all(8.0),
//          child: Image(image: new NetworkImage(this._url) ,),
//        )
//    );
  }




  String get url => _url;

  set url(String value) {
    _url = value;
  }

  Widget getNameWidget(Color c)
  {
    if(this._name.isEmpty){
      return Helpers.EMPTY_BOX;
    }
    else{
      return Padding(
        padding: const EdgeInsets.only(left:8.0,right:8.0,top: 8.0),
        child: new Text(name,
          textAlign: TextAlign.center,
          style: new TextStyle(
            color:  c,
              fontSize: Helpers.TITLE_FONT_SIZE,
              fontWeight: FontWeight.bold,

          ),),
      );
    }

  }

  Widget getDesWidget(Color c)
  {
    if(this._description.isEmpty){
      return Helpers.EMPTY_BOX;
    }
    else{
      return Padding(
        padding: const EdgeInsets.only(left:8.0,right:8.0),
        child: new Text(description,
            textAlign: TextAlign.center,
            style: new TextStyle(
              color: c,
              fontSize: Helpers.DESCRIPTION_FONT_SIZE,
            )),
      );
    }

  }

  Widget getMoneyWidget(Color c)
  {
    return Row(
      mainAxisAlignment:MainAxisAlignment.center,
      children: <Widget>[
        new Icon(Icons.attach_money,color: c,),
        new Text("$price",textAlign: TextAlign.center,style: TextStyle(color: c),),
      ],
    );
  }

  Widget getTimeWidget(Color c)
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Icon(Icons.access_time,color: c,),
        new Text("$timeItTakes",textAlign: TextAlign.center,style: TextStyle(color: c),),
      ],
    );
  }

  Widget getGenderWidget(Color c)
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Icon(Icons.perm_identity,color: c,),
        new Text("$_gender",textAlign: TextAlign.center,style: TextStyle(color: c),),
      ],
    );
  }


  //returns the time it takes and price of the job in a row
  Widget getBottomInfoWidget(Color c)
  {
    return new Row(
      children: <Widget>[
        Expanded(child: getMoneyWidget(c)),
        Expanded(child: getTimeWidget(c)),
        Expanded(child: getGenderWidget(c)),
      ],
    );
  }

  toJson()
  {
    return {
      Helpers.NAME:this._name,
      Helpers.DESCRIPTION:this._description,
      Helpers.GENDER :this._gender,
      Helpers.TIME_IT_TAKES: this._timeItTakes,
      Helpers.PRICE: this._price,
      Helpers.DELETED: this._deleted,
      Helpers.ID: this._id,
      Helpers.URL: this._url,
      Helpers.NOT_PROVIDED : this.weekDayJson(this.notProvided)
    };
  }


  toTypeOfHairJob(dynamic data)
  {
    this.name = data[Helpers.NAME];
    this._description = data[Helpers.DESCRIPTION];
    this._gender = data[Helpers.GENDER];
    this._timeItTakes = data[Helpers.TIME_IT_TAKES];
    this._price = data[Helpers.PRICE];
    this._deleted = data[Helpers.DELETED];
    this._id = data[Helpers.ID];
    this._url = data[Helpers.URL];
    this._notProvided = dataToWeekDay(data[Helpers.NOT_PROVIDED]);
  }



  List<WeekDay> dataToWeekDay(dynamic map)
  {
    List<WeekDay> appointments = new List<WeekDay>();

    for(int i = 0;i<10;i++){
      try{
        dynamic value = map[i];
        if(value!=null){
          WeekDay weekDay = new WeekDay(null, null, null);
          weekDay.toWeekDay(value);
          appointments.add(weekDay);
        }
        else{
          break;
        }
      }catch(e){
        break;
      }
    }


    return appointments;
  }


  weekDayJson(List<WeekDay> weekDay)
  {
    Map<String, Map> map = new Map();
    if(weekDay!=null){
      for(int i =0;i<weekDay.length;i++){
        map.putIfAbsent(i.toString(), ()=>weekDay[i].toJson());
      }
    }
    return map;
  }


  String isNotProvided(DateTime d)
  {
    if(this.notProvided[d.weekday-1].notProvided){
      return this.notProvided[d.weekday-1].name;
    }
    return "";
  }



}
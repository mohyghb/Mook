import 'package:simin_saloon/Helpers.dart';
import 'package:flutter/material.dart';

class News{

  //description might contain links
  String _title,_description,_url,_id;
  bool _deleted;

  //date time on which the news was created
  DateTime _dateTime;

  bool isInList;

  News(this._title,this._description)
  {
    this._deleted = false;
    this._url = "";
    this.isInList = true;
    this._id = Helpers.generateRandomId();
  }

  DateTime get dateTime => _dateTime;

  set dateTime(DateTime value) {
    _dateTime = value;
  }

  bool get deleted => _deleted;

  set deleted(bool value) {
    _deleted = value;
  }

  get id => _id;

  set id(value) {
    _id = value;
  }

  get url => _url;

  set url(value) {
    _url = value;
  }



  String get description => _description;

  set description(value) {
    _description = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  Widget showImage(BuildContext context,Color c)
  {
    if(this._url.isEmpty){
      var logo = new AssetImage("assets/logo_simin.png");
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Image(image: logo,color: c,),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
          borderRadius: new BorderRadius.circular(8.0),
          child: Image(image: new NetworkImage(this._url) ,)
      ),
    );

  }

  Widget getNewsWidget(BuildContext context,Color c)
  {
    return new Column(
        children: <Widget>[
          getNameWidget(c),
          new SizedBox(height: 3.2,),
          showImage(context,c),
          new SizedBox(height: 3.2,),
          getDesWidget(c),
          new SizedBox(height: 10.0,),
        ],
      );
  }


  Widget getNameWidget(Color c)
  {
    if(this.title.isEmpty){
      return Helpers.EMPTY_BOX;
    }
    else{
      return Padding(
        padding: const EdgeInsets.only(left:8.0,right:8.0,top: 8.0),
        child: new Text(title,
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
      return new Text(description,
          textAlign: TextAlign.center,
          style: new TextStyle(
            color: c,
            fontSize: Helpers.FONT_SIZE-2,
          ));
    }

  }



  toJson()
  {
    return {
      Helpers.NAME:this._title,
      Helpers.DESCRIPTION:this._description,
      Helpers.DELETED: this._deleted,
      Helpers.ID: this._id,
      Helpers.URL: this._url,
    };
  }


  toTypeOfHairJob(dynamic data)
  {
    this.title = data[Helpers.NAME];
    this._description = data[Helpers.DESCRIPTION];
    this._deleted = data[Helpers.DELETED];
    this._id = data[Helpers.ID];
    this._url = data[Helpers.URL];
  }





}
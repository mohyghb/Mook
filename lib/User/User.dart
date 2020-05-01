import 'package:flutter/material.dart';
import 'package:simin_saloon/Appointment/Appointment.dart';
import 'package:simin_saloon/Helpers.dart';
import 'package:simin_saloon/Encryption/Encrypt.dart';



class User
{
  static const USER = "User";
  static const VISITOR = "JUST_VISITING";

  String _name,_lastname,_phonenumber,_uid,_notificationToken;
  List<Appointment> _appointments;
  bool _deleted, _boss;
  Encrypt encrypt;
  String fullInfo;
  bool isInList;


  User(this._name,this._lastname,this._phonenumber,this._uid)
  {
    this._deleted = false;
    this._boss    = false;
    this._notificationToken = "";
    isInList = true;
    encrypt = new Encrypt();
  }

  bool isNotAVisitor()
  {
    return (this._uid.isNotEmpty&&this._uid!=VISITOR);
  }

  String enc(String text)
  {
    return this.encrypt.encrypt(text);
  }

  String dec(String text)
  {
    String decText = this.encrypt.decrypt(text);
    if(decText.endsWith(" ")){
      return decText.substring(0,decText.length-1);
    }
    return decText;
  }

  String fullName()
  {
    return this.name + " " + this.lastname;
  }

  String getJsonFullNameAndPn()
  {
    return enc("${this.name}\n${this.lastname}\n${this.phonenumber}");
  }

  void setJsonFullNameAndPn(String text)
  {
    this.fullInfo = dec(text);
  }


  get notificationToken => _notificationToken;

  set notificationToken(value) {
    _notificationToken = value;
  }

  get boss => _boss;

  set boss(value) {
    _boss = value;
  }

  bool get deleted => _deleted;

  set deleted(bool value) {
    _deleted = value;
  }

  get phonenumber => _phonenumber;

  set phonenumber(value) {
    _phonenumber = value;
  }

  List<Appointment> get appointments => _appointments;

  set appointments(List<Appointment> value) {
    _appointments = value;
  }

  String get lastname => _lastname;

  set lastname(value) {
    _lastname = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String getUID (){
    return this._uid;
  }

  get uid => _uid;

  set uid(value) {
    _uid = value;
  }

  toJson()
  {
    return{
      Helpers.NAME               : enc(_name),
      Helpers.LAST_NAME          : enc(_lastname),
      Helpers.PHONE_NUMBER       : enc(_phonenumber),
      Helpers.UID                : _uid,
      Helpers.DELETED            : _deleted,
      Helpers.APPOINTMENTS       : appointmentJson(),
      Helpers.NOTIFICATION_TOKEN : enc(_notificationToken),
    };
  }


  toUser(dynamic data)
  {
    try{
      this.name = dec(data[Helpers.NAME]).trim();
      this.lastname = dec(data[Helpers.LAST_NAME]).trim();
      this.phonenumber = dec(data[Helpers.PHONE_NUMBER]).trim();
      this.uid = data[Helpers.UID];
      this._deleted = data[Helpers.DELETED];
      this._notificationToken = dec(data[Helpers.NOTIFICATION_TOKEN]);
    }catch(e){

    }
    try{
      this._appointments = dataToAppointment(data[Helpers.APPOINTMENTS]);
    }
    catch(e){
      this.appointments = new List<Appointment>();
    }

  }



  appointmentJson()
  {
    Map<String, Map> map = new Map();
    if(this.appointments!=null){
      for(int i =0;i<this._appointments.length;i++){
        map.putIfAbsent(i.toString(), ()=>this._appointments[i].toJsonForUser());
      }
    }
    return map;
  }

  List<Appointment> dataToAppointment(dynamic map)
  {
    List<Appointment> appointments = new List<Appointment>();


    for(int i = 0;i<Helpers.MAX_SIZE_APPOINTMENTS;i++){
      try{
        dynamic value = map[i];
        if(value!=null){
          Appointment appointment = new Appointment(null, null, null, null);
          appointment.toAppointmentForUser(value);
          if(!appointment.deleted){
            appointments.add(appointment);
          }

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





  Widget getBossWidget(Color c)
  {
    return new Column(
        children: <Widget>[
          makeText(this.fullName(), c, Icons.supervisor_account),
          makeText(Helpers.makeFancy(this.phonenumber),c,Icons.call),
          makeText("#Appointments: "+this.appointments.length.toString(), c, Icons.format_list_bulleted)
        ],
    );
  }


  Widget userWidget(Color c)
  {
    return  new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(child: makeText(this.fullName(), c, Icons.supervisor_account)),
        Expanded(child: makeText(Helpers.makeFancy(this.phonenumber),c,Icons.call)),
      ],
    );
  }


  Widget showAppointments(bool condense,Color c)
  {
    int size = appointments.length;
    if(size!=0){
      return new ListView.builder(
          itemCount: size,
          itemBuilder: (BuildContext context, int index){
            return  appointments[index].getAppointmentWidget_NO_DELETE(context,condense,c,false);
          });
    }else{
      return Center(child: makeTextCenter("No appointments found",c, Icons.hourglass_empty));
    }

  }


  Widget makeText(String text,Color c, IconData id)
  {
    return Row(
      children: <Widget>[
        SizedBox(width: 4.0,),
        new Icon(id,color: c,),
        SizedBox(width: 4.0,),
        new Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: c
          ),
        ),
      ],
    );
  }


  Widget makeTextCenter(String text,Color c, IconData id)
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(width: 4.0,),
        new Icon(id,color: c,),
        SizedBox(width: 4.0,),
        new Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: c,
            fontSize: 20
          ),
        ),
      ],
    );
  }





}
import 'dart:io';

import 'package:simin_saloon/Appointment/TypeOfHairJob.dart';
import 'package:flutter/material.dart';
import 'package:simin_saloon/Helpers.dart';
import 'package:simin_saloon/DaySetting/Time.dart';
import 'package:simin_saloon/User/User.dart';
import 'package:simin_saloon/Buttons/Fancy.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:simin_saloon/DaySetting/Day.dart';
import 'package:simin_saloon/LoggedInUser.dart';

import 'package:simin_saloon/CreateAppointments.dart';

class Appointment
{
  DateTime _dateTime;
  TypeOfHairJob _typeOfHairJob;
  Time _time;
  bool _deleted;
  String _id;
  User _user;


  Appointment(DateTime dt, TypeOfHairJob thj, Time t,User u)
  {
    this._dateTime = dt;
    this._typeOfHairJob = thj;
    this._deleted = false;
    this._time = t;
    this._user = u;
    this._id = Helpers.generateRandomId();
  }


  String get id => _id;

  set id(String value) {
    _id = value;
  }



  String showDateTime()
  {
    String dt_str = this._dateTime.toString();
    List<String> sep_dt_str = dt_str.split(" ");
    return sep_dt_str.first;
  }

  Time getTime()
  {
    return this._time;
  }

  set time(Time value) {
    _time = value;
  }

  TypeOfHairJob get typeOfHairJob => _typeOfHairJob;

  set typeOfHairJob(TypeOfHairJob value) {
    _typeOfHairJob = value;
  }

  DateTime get dateTime => _dateTime;

  set dateTime(DateTime value) {
    _dateTime = value;
  }


  User get user => _user;

  set user(User value) {
    _user = value;
  }

  Widget getAppointmentWidget(BuildContext context,DatabaseReference ref, bool showDelete,Color c)
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Card(
        elevation: 3.0,
        color: Helpers.themeColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            children: <Widget>[
              getTitle(context,c),
              SizedBox(height: 10.0,),
              getDateAndTime(c),
              getDeleteButton(context,ref,showDelete)
            ],
          ),
        ),
      ),
    );
  }

  Widget getAppointmentWidget_NO_DELETE(BuildContext context, bool condense,Color c,bool showMove)
  {
    if(condense){
      return  new Card(
        color: getCardColor(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: new Column(
          children: <Widget>[
            SizedBox(height: 10.0,),
            getCancelled(c),
            SizedBox(height: 5.0,),
            makeText("Type of Hair Job: "+typeOfHairJob.name,c,Icons.gesture),
            SizedBox(height: 5.0,),
            makeText("At: "+_time.showTime(),c,Icons.access_time),
            SizedBox(height: 5.0,),
            getUserIfNotNull(c),
            getMoveAppointmentButton(context,showMove)
          ],
        ),
      );
    }
    return new Card(
      color: getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: new Column(
        children: <Widget>[
          SizedBox(height: 10.0,),
          getCancelled(c),
          this.typeOfHairJob.getTypeOfHairJobWidget(context, Colors.white),
          SizedBox(height: 5.0,),
          getDateAndTime(Colors.white),
          SizedBox(height: 10.0,),
          getUserIfNotNull(c),
          getMoveAppointmentButton(context,showMove)
        ],
      ),
    );
  }

  Widget getUserIfNotNull(Color c)
  {
    if(this.user!=null){
      return makeText("For: "+user.fullName(),c,Icons.supervisor_account);
    }
    return SizedBox();
  }


  Widget makeText(String text,Color c, IconData id)
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
            color: c
          ),
        ),
      ],
    );
  }



  Widget getMoveAppointmentButton(BuildContext context,bool showMove)
  {
    if(!this._deleted&&showMove){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Fancy(
          text: "Move",
          radius: 100,
          color: Colors.white,
          elevation: 0.0,
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => (CreateAppointment(changeThisAppointment: this,))));
          },
        ),
      );
    }else{
      return SizedBox(height: 10.0,);
    }

  }


  Widget getCancelled(Color c)
  {
    if(this.deleted){
      return new Text("Cancelled",textAlign: TextAlign.center,style: TextStyle(color: c),);
    }
    return new Text("Still in session",textAlign: TextAlign.center,style: TextStyle(color: c),);
  }

  Color getCardColor()
  {
    if(this.deleted){
      return Colors.red;
    }else{
      return Colors.green;
    }
  }

  Widget getDeleteButton(BuildContext context, DatabaseReference ref,bool showDelete)
  {
    if(showDelete){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Fancy(
          text: "Cancel",
          iconData: Icons.cancel,
          elevation: 0.0,
          spaceBetweenTI: 5.0,
          color: Colors.white,
          textColor: Colors.black,
          radius: 100.0,
          onTap: ()=> deleteThisAppointmentDialog(context, ref),
        ),
      );
    }else{
      return new SizedBox(height: 10.0,);
    }

  }

  deleteThisAppointmentDialog (BuildContext mcontext, DatabaseReference ref)
  {
    return showDialog<void>(
      context:  mcontext,
      builder: (BuildContext context){
        return new AlertDialog(
          title: new Text("Cancel this appointment",textAlign: TextAlign.center,),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text("Are you sure you want to cancel your appointment at ${_time.showTime()} on ${this.showDateTime()}?",textAlign: TextAlign.center,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Fancy(
                        radius: 100.0,
                        text: "No",
                        textColor: Colors.white,
                        color: Helpers.acceptColor,
                        iconData: Icons.close,
                        onTap: ()=>Navigator.pop(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Fancy(
                        text: "Yes",
                        textColor: Colors.white,
                        color: Helpers.rejectColor,
                        iconData: Icons.delete,
                        radius: 100.0,
                        onTap: ()=> deleteThisAppointment(mcontext,Helpers.SUCCESSFUL_DELETE,Helpers.FAILED_DELETE,context: context)
                        ,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  deleteThisAppointment(BuildContext mainContext,String onSuccess,String onFail,{BuildContext context}) async
  {
    bool connected = await checkInternet();

    if(connected){
      // delete from the dates
      deleteAppointmentFromDataBase(this.id,getDataBaseReference());
      // delete it for user
      deleteAppointmentFromDataBase(this.id,getDataBaseReferenceForUser());

      //updateUserAppointments(ref);
      //update the changes for user and firebase

      if(context!=null){
        Navigator.pop(context);
        Scaffold.of(mainContext).showSnackBar(
            new SnackBar(
                duration: Duration(seconds: 4),
                backgroundColor: Helpers.acceptColor,
                content: new Text(onSuccess,textAlign: TextAlign.center,style: new TextStyle(color: Colors.white),)
            )
        );
      }

    }
    else{
      if(context!=null){
        Navigator.pop(context);
        Scaffold.of(mainContext).showSnackBar(
            new SnackBar(
                duration: Duration(seconds: 6),
                backgroundColor: Helpers.rejectColor,
                content: new Text(onFail,textAlign: TextAlign.center,style: new TextStyle(color: Colors.white),)
            )
        );
      }

    }
  }

  DatabaseReference getDataBaseReference()
  {
    return FirebaseDatabase.instance.reference().
    child(Helpers.DATE).
    child(this._dateTime.year.toString()).
    child(this._dateTime.month.toString()).
    child(this._dateTime.day.toString()).
    child(Helpers.APPOINTMENTS);
  }

  DatabaseReference getDataBaseReferenceForUser()
  {
    if(this.user!=null){
      return FirebaseDatabase.instance.reference().
      child(Helpers.USERS).
      child(this.user.uid).
      child(Helpers.APPOINTMENTS);
    }else{
      return FirebaseDatabase.instance.reference().
      child(Helpers.USERS).
      child(LoggedInUser.loggedInUser.uid).
      child(Helpers.APPOINTMENTS);
    }
  }

   deleteAppointmentFromDataBase(String id, DatabaseReference ref) async
  {
    List<Appointment> appointments = new List<Appointment>();
    ref.once().then((DataSnapshot snap){
      if(snap.value!=null){
        appointments = Day.dataToAppointment(snap.value);
      }

      for(int i = 0;i<appointments.length;i++){
        Appointment appointment = appointments.elementAt(i);
        if(appointment.id.contains(this._id)){
          appointments.elementAt(i).deleted = true;
        }
      }

      ref.set(Day.appointmentJsonStatic(appointments)).catchError((e){
        print(e);
      });
    });
  }


   Future addAppointmentToUserDataBase(DatabaseReference ref,Appointment ap,Appointment delete,BuildContext context) async
  {
    List<Appointment> appointments = new List<Appointment>();
    ref.once().then((DataSnapshot snap){
      if(snap.value!=null){
        appointments = Day.dataToAppointment(snap.value);
      }
      appointments = insertSort(appointments, ap);

      ref.set(Day.appointmentJsonStatic(appointments)).catchError((e){
        print(e);
      });
      if(delete!=null){
        delete.deleteThisAppointment(context,"Succes change","internet error");
      }

    });
  }

//  void deleteAppointmentForUser(String id)
//  {
//    for(int i = 0;i<LoggedInUser.loggedInUser.appointments.length;i++){
//      Appointment ap = LoggedInUser.loggedInUser.appointments[i];
//      if(ap.id.contains(id)){
//        LoggedInUser.loggedInUser.appointments[i].deleted = true;
//      }
//    }
//  }



  void updateUserAppointments(DatabaseReference ref)
  {
    ref.set(LoggedInUser.loggedInUser.appointmentJson());
  }


  Widget getTitle(BuildContext context,Color c)
  {
    return this.typeOfHairJob.getTypeOfHairJobWidget(context,c);
  }



  Widget getShowDate(Color c)
  {
    return Column(
      children: <Widget>[
        new Icon(Icons.date_range,color: c,),
        new Text(
            showDateTime(),
          style: TextStyle(color: c),
        ),
      ],
    );
  }

  Widget getDateAndTime(Color c)
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(child: getShowDate(c)),
        Expanded(child: this._time.getWidget(c))
      ],
    );
  }


  toJson()
  {
    return{
      Helpers.DATE_TIME              : showDateTime(),
      Helpers.TYPE_OF_HAIR_JOB       : _typeOfHairJob.toJson(),
      Helpers.DELETED                : _deleted,
      Time.TIME                      : _time.toJson(),
      Helpers.ID                     : _id,
      User.USER                      : user.enc(_user.uid)
    };
  }

  toJsonForUser()
  {
    return{
      Helpers.DATE_TIME              : showDateTime(),
      Helpers.TYPE_OF_HAIR_JOB       : _typeOfHairJob.toJson(),
      Helpers.DELETED                : _deleted,
      Time.TIME                      : _time.toJson(),
      Helpers.ID                     : _id,
    };
  }

  toAppointmentForUser(dynamic data)
  {
    this._dateTime = getDateTimeFromString(data[Helpers.DATE_TIME]);

    if(isOutDated()){
      this.deleted = true;
    }else{
      this._deleted = data[Helpers.DELETED];
      this._typeOfHairJob =  new TypeOfHairJob("", "", "", "", "");
      this._typeOfHairJob.toTypeOfHairJob(data[Helpers.TYPE_OF_HAIR_JOB]);
      this._time = new Time(0,0);
      _time.toTime(data[Time.TIME]);
      this._id = data[Helpers.ID];
    }



  }

  DateTime getDateTimeFromString(String data)
  {
    List<String> split = data.split("-");
    return new DateTime(int.parse(split[0]),int.parse(split[1]),int.parse(split[2]),23,59,59);
  }

  toAppointment(dynamic data)
  {
    this._dateTime = getDateTimeFromString(data[Helpers.DATE_TIME]);

    this._typeOfHairJob =  new TypeOfHairJob("", "", "", "", "");
    this._typeOfHairJob.toTypeOfHairJob(data[Helpers.TYPE_OF_HAIR_JOB]);

    this._deleted = data[Helpers.DELETED];
    this._time = new Time(0,0);
    _time.toTime(data[Time.TIME]);

    this._id = data[Helpers.ID];
    this._user = new User("", "", "", "");
    this._user.uid = this.user.dec(data[User.USER]).trim();

  }

  bool get deleted => _deleted;

  set deleted(bool value) {
    _deleted = value;
  }



  //returns true if this appointment is outdated
  bool isOutDated()
  {
    return this._dateTime.isBefore(DateTime.now());
  }



  checkInternet() async
  {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }




  // gets a list of appointment and produces a list with only appointments that have deleted = false;
  static List<Appointment> getOnlyInSessionAppointments(List<Appointment> aps)
  {
    List<Appointment> appointments = new List<Appointment>();
    for(int i =0;i<aps.length;i++){
      if(!aps[i].deleted){
        appointments.add(aps[i]);
      }
    }
    return appointments;
  }


  // does a insert sort while adding that appointment to the other one
  static List<Appointment> insertSort(List<Appointment> appointments,Appointment appointment)
  {
    List<Appointment> newAppointments = new List<Appointment>();
    bool stop = false;
    if(appointments.length==0){
      newAppointments.add(appointment);
      return newAppointments;
    }
    for(int i = 0;i<appointments.length;i++){
      if(stop){
        newAppointments.add(appointments[i]);
      }
      else if(i==appointments.length-1) {
        //last index
        if(appointments[i].dateTime.isBefore(appointment.dateTime)){
          newAppointments.add(appointments[i]);
          newAppointments.add(appointment);
        }else{
          newAppointments.add(appointment);
          newAppointments.add(appointments[i]);
        }


      }else{
        Appointment before = appointments[i];
        Appointment after = appointments[i+1];
        if(before.dateTime.isBefore(appointment.dateTime)&&after.dateTime.isAfter(appointment.dateTime)){
          stop = true;
          newAppointments.add(before);
          newAppointments.add(appointment);
        }
        else{
          newAppointments.add(before);
        }
      }
    }

    return newAppointments;
  }



  static List<Appointment> insertSortTime(List<Appointment> appointments,Appointment appointment)
  {
    List<Appointment> newAppointments = new List<Appointment>();
    bool stop = false;
    if(appointments.length==0){
      newAppointments.add(appointment);
      return newAppointments;
    }
    for(int i = 0;i<appointments.length;i++){
      if(stop){
        newAppointments.add(appointments[i]);
      }
      else if(i==appointments.length-1) {
        //last index
        if(appointments[i]._time.isBefore(appointment._time)){
          newAppointments.add(appointments[i]);
          newAppointments.add(appointment);
        }else{
          newAppointments.add(appointment);
          newAppointments.add(appointments[i]);
        }


      }else{
        Appointment before = appointments[i];
        Appointment after = appointments[i+1];
        if(before._time.isBefore(appointment._time)&&after._time.isAfter(appointment._time)){
          stop = true;
          newAppointments.add(before);
          newAppointments.add(appointment);
        }
        else{
          newAppointments.add(before);
        }
      }
    }

    return newAppointments;
  }



}
import 'package:firebase_database/firebase_database.dart';
import 'package:simin_saloon/Helpers.dart';
import 'package:simin_saloon/Appointment/Appointment.dart';
import 'package:simin_saloon/DaySetting/Day.dart';
import 'package:flutter/material.dart';
import 'package:simin_saloon/LoggedInUser.dart';
import 'package:simin_saloon/Buttons/Fancy.dart';
import 'package:simin_saloon/User/User.dart';

import 'package:simin_saloon/ReservedAppointments.dart';


class Time{

  static const TIME = "Time";


  double _startTime, _endTime;

  bool _showAccept;

  //only show to the boss with the details, what the jobs are etc...
  List<Appointment> _numberOfCollisions;
  List<Appointment> _negotiable;

  int state;
  int tap;
  int appointmentRef;

   Time(double st, double et)
  {
    this._startTime = st;
    this._endTime = et;
    this._negotiable = new List<Appointment>();
    this._numberOfCollisions = new List<Appointment>();
    this._showAccept = false;
    state = 0;
    this.tap = 0;
  }


  double difference()
  {
    return this.endTime-this.startTime;
  }

  bool get showAccept => _showAccept;

  set showAccept(bool value) {
    _showAccept = value;
  }






  String showTime()
  {
    return getReadableForm(this._startTime) + " - " + getReadableForm(this._endTime);
  }





  static List<Time> getListOfStartingTimes(double startTime, double endTime, double timeItTakes)
  {
    List<Time> listOfTimes = new List<Time>();

    if(timeItTakes<=Helpers.ROUND_LIMIT){
      for(double st = startTime ; st<=endTime; st+=Helpers.ROUND_LIMIT){
        if(st%100==60){
          st+=40;
        }
        double et = st+timeItTakes;
        while(et%100>=60){
          et+=40;
        }
        Time t = new Time(st, et);
        if(et<=endTime){
          listOfTimes.add(t);
        }
      }
    }else{
      //test this when you get home
      double formatAdder = 0;
      double ogTime = timeItTakes;
      if(timeItTakes<60){
        formatAdder = timeItTakes;
      }else{
        while(ogTime>=60){
          formatAdder+=100;
          ogTime-=60;
        }
        formatAdder+=ogTime;
      }

//      if(timeItTakes>=60){
//        formatAdder = (timeItTakes/60.0)*100;
//      }else{
//        formatAdder = timeItTakes;
//      }


//      if(formatAdder%100==50) {
//        formatAdder -= 20;
//      }
//      }else if(formatAdder%100 == 25){
//        formatAdder-=10;
//      }

      for(double st = startTime ; st<=endTime; st+=Helpers.ROUND_LIMIT){

        if(st%100==60){
          st+=40;
        }
        double et = st+formatAdder;
        while(et%100>=60){
          et+=40;
        }
        Time t = new Time(st, et);
        if(et<=endTime){
          listOfTimes.add(t);
        }
      }
    }

    /// there might be a combination problem like 64 minutes and other examples...

    return listOfTimes;
  }


  // takes two Times and determines whether they intersect one and each other
  // 0 indicates no collision
  // 1 indicates a  collision
  // 2 indicates a negotiable collision
  static int timeCoincide(Time t1, Time reservedTime)
  {
    if((t1._startTime==reservedTime._startTime)||(t1._endTime==reservedTime._endTime)){
      return 1;
    }
    else if((t1._startTime>reservedTime._startTime&&t1._startTime<reservedTime._endTime)|| (t1._endTime>reservedTime._startTime&&t1._endTime<reservedTime._endTime)){
     // logic
      if(isNegotiable(t1, reservedTime)){
        return 2;
      }
      return 1;
    }
    else if((reservedTime._startTime>t1._startTime&&reservedTime._startTime<t1._endTime)|| (reservedTime._endTime>t1._startTime&&reservedTime._endTime<t1._endTime)){
      // logic
      if(isNegotiable(t1, reservedTime)){
        return 2;
      }
      return 1;
    }
    else{
      return 0;
    }
  }

  //logic
  //our logic produces true if the resereved time is negotiable
  static bool isNegotiable(Time t, Time reserved)
  {
    double tDifference = t.difference();
    double reservedDifference = reserved.difference();

    if(tDifference>=reservedDifference){
      return false;
    }else if(tDifference<reservedDifference){
      double ratio = tDifference/reservedDifference;
      if(ratio<=Helpers.OK_RATIO){
        return true;
      }else{
        return false;
      }
    }
    return false;
  }


  // produces a list of time where all the availabe times are in there
  static List<Time> getAvailableTimes(double startTime, double endTime, double timeItTakes, List<Appointment> aps)
  {
    List<Time> allTimes = getListOfStartingTimes(startTime, endTime, timeItTakes);
    List<Time> reservedTimes = getReservedTimes(aps);
    List<Time> availableTimes = new List<Time>();

    for(int i = 0;i<allTimes.length;i++){

      Time t1 = allTimes[i];
      for(int j = 0;j<reservedTimes.length;j++){
        Time reservedTime = reservedTimes[j];
        int collisionNumber = timeCoincide(t1, reservedTime);
        switch(collisionNumber){
          case 0:
            //not doing anything!!!
            break;
          case 1:
            //collisions
            t1._numberOfCollisions.add(aps[reservedTime.appointmentRef]);
            break;
          case 2:
            //negotiable
            t1._negotiable.add(aps[reservedTime.appointmentRef]);
            break;
        }
      }
      t1.setState();
      availableTimes.add(allTimes[i]);
    }
    return availableTimes;
  }

  void setState()
  {
    int numberOfCollisions = this._numberOfCollisions.length;
    int _negotiable = this._negotiable.length;

    if(numberOfCollisions==0&&_negotiable==0){
      this.state = 0;
    }
    else if(numberOfCollisions==0&&_negotiable>0){
      this.state = 2;
    }else if(numberOfCollisions>0&&_negotiable==0){
      this.state = 1;
    }
    else if(numberOfCollisions>_negotiable){
      this.state = 1;
    }else if(_negotiable>numberOfCollisions){
      this.state = 2;
    }else if(_negotiable==numberOfCollisions){
      this.state = 1;
    }else{
      this.state = 3;
    }
  }


  //produce a list of time from a list of appointment
  // if they are not deleted
  static List<Time> getReservedTimes(List<Appointment> aps)
  {
    List<Time> rTimes = new List<Time>();
    for(int i = 0;i<aps.length;i++){
      Appointment ap = aps.elementAt(i);
      if(ap.deleted==false){
        Time time = ap.getTime();
        time.appointmentRef = i;
        rTimes.add(time);
      }
    }

    return rTimes;
  }




  //takes a list of time and just produce times
  static List<String> readTimes(Day day,double timeItTakes)
  {
    List<String> los  = new List<String>();
    List<Time> times = getAvailableTimes(day.workingHours._startTime, day.workingHours._endTime, timeItTakes, day.appointments);
    for(int i = 0;i<times.length;i++){
      los.add(times[i].showTime());
    }
    return los;
  }

  static List<Time> getAvailableAppointmentTimes(Day day,double timeItTakes)
  {
    return getAvailableTimes(day.workingHours._startTime, day.workingHours._endTime, timeItTakes, day.appointments);
  }

  String getReadableFormStartTime()
  {
    return getReadableForm(this.startTime);
  }

  String getReadableFormEndTime()
  {
    return getReadableForm(this.endTime);
  }

  // takes a time in and produce a readable human form
  static String getReadableForm(double number)
  {
    double d = number/100;
    if(number<1000){
      String time =  d.toStringAsPrecision(3);
      time = time.replaceAll(".", ":");
      return time;
    }else{
      String time = d.toStringAsPrecision(4);
      time = time.replaceAll(".", ":");
      return time;
    }
  }


  Widget getWidget(Color c)
  {
    return Column(
        children: <Widget>[
          new Icon(Icons.access_time, color: c,),
          new Text(this.showTime(),
            style: new TextStyle(
              color: c
            ),),
        ],
    );
  }

  Widget bossEye(BuildContext context,Day day)
  {
    if(LoggedInUser.loggedInUser.boss&&this.state!=0){
      return Padding(
        padding: const EdgeInsets.only(left:16.0,right:16.0),
        child: new Fancy(
          text: "Collisions",
          iconData: Icons.warning,
          radius: 100.0,
          onTap: (){
            day.appointments = this._numberOfCollisions + this._negotiable;
            Navigator.push(context, MaterialPageRoute(builder: (context) => ( ReservedAppointments(day))));
          },

        ),
      );
    }
    else{
      return SizedBox();
    }
  }


  showCollisions (BuildContext mcontext) async
  {
    List<Appointment> merged = this._negotiable + this._numberOfCollisions;
   merged = await loadTheUsers(merged);
    return showDialog<void>(
      context:  mcontext,
      builder: (BuildContext context){
        return new AlertDialog(
          title: new Text("These Appointments Conflict With " +this.showTime(),textAlign: TextAlign.center,),
          content: new ListView.builder(
            itemCount: merged.length,
              shrinkWrap: true,
              itemBuilder: (context,index){
                return merged[index].getAppointmentWidget_NO_DELETE(context, false, Colors.white, false);
              }
          )
        );
      },
    );
  }

  Future<List<Appointment>> loadTheUsers(List<Appointment> appointments) async
  {
      for(int i = 0;i<appointments.length;i++){
        Appointment appointment = appointments[i];
        User user = appointment.user;
        if(user.name.isEmpty){
          await FirebaseDatabase.instance.reference().child(Helpers.USERS).child(user.uid).once().then((DataSnapshot snap){
            if(snap.value!=null){
              appointments[i].user.toUser(snap.value);
            }
          });
        }
    }
      return appointments;

  }

  toJson(){
    return {
      Helpers.START_TIME: this._startTime,
      Helpers.END_TIME: this._endTime,
    };
  }

   toTime(dynamic data)
  {
    this._startTime = data[Helpers.START_TIME].toDouble();
    this._endTime =  data[Helpers.END_TIME].toDouble();
  }

  get endTime => _endTime;

  set endTime(value) {
    _endTime = value;
  }

  double get startTime => _startTime;

  set startTime(double value) {
    _startTime = value;
  }






  // a log
//  Color getColor()
//  {
//    if(numberOfCollisions==0&&_negotiable==0){
//      return Colors.green;
//    }
//    else if(numberOfCollisions==0&&_negotiable>0){
//      return Colors.blue;
//    }else if(numberOfCollisions>0&&_negotiable==0){
//      return Colors.red;
//    }
//    else if(numberOfCollisions>this._negotiable){
//      return Colors.red;
//    }else if(this._negotiable>numberOfCollisions){
//      return Colors.blue;
//    }else if(this._negotiable==this.numberOfCollisions){
//      return Colors.red;
//    }
//    return Colors.yellow;
//  }
//
//  IconData getIcon()
//  {
//    if(numberOfCollisions==0&&_negotiable==0){
//      return Icons.access_time;
//    }
//    else if(numberOfCollisions==0&&_negotiable>0){
//      return Icons.phone_in_talk;
//    }else if(numberOfCollisions>0&&_negotiable==0){
//      return Icons.close;
//    }
//    else if(numberOfCollisions>this._negotiable){
//      return Icons.close;
//    }else if(this._negotiable>numberOfCollisions){
//      return Icons.phone_in_talk;
//    }else if(this._negotiable==this.numberOfCollisions){
//      return Icons.close;
//    }
//    return Icons.access_time;
//  }

  Color getColor()
  {
    switch(this.state){
      case 0:
        return Colors.white;
        break;
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.blue;
        break;
      case 3:
        return Colors.yellow;
        break;
    }
    return Colors.yellow;
  }

  IconData getIcon()
  {
    switch(this.state){
      case 0:
        return Icons.access_time;
        break;
      case 1:
        return Icons.close;
        break;
      case 2:
        return Icons.phone_in_talk;
        break;
      case 3:
        return Icons.access_time;
        break;
    }
    return Icons.access_time;
  }



  bool isBefore(Time t)
  {
    return (this.startTime<t.startTime);
  }

  bool isAfter(Time t)
  {
    return (this.startTime>t.startTime);
  }






}
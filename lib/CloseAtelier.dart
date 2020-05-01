
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simin_saloon/DateConvertor/DateConvertor.dart';
import 'package:simin_saloon/Buttons/Fancy.dart';
import 'package:simin_saloon/DaySetting/Time.dart';
import 'package:simin_saloon/Appointment/Appointment.dart';
import 'package:simin_saloon/Helpers.dart';



class CloseAtelier extends StatefulWidget
{


  @override
  _CloseAtelierState createState() => new _CloseAtelierState();
}

class _CloseAtelierState extends State<CloseAtelier>
{

  final double enterTime = -1;

  double startTime,endTime;
  DateTime startDate,endDate;

  bool isOpen;

  List<Appointment> inSessionAppointments;
  //initializer
  void initState()
  {

    super.initState();
    this.inSessionAppointments = new List();

    this.startTime = enterTime;
    this.endTime = enterTime;

    this.startDate = DateTime.now();
    this.endDate = DateTime.now();

    this.isOpen = true;



  }

  //get the hair jobs from the database

  //produces the scaffold of the createAppointment
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: getAppBar(),
      body: Builder(builder: (context) => getBody(context)),
      resizeToAvoidBottomPadding: true,
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  Widget getAppBar()
  {
    return new AppBar(
      title: new Text("Manage Day"),
      centerTitle: true,
      elevation: 0.0,
    );
  }







  //produces the body of the manger
  Widget getBody(BuildContext context)
  {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(child: getButtonForStartTime()),
                      Expanded(child: getButtonForEndTime())
                    ],
                  ),

                       getButtonForStartDate(context),
                       getButtonForEndDate(context),

                  getIsOpenButton(),
                  saveTheChanges(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget saveTheChanges(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Fancy(
        text: "Save",
        iconData: Icons.save,

        onTap: ()=> areYouSure(context),
        elevation: 0.0,
        radius: 100.0,
      ),
    );
  }

  areYouSure(BuildContext mcontext)
  {
    int size = this.inSessionAppointments.length;
    if((!this.isOpen&&size!=0)||this.startTime>this.endTime){
      //are you sure ?? there are
      return showDialog<void>(
        context:  mcontext,
        builder: (BuildContext context){
          return new AlertDialog(
            title: new Text("Are you sure?",textAlign: TextAlign.center,),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                getErrorAppointments(size),
                getErrorHours()
              ],
            ),
            actions: <Widget>[
              new FlatButton(onPressed: ()=>Navigator.pop(mcontext), child: new Text("Cancel")),
              new FlatButton(onPressed: ()=>saveChanges(mcontext,dcontext: context), child: new Text("Yes")),

            ],
          );
        },
      );
    }else{
      saveChanges(mcontext);
    }
  }

  Widget getErrorAppointments(int size)
  {
    if((!this.isOpen&&size!=0)) {
      return  new Text(
        "This day still has " + size.toString() + " active appointments!",
        textAlign: TextAlign.center,);
    }
    return SizedBox();
  }

  Widget getErrorHours()
  {
    if(this.startTime>this.endTime) {
      return  new Text(
        "The Opening hour is greater than the closing hour!!",
        textAlign: TextAlign.center,);
    }
    return SizedBox();
  }


  saveChanges(BuildContext context,{BuildContext dcontext}) async
  {
    bool c = await checkInternet();
    if(c){

      int year = this.startDate.year;
      int month = this.startDate.month;
      int day = this.startDate.day;

      while(!(year==this.endDate.year&&month==this.endDate.month&&day==this.endDate.day))
      {
//        this.startDate.
      }

      if(dcontext!=null){
        Navigator.pop(dcontext);
      }
      Navigator.pop(context);
    }else{
      if(dcontext!=null){
        Navigator.pop(dcontext);
      }
      Scaffold.of(context).showSnackBar(new SnackBar(backgroundColor:Colors.red,content: new Text("Please connect to internet",textAlign: TextAlign.center,style: TextStyle(color: Colors.white),)));
    }
  }

  Widget getIsOpenButton()
  {
    return Padding(
      padding: const EdgeInsets.only(left:8.0,right:8.0),
      child: new Fancy(
        textColor: Colors.white,
        text: getText(),
        color: getColor(),
        radius: 100.0,
        onTap: (){
          setState(() {
            this.isOpen = !this.isOpen;
          });

        },
      ),
    );
  }

  String getText()
  {
    return (this.isOpen)?"Atelier is open":"Atelier is closed";
  }

  Color getColor()
  {
    return (this.isOpen)?Colors.green:Colors.red;
  }

  Widget getButtonForStartTime()
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Fancy(
        text: (this.startTime==enterTime)?"Enter Start Time":"Start time: " + Time.getReadableForm(this.startTime),
        onTap: ()=> changeTime(1),
        radius: 100.0,
        elevation: 0.0,
      ),
    );
  }


  Widget getButtonForEndTime()
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Fancy(
        text: (this.endTime==enterTime)?"Enter End Time":"End time: " + Time.getReadableForm(this.endTime),
        onTap: ()=> changeTime(2),
        radius: 100.0,
        elevation: 0.0,
      ),
    );
  }

  Future<Null> changeTime(int i) async
  {

    TimeOfDay timeOfDay = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );

    if(timeOfDay!=null)
    {

      switch(i){
        case 1:
          setState(() {
            this.startTime = (timeOfDay.hour*100.0) + timeOfDay.minute;
          });
          break;
        case 2:
          setState(() {
            this.endTime  = (timeOfDay.hour*100.0) + timeOfDay.minute;
          });
          break;
      }
    }

  }


  Widget getButtonForStartDate(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Fancy(
        text: "Start Date: " + DateConvertor.showDateTime(this.startDate),
        onTap: ()=> selectDateFromPicker(context,1),
        radius: 100.0,
        elevation: 0.0,
      ),
    );
  }

  Widget getButtonForEndDate(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Fancy(
        text: "End Date: " + DateConvertor.showDateTime(this.endDate),
        onTap: ()=> selectDateFromPicker(context,2),
        radius: 100.0,
        elevation: 0.0,
      ),
    );
  }




  Future<Null> selectDateFromPicker(BuildContext context, int state) async {
    DateTime selected = await showDatePicker(
      context: context,
      initialDate: new DateTime.now(),
      firstDate: new DateTime(Helpers.yearStart),
      lastDate: new DateTime(Helpers.yearEnd),
    );

    if (selected != null) {
      DateTime convert = new DateTime(selected.year,selected.month,selected.day,23,59,59);
      if(convert.isBefore(DateTime.now())){
        //they cant choose appointments before today obviously right??!!!

        Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("You can not choose a date before today!",textAlign: TextAlign.center,)));
      }else {
        setState(() {
          switch(state){
            case 1:
              setState(() {
                this.startDate = selected;
              });
              break;
            case 2:
              setState(() {
                this.endDate  = selected ;
              });
              break;
          }

        });
      }
    }
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












}


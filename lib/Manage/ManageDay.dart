
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:simin_saloon/DaySetting/Day.dart';
import 'package:simin_saloon/Helpers.dart';
import 'package:simin_saloon/Buttons/Fancy.dart';
import 'package:simin_saloon/DaySetting/Time.dart';



class ManageDay extends StatefulWidget
{
  final Day day;
  ManageDay(this.day);

  @override
  _ManageDayState createState() => new _ManageDayState();
}

class _ManageDayState extends State<ManageDay>
{



  double startTime,endTime;
  bool isOpen;

  //initializer
  void initState()
  {

    super.initState();

    this.startTime = widget.day.workingHours.startTime;
    this.endTime = widget.day.workingHours.endTime;
    this.isOpen = widget.day.isOpen;



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
    int size = widget.day.inSessionAppointments();
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

      widget.day.workingHours.startTime = this.startTime;
      widget.day.workingHours.endTime = this.endTime;
      widget.day.isOpen =  this.isOpen;

      FirebaseDatabase.instance.reference().
      child(Helpers.DATE).
      child(widget.day.getYearOfDateTime()).
      child(widget.day.getMonthOfDateTime()).
      child(widget.day.getDayOfDateTime()).set(widget.day.toJson());

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
        text: "Start time: " + Time.getReadableForm(this.startTime),
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
        text: "End time: " + Time.getReadableForm(this.endTime),
        onTap: ()=> changeTime(2),
        radius: 100.0,
        elevation: 0.0,
      ),
    );
  }

  Future<Null> changeTime(int i) async
  {
    TimeOfDay initialTime;
    switch(i){
      case 1:
        initialTime = new TimeOfDay(hour: (this.startTime/100).floor(), minute: 0);
        break;
      case 2:
        initialTime = new TimeOfDay(hour: (this.endTime/100).floor(), minute: 0);
        break;
    }

    TimeOfDay timeOfDay = await showTimePicker(
      initialTime: initialTime,
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


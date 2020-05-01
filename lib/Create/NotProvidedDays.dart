

import 'package:flutter/material.dart';
import 'package:simin_saloon/Buttons/Fancy.dart';
import 'package:simin_saloon/Helpers.dart';



import 'package:simin_saloon/Appointment/WeekDay.dart';


// ignore: must_be_immutable
class NotProvidedDays extends StatefulWidget
{
  List<WeekDay> notProvided;
  NotProvidedDays({this.notProvided});

  @override
  _NotProvidedDaysState createState() => new _NotProvidedDaysState();
}

class _NotProvidedDaysState extends State<NotProvidedDays>
{



  List<WeekDay> notProvidedList;







  //initializer
  void initState()
  {
    initVars();
    super.initState();
  }

  //init all the vars
  void initVars()
  {
    if(widget.notProvided!=null){
      this.notProvidedList = widget.notProvided;
    }else{
      this.notProvidedList = getWeekDays();
    }
  }





  //produces the scaffold of the createAppointment
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: getAppBar(),
      body: Builder(
          builder: (BuildContext context) {
            return getBody(context);
          }
      ),
      backgroundColor: Theme.of(context).primaryColor,
      resizeToAvoidBottomPadding: true,
    );
  }


  //produce the appbar
  Widget getAppBar()
  {
    return new AppBar(
      elevation: 0.0,
      centerTitle: true,
      title: new Text("Not Provided Days"),
    );
  }


  //produces the body of the manger
  Widget getBody(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: SingleChildScrollView(
          child: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Text("Only choose the dates on which this hair job is NOT provided",textAlign: TextAlign.center,style: TextStyle(
                    fontSize: Helpers.FONT_SIZE
                  ),),
                ),
                getDaysOfTheWeekChecker(context),
                Padding(
                  padding: const EdgeInsets.only(left:8.0,right:8.0,bottom: 8.0),
                  child: new Fancy(
                    text: "save",
                    radius: 100.0,
                    onTap: (){
                      //save the changes
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  //not provided days dialog


  Widget getProvidedAllDaysButton(BuildContext context)
  {
    return new Fancy(
      text: "It is provided on all days",
      radius: 100.0,
      onTap: (){
        setState(() {
          this.notProvidedList = getWeekDays();
        });
        Navigator.pop(context);
      },
    );
  }

  Widget getDaysOfTheWeekChecker(BuildContext context)
  {

    return new ListView.builder(
        itemCount: notProvidedList.length,
        shrinkWrap: true,
        addAutomaticKeepAlives: true,
        itemBuilder: (BuildContext context, int index){
          WeekDay day = notProvidedList[index];
          return Row(
            children: <Widget>[
              new Checkbox(
                  value: day.notProvided,
                  onChanged: (bool b){
                    setState(() {
                      notProvidedList[index].notProvided = b;
                    });
                  }
              ),
              new Text(day.name)
            ],
          );
        }
    );
  }



  List<WeekDay> getWeekDays()
  {
    List<WeekDay> days = new List<WeekDay>();
    for(int i = 0;i<Helpers.weekdays.length;i++){
      WeekDay day = new WeekDay(Helpers.weekdays[i], i, false);
      days.add(day);
    }
    return days;
  }
















}

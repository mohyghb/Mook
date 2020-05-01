import 'package:flutter/material.dart';
import 'package:simin_saloon/DaySetting/Day.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:simin_saloon/Helpers.dart';
import 'package:simin_saloon/Appointment/Appointment.dart';
import 'package:simin_saloon/User/User.dart';


class ReservedAppointments extends StatefulWidget
{
  final Day day;
  final String title;

  ReservedAppointments(this.day,{this.title});


  @override
  _ReservedState createState() => new _ReservedState();
}

class _ReservedState extends State<ReservedAppointments>
{

  DatabaseReference _users;

  bool showCancelled;
  bool condense;

  //initializer
  void initState()
  {
    super.initState();
    showCancelled = true;
    condense = true;
    _users = FirebaseDatabase.instance.reference().child(Helpers.USERS);
    _loadTheUsers();
  }

  void _loadTheUsers() async
  {
    List<Appointment> appointments = new List<Appointment>();
    if(widget.day.appointments!=null){
      appointments = widget.day.appointments;

      for(int i = 0;i<appointments.length;i++){
        Appointment appointment = appointments[i];
        User user = appointment.user;
        if(user.name.isEmpty){
          await _users.child(user.uid).once().then((DataSnapshot snap){
            if(snap.value!=null){

                appointments[i].user.toUser(snap.value);
                widget.day.appointments = appointments;
            }
          });
        }
      }
      setState(() {

      });
    }
  }

  //produces the scaffold of the createAppointment
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        appBar: getAppBar(),
        body: getBody(),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }


  //produce the appbar
  Widget getAppBar()
  {
    return new AppBar(
      elevation: 0.0,
      leading: IconButton(icon: Icon(Icons.close), onPressed:(){
        Navigator.pop(context);
      }),
      centerTitle: true,
      title: new Text(getTitle()),
    );
  }


  String getTitle()
  {
    if(widget.title!=null){
      return widget.title;
    }else{
      return widget.day.showDateTime();
    }
  }


  //produces the body of the manger
  Widget getBody()
  {
    return Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            children: <Widget>[
              Card(
                child: Row(
                  children: <Widget>[
                    Expanded(child: getShowCancelledButton()),
                    Expanded(child: getShowCondenseButton())
                  ],
                ),
              ),
              Expanded(child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(child: getAppointments()),
                ],
              )),
            ],
          ),
    );
  }

  //show cancel
  Widget getShowCancelledButton()
  {
    if(showCancelled){
      return new FlatButton.icon(onPressed: onPressShowCancelledButton, icon: Icon(Icons.visibility), label: new Text("Show cancelled"));
    }else{
      return new FlatButton.icon(onPressed: onPressShowCancelledButton, icon: Icon(Icons.visibility_off), label: new Text("Show cancelled"));
    }
  }

  onPressShowCancelledButton()
  {
    setState(() {
      this.showCancelled = !this.showCancelled;
    });
  }

  //condense

  Widget getShowCondenseButton()
  {
    if(condense){
      return new FlatButton.icon(onPressed: onPressShowCondenseButton, icon: Icon(Icons.expand_more), label: new Text("Expand"));
    }else{
      return new FlatButton.icon(onPressed: onPressShowCondenseButton, icon: Icon(Icons.expand_less), label: new Text("Collapse"));
    }
  }

  onPressShowCondenseButton()
  {
    setState(() {
      this.condense = !this.condense;
    });
  }


  Widget getAppointments()
  {
    if(widget.day.appointments!=null){
      List<Appointment> appointments = getAppropriateAppointment();
      int len = appointments.length;
      if(len==0) {
        return new Card (
          child: Center(child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Icon(Icons.hourglass_empty,color:Colors.grey),
              new Text("No appointment found",textAlign: TextAlign.center,style: new TextStyle(color:Colors.grey,fontSize: Helpers.TITLE_FONT_SIZE),),
            ],
          )),
        );
      }
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new ListView.builder(
            itemCount: len,
              shrinkWrap: true,
              itemBuilder: (BuildContext context,int index){
                return appointments[index].getAppointmentWidget_NO_DELETE(context,condense,Colors.white,true);
              }
          ),
        ),
      );

    }else{
      return new Card (
        child: new Text("No appointment found",textAlign: TextAlign.center,),
      );
    }
  }


  List<Appointment> getAppropriateAppointment()
  {
    if(showCancelled){
      return widget.day.appointments;
    }else{
      return Appointment.getOnlyInSessionAppointments(widget.day.appointments);
    }
  }




}


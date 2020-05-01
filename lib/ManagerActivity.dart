import 'package:flutter/material.dart';
import 'package:simin_saloon/Buttons/Fancy.dart';
import 'package:simin_saloon/Create/NewHairJob.dart';
import 'package:simin_saloon/Manage/ManageHairJobs.dart';



class ManagerActivity extends StatefulWidget
{
  @override
  _ManagerActivityState createState() => new _ManagerActivityState();
}

class _ManagerActivityState extends State<ManagerActivity>
{



  //initializer
  void initState()
  {
    super.initState();

  }

  //produces the scaffold of the createAppointment
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: getAppBar(),
      body: getBody(),
    );
  }


  //produce the appbar
  Widget getAppBar()
  {
    return new AppBar(
      centerTitle: true,
      title: new Text("Manager"),
    );
  }


  //produces the body of the manger
  Widget getBody()
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Column(
          children: <Widget>[
            getNewHairJob(),
            getManageHairJobs(),

          ],
      ),
    );
  }


  //returns a button to create new hair jobs
  Widget getNewHairJob()
  {
    return new Fancy(
      text: "New Hair Job",
      radius: 100.0,
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ( NewHairJob())));
      },
    );
  }

  //managing the hair jobs
  Widget getManageHairJobs()
  {
    return new Fancy(
      text: "Manage Hair Jobs",
      radius: 100.0,
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ( ManageHairJobs())));
      },
    );
  }

  //
//  Widget getShowAppointments()
//  {
//    return new Fancy(
//      text: "Appointments",
//      radius: 100.0,
//      onTap: (){
//        Navigator.push(
//            context,
//            MaterialPageRoute(builder: (context) => ( ManageAppointments())));
//      },
//    );
//  }
}



import 'package:flutter/material.dart';
import 'package:simin_saloon/User/User.dart';


class ShowAppointments extends StatefulWidget
{
  final User user;
  ShowAppointments(this.user);
  @override
  _ShowAppointmentsState createState() => new _ShowAppointmentsState();
}

class _ShowAppointmentsState extends State<ShowAppointments>

{




  //initializer
  void initState()
  {

    super.initState();

  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: getAppBar(),
      body: Builder( builder: (context){return getBody(context);}),
      resizeToAvoidBottomPadding: true,
    );
  }

  Widget getAppBar()
  {
    return new AppBar(
      elevation: 0.0,
      centerTitle: true,
      title: new Text(widget.user.name+"'s "+"Appointments"),
    );
  }


  //produces the body of the manger
  Widget getBody(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: widget.user.showAppointments(false, Colors.black),
    );
  }





}

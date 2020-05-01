import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simin_saloon/Buttons/Fancy.dart';
import 'package:simin_saloon/Helpers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:simin_saloon/User/User.dart';
import 'package:simin_saloon/Appointment/ShowAppointments.dart';
import 'package:simin_saloon/Appointment/Appointment.dart';
import 'package:simin_saloon/DaySetting/Day.dart';
import 'package:simin_saloon/LoggedInUser.dart';

class ManageUsers extends StatefulWidget
{
  @override
  _ManageUsersState createState() => new _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers>

{


  List<User> users;
  bool isSearching;

  //initializer
  void initState()
  {
    isSearching = false;
    super.initState();
    getUsers();
  }

  //get the hair jobs from the database
  void getUsers() async
  {
    //getting the hair jobs from data base one by one
    //parsing and then adding it to the list
    await FirebaseDatabase.instance.reference().child(Helpers.USERS).once().then((DataSnapshot data){
      users = new List<User>();
      Map<dynamic,dynamic> map = data.value;
      if(map!=null){
        map.forEach((dynamic k, dynamic v){
          User user = new User( "", "", "", "");
          user.toUser(v);
          if(user.fullName()==(LoggedInUser.loggedInUser.fullName())&&user.phonenumber==(LoggedInUser.loggedInUser.phonenumber)){

          }else{
            users.add(user);
          }

        });
      }
    });
    setState(() {

    });

  }

  //produces the scaffold of the createAppointment
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
    if(isSearching){
      return new AppBar(
        elevation: 0.0,
        centerTitle: true,
        leading: new IconButton(icon:Icon(Icons.close),onPressed: (){
          setState(() {
            this.isSearching = false;
          });
        },),
        title: new TextField(
          onChanged: onSearchChange,
          decoration: new InputDecoration(
            hintText: "Search...",
              border: InputBorder.none,
            icon: Icon(Icons.search,color: Colors.black38,)
          ),
        ),
      );
    }else{
      return new AppBar(
        elevation: 0.0,
        centerTitle: true,
        actions: <Widget>[
          new IconButton(icon: Icon(Icons.search), onPressed: (){
            setState(() {
              this.isSearching = true;
            });
          })
        ],
        title: new Text("Manage Users"),
      );
    }

  }

  void onSearchChange(String changedText)
  {
    String lowCaseText = changedText.toLowerCase();
    for(int i = 0;i<users.length;i++){
      User user = users[i];
      if(user.fullName().toLowerCase().contains(lowCaseText)||user.phonenumber.contains(lowCaseText)){
        user.isInList = true;
      }else{
        user.isInList = false;
      }
    }
    setState(() {

    });
  }


  //produces the body of the manger
  Widget getBody(BuildContext context)
  {
    if(this.users==null){
      return new Center(
        child: new CircularProgressIndicator(),
      );
    }else{
      if(this.users.length!=0){
        return new ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.all(10.0),
          itemCount: this.users.length,
          itemBuilder: (BuildContext context, int index){
            User user =  this.users.elementAt(index);
            if(!user.isInList){
              return SizedBox();
            }
            return Card(
                elevation: 1.0,
                color: (user.deleted)?Colors.red:Colors.green,
                shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: user.getBossWidget(Colors.white)),
                      Column(
                        children: <Widget>[
                          deleteOrUndo(user,context),
                          new Fancy(
                            text: "open",
                            radius: 100.0,
                            color: Colors.white,
                            onTap: (){
                              //open to show the appointments of the user
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ( ShowAppointments(user))));
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                )
            );
          },
        );
      }else{
        return new Center(
          child: new Text("No Users Found",textAlign: TextAlign.center,style: TextStyle(fontSize: Helpers.TITLE_FONT_SIZE),),
        );
      }
    }

  }


  Widget deleteOrUndo(User user,BuildContext context)
  {
    if(user.deleted){
      return new Fancy(
        text: "Add back",
        radius: 100.0,
        color: Colors.white,
        onTap: ()=> addBack(user,context),
      );
    }else{
      return new Fancy(
        text: "remove",
        radius: 100.0,
        color: Colors.white,
        onTap: ()=> removeAtDialog(context,user),
      );
    }
  }

  removeAtDialog(BuildContext mcontext, User user) async
  {
    return showDialog<void>(
      context:  mcontext,
      builder: (BuildContext context){
        return new AlertDialog(
          title: new Text("Delete this user?",textAlign: TextAlign.center,),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text("Are you sure you want to delete ${user.fullName()}'s account?",textAlign: TextAlign.center,),
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
                        color: Colors.green,
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
                        color: Colors.red,
                        iconData: Icons.delete,
                        radius: 100.0,
                        onTap: ()=> removeAt(user,mcontext,context)
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



  //set the user's deleted to false
  void removeAt(User user,BuildContext context,dcontext) async
  {

    bool connected = await checkInternet();
    Navigator.pop(dcontext);
    if(connected){
      //add their pn to the blocked users
      addPhoneToBlocked(user.phonenumber);
      FirebaseDatabase.instance.reference().child(Helpers.USERS).child(user.uid).child(Helpers.APPOINTMENTS).once().then((snap){
        List<Appointment> appointments = new List<Appointment>();

          if(snap.value!=null){
            appointments = Day.dataToAppointment(snap.value);
          }
          for(int i = 0;i<appointments.length;i++){
            Appointment appointment = appointments.elementAt(i);
            appointment.deleteThisAppointment(context, "Successful!", "Error: Internet");
          }
        FirebaseDatabase.instance.reference().child(Helpers.USERS).child(user.uid).child(Helpers.APPOINTMENTS).set(null);
      });

      FirebaseDatabase.instance.reference().child(Helpers.USERS).child(user.uid).child(Helpers.DELETED).set(true);
      user.deleted = true;
      setState(() {

      });
    }else{
      Scaffold.of(context).showSnackBar(new SnackBar(backgroundColor:Colors.red,content: new Text("Please connect to internet",textAlign: TextAlign.center,style: TextStyle(color: Colors.white),)));
    }
  }


  //set the user's deleted to true
  void addBack(User user,BuildContext context) async
  {
    bool connected = await checkInternet();
    if(connected){
      //remove pn from the blocked numbers
      removePhoneFromBlocked(user.phonenumber);
      FirebaseDatabase.instance.reference().child(Helpers.USERS).child(user.uid).child(Helpers.DELETED).set(false);
      user.deleted = false;
      setState(() {

      });
    }else{
      Scaffold.of(context).showSnackBar(new SnackBar(backgroundColor:Colors.red,content: new Text("Please connect to internet",textAlign: TextAlign.center,style: TextStyle(color: Colors.white),)));
    }
  }


  addPhoneToBlocked(String pn)
  {
    FirebaseDatabase.instance.reference().child(Helpers.BLOCKED_NUMBERS).once().then((snap){
      List<dynamic> bpn = new List<dynamic>();
      if(snap.value!=null){
        bpn = snap.value;
      }
      List<String> newBPN = new List<String>();
      for(int i = 0;i<bpn.length;i++){
        newBPN.add(bpn[i]);
      }
      newBPN.add(pn);

      Map<String,String> map = new Map();
        for(int i =0;i<newBPN.length;i++){
          map.putIfAbsent(i.toString(), ()=> newBPN[i]);
        }

      FirebaseDatabase.instance.reference().child(Helpers.BLOCKED_NUMBERS).set(newBPN);
    });
  }

  removePhoneFromBlocked(String pn)
  {
    FirebaseDatabase.instance.reference().child(Helpers.BLOCKED_NUMBERS).once().then((snap){
      if(snap.value!=null){
        List<dynamic> bpn = new List<dynamic>();
        if(snap.value!=null){
          bpn = snap.value;
        }
        List<String> newBPN = new List<String>();
        for(int i = 0;i<bpn.length;i++){
          newBPN.add(bpn[i]);
        }
        newBPN.remove(pn);

        Map<String,String> map = new Map();
        for(int i =0;i<newBPN.length;i++){
          map.putIfAbsent(i.toString(), ()=> newBPN[i]);
        }

        FirebaseDatabase.instance.reference().child(Helpers.BLOCKED_NUMBERS).set(newBPN);
      }
    });
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

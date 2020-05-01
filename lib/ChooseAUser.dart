import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simin_saloon/Buttons/Fancy.dart';
import 'package:simin_saloon/Helpers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:simin_saloon/User/User.dart';
import 'package:simin_saloon/CreateAppointments.dart';
import 'package:simin_saloon/Create/NewUser.dart';



class ChooseAUser extends StatefulWidget
{
  @override
  _ChooseAUserState createState() => new _ChooseAUserState();
}

class _ChooseAUserState extends State<ChooseAUser>

{


  List<User> users;
  bool isSearching;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  //initializer
  void initState()
  {
    isSearching = false;
    users = new List<User>();
    super.initState();
    getUsers();
  }

  //get the hair jobs from the database
  void getUsers() async
  {
    //getting the hair jobs from data base one by one
    //parsing and then adding it to the list
    await FirebaseDatabase.instance.reference().child(Helpers.USERS).once().then((DataSnapshot data){
      Map<dynamic,dynamic> map = data.value;
      map.forEach((dynamic k, dynamic v){
        User user = new User( "", "", "", "");
        user.toUser(v);
        users.add(user);
      });
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
        body: Builder( builder: (context){return scaffoldBody(context);}),

        resizeToAvoidBottomPadding: true,
    );
  }


  Widget scaffoldBody(BuildContext context)
  {
    return new Column(
      children: <Widget>[
        newUser(context),
        skipChoosingUser(context),
        Expanded(child: getBody(context))
      ],
    );
  }

  Widget newUser(BuildContext context)
  {
    return  Padding(
      padding: const EdgeInsets.only(left:8.0,right:8.0,top: 8.0),
      child: new Fancy(
          text: "User does not have an account?",
          radius: 100.0,
          elevation: 0.0,
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => (NewUser())));
          },
      ),
    );
  }

  Widget skipChoosingUser(BuildContext mcontext)
  {
    return Padding(
      padding: const EdgeInsets.only(bottom:8.0,left:8.0,right: 8.0),
      child: new Fancy(
        text: "Skip choosing",
        radius: 100.0,
        elevation: 0.0,
        onTap: (){
          Navigator.pop(mcontext);
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => (CreateAppointment()))
          );
        },
      ),
    );
  }

//  addUserDialog (BuildContext mcontext)
//  {
//    return showDialog<void>(
//      context:  mcontext,
//      builder: (BuildContext context){
//        return new AlertDialog(
//          title: new Text("Create A New User",textAlign: TextAlign.center,),
//          content: new Column(
//            mainAxisSize: MainAxisSize.min,
//            children: <Widget>[
//              getTextFieldForName(),
//              getTextFieldForDescription(),
//              getTextFieldForPrice(),
//              SizedBox(height: 20.0,),
//              new Fancy(
//                text: "Create",
//                radius: 100.0,
//                onTap: ()=> ,
//              )
//            ],
//          ),
//
//        );
//      },
//    );
//  }


//  createNewUser(BuildContext mcontext,BuildContext dcontext) async
//  {
//    bool connected = await checkInternet();
//    if(connected){
//      String name = this._nameController.text;
//      String lastname = this._descriptionController.text;
//      String pn = this._priceController.text;
//
//
//      if(name.isEmpty){
//        Navigator.pop(dcontext);
//        Helpers.getSnackBar(Helpers.NAME_ERROR_EMPTY, mcontext);
//      }else if(lastname.isEmpty){
//        Navigator.pop(dcontext);
//        Helpers.getSnackBar("Last name can not be empty", mcontext);
//      }else if(pn.isEmpty){
//        Navigator.pop(dcontext);
//        Helpers.getSnackBar("Phone number can not be empty", mcontext);
//      }else if(pn.length!=10){
//        Navigator.pop(dcontext);
//        Helpers.getSnackBar("Phone number must have 10 digits", mcontext);
//      }else{
//        User newUser = new User(name,lastname,pn,Helpers.generateRandomId());
//        FirebaseDatabase.instance.reference().child(Helpers.USERS).child(newUser.uid).set(newUser.toJson());
//        Navigator.pop(dcontext);
//        Navigator.pop(mcontext);
//        Navigator.push(
//            context,
//            MaterialPageRoute(builder: (context) => ( CreateAppointment(
//              chosenUser: newUser,
//            ))));
//      }
//    }else{
//      Navigator.pop(dcontext);
//      Scaffold.of(mcontext).showSnackBar(new SnackBar(backgroundColor:Colors.red,content: new Text("Please make sure your internet connection works. We could not create a user at this moment.",textAlign: TextAlign.center,)));
//    }
//
//  }

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
        title: new Text("Choose A User"),
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
    if(this.users.length!=0){
      return new ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.only(left:10.0,right:10.0,bottom: 10.0),
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
                        new Fancy(
                            text: "Choose",
                            radius: 100.0,
                            elevation: 0.0,
                            color: Colors.white,
                            onTap: (){
                              Navigator.pop(context);
                              //open to show the appointments of the user
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ( CreateAppointment(
                                    chosenUser: user,
                                  ))));
                            },
                          ),
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
        child: new CircularProgressIndicator(),
      );
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




  //get the name TextField
  Widget getTextFieldForName()
  {
    return Padding(
      padding: const EdgeInsets.only(left:8.0,right:8.0,top:8.0),
      child: TextField(
          maxLines: 1,
          controller: this._nameController,
          enabled: true,
          obscureText: false,
          cursorColor: Theme.of(context).cursorColor,
          cursorWidth: 2,
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: Helpers.FONT_SIZE
          ),
          textAlign: TextAlign.center,
          autofocus: false,
          decoration: new InputDecoration(
              hintText: "Enter a name",
              hintStyle: TextStyle(
                  fontSize: Helpers.FONT_SIZE)
          ),
      ),
    );
  }



  //get the description TextField
  Widget getTextFieldForDescription()
  {
    return Padding(
      padding: const EdgeInsets.only(left:8.0,right:8.0,top:8.0),
      child: TextField(
        maxLines: 1,
        controller: this._descriptionController,
        enabled: true,
        obscureText: false,
        cursorColor: Theme.of(context).cursorColor,
        cursorWidth: 2,
        style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: Helpers.FONT_SIZE
        ),
        textAlign: TextAlign.center,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: "Enter a Last Name",
            hintStyle: TextStyle(
                fontSize: Helpers.FONT_SIZE)
        ),
      ),
    );
  }


  //get the price TextField
  Widget getTextFieldForPrice()
  {
    return Padding(
      padding: const EdgeInsets.only(left:8.0,right:8.0,top:8.0),
      child: TextField(
        maxLines: 1,
        controller: this._priceController,
        enabled: true,
        keyboardType: TextInputType.numberWithOptions(
            decimal: false,
            signed: false),
        obscureText: false,
        cursorColor: Theme.of(context).cursorColor,
        cursorWidth: 2,
        style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: Helpers.FONT_SIZE
        ),
        textAlign: TextAlign.center,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: "Enter a Phone Number",
            hintStyle: TextStyle(
                fontSize: Helpers.FONT_SIZE)
        ),
      ),
    );
  }




  void dispose()
  {
    super.dispose();
    this._nameController.dispose();
    this._descriptionController.dispose();
    this._priceController.dispose();
  }

}

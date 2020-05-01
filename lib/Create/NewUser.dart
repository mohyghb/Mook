
import 'dart:io';


import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simin_saloon/Buttons/Fancy.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:simin_saloon/User/User.dart';

import 'package:simin_saloon/CreateAppointments.dart';
import 'package:simin_saloon/Helpers.dart';

class NewUser extends StatefulWidget {

  _NewUserState createState() => new _NewUserState();

}

class _NewUserState extends State<NewUser> {


  final double FONT_SIZE = 16;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String verificationId;
  String phoneNumber = '';
  String phoneNumberError = "";
  String countryCode = "+1";
  String smsCode = "";
  String name = "";
  String lastname = "";





  bool connected;
  Connectivity subscription;

  List<String> blockedNumbers;

  var logo = new AssetImage("assets/logo_simin.png");





  @override
  void initState() {
    initBlockedNumbers();
    connected = true;
    super.initState();
  }

  void initBlockedNumbers()
  {
    this.blockedNumbers = new List<String>();
    FirebaseDatabase.instance.reference().child(Helpers.BLOCKED_NUMBERS).once().then((snap){

      List<dynamic> bpn = new List<dynamic>();
      if(snap.value!=null){
        bpn = snap.value;
      }

      for(int i = 0;i<bpn.length;i++){
        blockedNumbers.add(bpn[i]);
        print(blockedNumbers[i]);
      }

    });
  }









  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: getAppBar(),
      body: Builder(builder: (BuildContext context){
        return getBody(context);
      }
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  Widget getAppBar()
  {
    return new AppBar(
      elevation: 0.0,
      backgroundColor: Theme.of(context).primaryColor,
      title: new Text("New User"),
      centerTitle: true,
    );
  }


  Widget verticalSpace(double h)
  {
    return new SizedBox(height: h);
  }


  Widget getBody(BuildContext context)
  {
      return SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: new Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                getLogo(),
                getTitle(),
                verticalSpace(16.0),
                getSignIn(context),
                verticalSpace(10.0),
              ],
            ),
          ),
        ),
      );

  }

  Widget getSignIn(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            children: <Widget>[
              getTextFieldForName(),
              getTextFieldForLastName(),
              getTextFieldForNumber(),
              showInfoToUser(context),
            ],
          ),
        ),
      ),
    );

  }



  Widget getLogo()
  {
    return Padding(
      padding: const EdgeInsets.only(left:12.0,right:12.0),
      child: new Image(image: logo),
    );
  }
  Widget getTitle()
  {
    return new SizedBox();
//    return new Text(
//        "WELCOME",
//      textAlign: TextAlign.center,
//      style: TextStyle(
//        fontStyle: FontStyle.italic,
//        fontSize: 25.0,
//      ),
//    );
  }

  Widget showInfoToUser(BuildContext context)
  {
      return getVerifyButton(context);
  }

  Widget getVerifyButton(BuildContext context)
  {
    if(this.connected){
      return Padding(
        padding: const EdgeInsets.only(left:8.0,right:8.0,top: 16.0,bottom: 8.0),
        child:
        new Fancy(
          radius: 100.0,
          elevation: 0.0,
          iconData: Icons.verified_user,
          spaceBetweenTI: 4.5,
          text: "Verify",
          color: Colors.black,
          textColor: Colors.white,
          onTap: ()=> VerifyPhoneNumber(context),
        ),
      );
    }else{
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
            elevation: 0.0,
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Icon(Icons.error,color: Colors.white,),
                  SizedBox(width: 3.0,),
                  new Text(Helpers.NEED_INTERNET,textAlign: TextAlign.center,style: TextStyle(color: Colors.white),),
                ],
              ),
            )
        ),
      );
    }

  }



  Widget getTextFieldForNumber()
  {
    return Padding(
      padding: const EdgeInsets.only(left:8.0,right:8.0,top:8.0),
      child:new TextField(
        //is not working
        keyboardType: TextInputType.numberWithOptions(
            decimal: false,
            signed: false),
        maxLines: 1,
        onChanged: onChangedTextPhoneNumber,
        enabled: true,
        obscureText: false,
        cursorColor: Theme.of(context).cursorColor,
        cursorWidth: 2,
        style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: FONT_SIZE
        ),
        autofocus: false,
        decoration: new InputDecoration(
            icon: Icon(Icons.phone_in_talk),
            labelStyle: TextStyle(color: Colors.black),
            labelText: "Enter your phone number",
            hintText: "e.g 6043243241",
            hintStyle: TextStyle(
                fontSize: FONT_SIZE)
        ),
      ),

    );
  }
  Widget getTextFieldForName()
  {
    return Padding(
      padding: const EdgeInsets.only(left:8.0,right:8.0,top:8.0),
      child: new TextField(
        //is not working
        maxLines: 1,
        onChanged: onChangedTextName,
        enabled: true,
        obscureText: false,
        cursorColor: Theme.of(context).cursorColor,
        cursorWidth: 2,
        style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: FONT_SIZE
        ),
        autofocus: false,
        decoration: new InputDecoration(
            icon: Icon(Icons.person,),
            labelText: "Enter a name",
            labelStyle: TextStyle(color: Colors.black),
            hintText: "Name",
            hintStyle: TextStyle(
                fontSize: FONT_SIZE)
        ),
      ),
    );
  }
  Widget getTextFieldForLastName()
  {
    return Padding(
      padding: const EdgeInsets.only(left:8.0,right:8.0,top:8.0),
      child: new TextField(
        //is not working
        maxLines: 1,
        onChanged: onChangedTextLastName,
        enabled: true,
        obscureText: false,
        cursorColor: Theme.of(context).cursorColor,
        cursorWidth: 2,
        style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: FONT_SIZE
        ),
        autofocus: false,
        decoration: new InputDecoration(
            icon: Icon(Icons.person_outline),
            labelText: "Enter a last name",
            labelStyle: TextStyle(color: Colors.black),
            hintText: "Last Name",
            hintStyle: TextStyle(
                fontSize: FONT_SIZE)
        ),
      ),

    );
  }


  //check to see if it changes
  void onChangedTextPhoneNumber(String number)
  {
    this.phoneNumber = number;
//    setState(() {
//      this.showLoadingVerification = false;
//    });
  }
  void onChangedTextName(String number)
  {
    this.name = number;

  }
  void onChangedTextLastName(String number)
  {
    this.lastname = number;

  }


  //PhoneNumber
  //Verifies whether the input number was good or not
  void VerifyPhoneNumber(BuildContext context) async
  {
    bool c  = await checkInternet();
    if(c){
      if(name.isEmpty){
        makeSnackBar("Name can not be empty", Colors.red,context);
      }
      else{
        if(lastname.isEmpty){
          makeSnackBar("Last Name can not be empty", Colors.red,context);
        }else{
          if(isAGoodPhoneNumber(this.phoneNumber)){
            if(this.blockedNumbers.contains(this.phoneNumber)){

              makeSnackBar("Your number has been blocked from our system, Sorry. Please speak with the owner to solve the issue.", Colors.red,context);

            }else{

              User newUser = new User(name,lastname,phoneNumber,Helpers.generateRandomId());
              FirebaseDatabase.instance.reference().child(Helpers.USERS).child(newUser.uid).set(newUser.toJson());
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ( CreateAppointment(
                    chosenUser: newUser,
                  ))));
//              setState(() {
//                this.showLoadingVerification = true;
//                verifyPhone();
//              });
            }

          }else{
            makeSnackBar(this.phoneNumberError, Colors.red,context);
          }
        }
      }

    }else{
      makeSnackBar("Connect to internet please", Colors.red,context);
    }
  }

  makeSnackBar(String text, Color c,BuildContext context)
  {
    Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(text,textAlign: TextAlign.center,),backgroundColor: c,));
  }

  //produces true if the phone number does not have a minus or dot in it and it is 10 digits
  bool isAGoodPhoneNumber(String s)
  {
    if(s.isNotEmpty){
      if(hasOnlyNumbers(s)){
        if(s.length == 10){
          return true;
        }else{
          //size of it is not exactly 10
          phoneNumberError = "Phone number must exactly have 10 numbers in it";
          return false;
        }
      }else{
        phoneNumberError = "Phone number must consist of only numbers";
        return false;
        //detected other things other than numbers

      }
    }
    else{
      phoneNumberError = "Phone Number can not be empty";
      //empty error
      return false;
    }
  }
  //returns true if string has only numbers in it
  bool hasOnlyNumbers(String s)
  {
    if(s.isEmpty){
      return true;
    }else if(s.codeUnitAt(0)<48||s.codeUnitAt(0)>57){
      return false;
    }
    return hasOnlyNumbers(s.substring(1));
  }
  //returns a good number in the valid form e.g (6823344172  -> +1 682-334-4172)
  String getValidForm(String number)
  {
    return this.countryCode + " " + getDashed(number);
  }
  //puts dashes every 3 numbers
  String getDashed(String number)
  {
    return number.substring(0,3) + "-" + number.substring(3,6) + "-" + number.substring(6,10);
  }


  //circular load
  Widget getCircularProgressBar()
  {
    return Padding(
      padding: const EdgeInsets.only(right:8.0,left:8.0,top: 16.0,bottom: 8.0),
      child: Column(
        children: <Widget>[
          new Theme(
            data: Theme.of(context).copyWith(accentColor: Colors.black),
            child: new CircularProgressIndicator(),
          ),
          verticalSpace(5.0),
          new Text("Make sure you entered the correct number!\n" +
              "This is an automatic authentication system, so you do not need to enter a code.",
            textAlign: TextAlign.center,),
        ],
      ),
    );
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


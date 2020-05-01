import 'dart:async';
import 'dart:io';


import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simin_saloon/Buttons/Fancy.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:simin_saloon/User/User.dart';
import 'package:simin_saloon/LoggedInUser.dart';
import 'package:simin_saloon/Helpers.dart';

class Auth extends StatefulWidget {

  _AuthState createState() => new _AuthState();

}

class _AuthState extends State<Auth> {


  final double FONT_SIZE = 16;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String verificationId;
  String phoneNumber = '';
  String phoneNumberError = "";
  String countryCode = "+1";
  String smsCode = "";
  String name = "";
  String lastname = "";



  bool showSplashScreen = true;
  bool showLoadingVerification = false;

  bool connected;
  Connectivity subscription;

  List<String> blockedNumbers;

  var logo = new AssetImage("assets/logo_simin.png");


  Future<void> verifyPhone() async {


    final PhoneCodeAutoRetrievalTimeout phoneCodeAutoRetrievalTimeout = (String verId){
      verificationId = verId;
    };

    final PhoneCodeSent phoneCodeSent = (String verId, [int forceCodeResend])
    {
      this.verificationId = verId;
    };

    final PhoneVerificationCompleted verificationCompleted = (FirebaseUser fireBaseUser)
    {
      User newUser = new User(this.name,this.lastname,this.phoneNumber,fireBaseUser.uid);
      LoggedInUser.loggedInUser = newUser;
      FirebaseDatabase.instance.reference().child(Helpers.USERS).child(newUser.uid).update(newUser.toJson());
      Navigator.pushReplacementNamed(context, "/mainmenu");
    };

    final PhoneVerificationFailed verificationFailed = (AuthException ae)
    {
      setState(() {
        this.showLoadingVerification = false;
        print(ae.message);
        Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(ae.message)));
      });
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: getValidForm(this.phoneNumber),
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: phoneCodeSent,
        codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout);
  }

//  signIn() {
//    FirebaseAuth.instance
//        .signInWithPhoneNumber(verificationId: verificationId, smsCode: smsCode)
//        .then((user) {
//          setState(() {
//            Navigator.pushReplacementNamed(context, "/mainmenu");
//          });
//    }).catchError((e) {
//      print(e);
//    });
//  }






  @override
  void initState() {
    FirebaseDatabase.instance.purgeOutstandingWrites();
    checkConnectivity();
    initBlockedNumbers();
    listenForConnectivityChanges();

    LoggedInUser.loggedInUser = new User("","","","");
      _auth.currentUser().then((val) {
          if (val != null) {
            getLoggedInUser(val);
          }else{
            showSplashScreen = false;
          }
      }).catchError((e) {

      });
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
      }

    });
  }


  Future<void> getLoggedInUser(FirebaseUser user) async
  {
    await FirebaseDatabase.instance.reference().child(Helpers.USERS).child(user.uid).once().then((DataSnapshot data){
      setState(() {
        if(data.value!=null){
          User user = new User("","","","");
          user.toUser(data.value);
          if(user.deleted){
            showSplashScreen = false;
          }else{
            LoggedInUser.loggedInUser = user;
            Navigator.pushReplacementNamed(context, "/mainmenu");
          }
        }
        else{
          showSplashScreen = false;

        }
      });
    });
  }






  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      body: Builder(builder: (BuildContext context){
        return getBody(context);
      }
      ),
      backgroundColor: Helpers.themeColor,
    );
  }


  Widget verticalSpace(double h)
  {
    return new SizedBox(height: h);
  }


  Widget getBody(BuildContext context)
  {
    if(showSplashScreen){
      return SafeArea(child: Center(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Image(image: logo,),
            SizedBox(height: 10.0,),
            new CircularProgressIndicator()
          ],
        )),
      ));
    }else{
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

  }

  Widget getSignIn(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            children: <Widget>[
              getTextFieldForName(),
              getTextFieldForLastName(),
              getTextFieldForNumber(),
              showInfoToUser(context),
              getButtonForJustVisiting()
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
    if(this.showLoadingVerification){
      return this.getCircularProgressBar();
    }else{
      return getVerifyButton(context);
    }
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
                        icon: Icon(Icons.phone_in_talk,color: Colors.black,),
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
              icon: Icon(Icons.person,color: Colors.black,),
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
              icon: Icon(Icons.person_outline,color: Colors.black,),
              labelText: "Enter a last name",
              labelStyle: TextStyle(color: Colors.black),
              hintText: "Last Name",
              hintStyle: TextStyle(
                  fontSize: FONT_SIZE)
          ),
        ),

    );
  }



  Widget getButtonForJustVisiting()
  {
    return new FlatButton(
        onPressed: (){
          LoggedInUser.loggedInUser.uid = User.VISITOR;
          Navigator.pushReplacementNamed(context, "/mainmenu");
        },
        child: new Text("Enter as guest")
    );
  }


  //check to see if it changes
  void onChangedTextPhoneNumber(String number)
  {
    this.phoneNumber = number;
    setState(() {
      this.showLoadingVerification = false;
    });
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
  void VerifyPhoneNumber(BuildContext context)
  {
    if(connected){
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
              setState(() {
                this.showLoadingVerification = true;
                verifyPhone();
              });
            }

          }else{
            makeSnackBar(this.phoneNumberError, Colors.red,context);
          }
        }
      }

    }else{
      print("Connect plz");
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
        setState(() {
          connected = true;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        connected = false;
        if(showLoadingVerification){
          showLoadingVerification = false;
        }
      });
    }
  }

  checkConnectivity() async{
    checkInternet();
  }

  listenForConnectivityChanges()
  {
    subscription = new Connectivity();
    subscription.onConnectivityChanged.listen((ConnectivityResult result) {
      // Got a new connectivity status!
      checkInternet();
    });
  }



}


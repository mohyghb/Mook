
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:simin_saloon/CreateAppointments.dart';
import 'package:simin_saloon/Auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:simin_saloon/LoggedInUser.dart';
import 'package:simin_saloon/Helpers.dart';


import 'package:simin_saloon/HairJobs.dart';


import 'package:simin_saloon/Appointment/Appointment.dart';
import 'package:simin_saloon/DaySetting/Day.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:simin_saloon/ReservedAppointments.dart';
import 'package:simin_saloon/Create/NewHairJob.dart';
import 'package:simin_saloon/Manage/ManageHairJobs.dart';

import 'package:simin_saloon/Manage/ManageUsers.dart';
import 'package:simin_saloon/ChooseAUser.dart';

import 'package:simin_saloon/Create/NewNews.dart';

import 'package:simin_saloon/Manage/ManageNews.dart';
import 'package:simin_saloon/Create/News.dart';

import 'package:simin_saloon/Appointment/TypeOfHairJob.dart';
import 'package:url_launcher/url_launcher.dart';


//icon launcher
//import 'package:flutter_launcher_icons/android.dart';
//import 'package:flutter_launcher_icons/constants.dart';
//import 'package:flutter_launcher_icons/custom_exceptions.dart';
//import 'package:flutter_launcher_icons/ios.dart';
//import 'package:flutter_launcher_icons/main.dart';
//import 'package:flutter_launcher_icons/xml_templates.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.


//  static final gold = const Color(0xFFFFD700).withOpacity(1.0);
//  final gold2 = const Color(0xFFC5B358);
//  final gold3 = const Color(0xFFCFB53B);
//  final gold4 = const Color(0xFFD4AF37);
//  final gold5 = const Color(0xFFFFDF00);
//  final gold6 = const Color(0xFFD4AF37);

    final newCyan = const Color(0xFF5DCFC6);


//  primaryColor: gold,
//  accentColor:  Colors.black,
//  backgroundColor: Colors.white,
//  splashColor: gold5,
//  cursorColor: Colors.black,
//  cardColor: Colors.white,
//  disabledColor: Colors.white70,

//  primaryColor: Colors.cyan[50],
//  accentColor:  Colors.black,
//  backgroundColor: Colors.white,
//  splashColor: Colors.cyan[200],
//  cursorColor: Colors.black,
//  cardColor: Colors.white,
//  disabledColor: Colors.white70,

//  primaryColor: Colors.grey,
//  accentColor:  Colors.black,
//  backgroundColor: Colors.white,
//  splashColor: Colors.grey[300],
//  cursorColor: Colors.black,
//  cardColor: Colors.white,
//  disabledColor: Colors.white70,

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mook',
      theme: new ThemeData(
        primaryColor: Colors.white,
        accentColor:  Colors.black,
        backgroundColor: Colors.white,
        splashColor: Colors.white70,
        cursorColor: Colors.black,
        cardColor: Colors.white,
        disabledColor: Colors.white70,
      ),
      home: new Auth(),
   // home: new MyHomePage(title:"Simin Beauty Atelier"),
        routes: <String, WidgetBuilder> {
          '/homepage': (BuildContext context) => Auth(),
          '/mainmenu': (BuildContext context) => MyHomePage(title:"Mook")
        }
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {






  FirebaseUser currentUser;


  DatabaseReference appointmentsRef;
  DatabaseReference appSwitchRef;
  List<TypeOfHairJob> hairJobs;

  var logo = new AssetImage("assets/logo_simin.png");
  int bodyIndex = 0;

  List<Widget> bodyWidgets;

  List<News> newsList;

  bool connected;
  bool appSwitch;

  Connectivity subscription;

  FirebaseMessaging fireBaseMessaging;


  @override
  void initState()
  {
    FirebaseDatabase.instance.setPersistenceEnabled(false);

    //LoggedInUser.loggedInUser = new User("Name","Last","6043652222",Helpers.generateRandomId());
//    Encrypt moc = new Encrypt();
//    String enc = moc.encrypt("this is my name please");
//    String dec = moc.decrypt(enc);
//
//    print("ENCRYPT  ==         " + enc);
//    print("DECRYPT  ==         " + dec);







    initClasses();
  //   mainCrash();
    super.initState();
  }












  //all the init happens inside this function
  void initClasses()
  {
    newsList = new List<News>();
    hairJobs = new List<TypeOfHairJob>();
    //listenForNotifications();
    updateNews();
    getHairJobs();
    HairJobs.hairJobs = new List();
    bodyWidgets = new List<Widget>();
    bodyWidgets.add(getBody());
    //news
    bodyWidgets.add(getNews());
    bodyWidgets.add(getHairJobsWidget());
    connected = false;
    checkConnectivity();
    listenForConnectivityChanges();
    initSwitch();
  }


  getHairJobs() async
  {
    //getting the hair jobs from data base one by one
    //parsing and then adding it to the list
    await FirebaseDatabase.instance.reference().child(Helpers.TYPE_OF_HAIR_JOB).once().then((DataSnapshot data){
      Map<dynamic,dynamic> map = data.value;
      if(map!=null){
        map.forEach((dynamic k, dynamic v){
          TypeOfHairJob typeOfHairJob = new TypeOfHairJob("", "", "", "", "");
          typeOfHairJob.toTypeOfHairJob(v);
          if(!typeOfHairJob.isDeleted()){
            hairJobs.add(typeOfHairJob);
          }
        });
      }


    });
    setState(() {
      bodyWidgets[2] = getHairJobsWidget();
    });

  }

  updateNews() async
  {
    await FirebaseDatabase.instance.reference().child(Helpers.NEWS).once().then((DataSnapshot data){
      Map<dynamic,dynamic> map = data.value;
      if(map!=null){
        map.forEach((dynamic k, dynamic v){
          News news = new News("", "");
          news.toTypeOfHairJob(v);
          if(news.deleted!=true){
            newsList.add(news);
          }

        });
      }

    });
    setState(() {
      bodyWidgets[1] = getNews();
    });
  }

//  listenForNotifications()
//  {
//    fireBaseMessaging = new FirebaseMessaging();
//    fireBaseMessaging.configure(
//      onLaunch: (Map<String,dynamic> data){
//        print("On launch");
//    },
//      onMessage: (Map<String,dynamic> data){
//        print("On launch");
//      },
//      onResume: (Map<String,dynamic> data){
//        print("On launch");
//      }
//    );
//    fireBaseMessaging.requestNotificationPermissions(
//      const IosNotificationSettings(
//        alert: true,
//        badge: true,
//        sound: true
//      )
//    );
//    fireBaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings s){
//      print(s.toString());
//    });
//    fireBaseMessaging.getToken().then((token){
//      updateUserToken(token);
//    }).catchError((e){print(e.toString());});

 // }

//  updateUserToken(String token)
//  {
//    FirebaseDatabase.instance.reference().child(Helpers.USERS).child(LoggedInUser.loggedInUser.uid).child(Helpers.NOTIFICATION_TOKEN)
//        .set(LoggedInUser.loggedInUser.enc(token));
//  }


  void initSwitch()
  {
    appSwitch = true;
    this.appSwitchRef = FirebaseDatabase.instance.reference().
    child(Helpers.SWITCH);
    this.appSwitchRef.onChildChanged.listen(updateSwitch);
    this.appSwitchRef.onChildRemoved.listen(updateSwitch);
    this.appSwitchRef.onChildAdded.listen(updateSwitch);
    this.appSwitchRef.keepSynced(true);

    this.appSwitchRef.once().then((DataSnapshot snap){
      if(snap.value!=null){
        setState(() {
          appSwitch = snap.value["Working"];
          if(appSwitch&&LoggedInUser.loggedInUser.isNotAVisitor()){
            initAppointmentRef();
            initBoss();
          }
        });
      }
    });
  }

  void initAppointmentRef()
  {
    appointmentsRef = FirebaseDatabase.instance.reference().
    child(Helpers.USERS).
    child(LoggedInUser.loggedInUser.uid);


    appointmentsRef.onChildAdded.listen(updateAppointments);
    appointmentsRef.onChildChanged.listen(updateAppointments);
    appointmentsRef.onChildRemoved.listen(updateAppointments);
  }

  initBoss() async
  {
    FirebaseDatabase.instance.reference().
    child(Helpers.BOSS).once().then((DataSnapshot snap){
      if(snap.value!=null){
        List<dynamic> bossNumbers = snap.value;
        String userNumber = LoggedInUser.loggedInUser.phonenumber;
        bossNumbers.forEach((dynamic bn){
          if(bn==(userNumber.toString())&&!LoggedInUser.loggedInUser.boss){
            setState(() {
              LoggedInUser.loggedInUser.boss = true;
            });
          }

        });
      }
    });
  }

  updateAppointments(Event e) async
  {
    if(e.snapshot.value!=null){

      this.appointmentsRef.once().then((DataSnapshot snap){
        if(snap.value!=null){
          LoggedInUser.loggedInUser.toUser(snap.value);
          if(LoggedInUser.loggedInUser.deleted){
            Navigator.pushReplacementNamed(context, '/homepage');
          }
          //          appointments = Day.dataToAppointmentUser(snap.value);
//          LoggedInUser.loggedInUser.appointments = new List<Appointment>();
//          for(int i = 0;i<appointments.length;i++){
//            if(!appointments.elementAt(i).deleted){
//              LoggedInUser.loggedInUser.appointments.add(appointments[i]);
//            }
//          }
          if(mounted){
            setState(() {
              bodyWidgets[0] = getBody();
            });
          }
        }
      });
    }
  }

  updateSwitch(Event e) async
  {
    if(e.snapshot.value!=null){
      this.appSwitchRef.once().then((DataSnapshot snap){
        if(snap.value!=null){
          setState(() {
            appSwitch = snap.value["Working"];
          });
        }
      });
    }
  }


  //produces the scaffold of the main menu
  @override
  Widget build(BuildContext context) {
    if(!appSwitch){
      return new Scaffold(
        backgroundColor: Colors.red,
        body: SafeArea(child: Center(child: new Text("Sorry, there was a problem. Talk to the developer if this error is unexpected.",textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: Helpers.TITLE_FONT_SIZE),))),
      );
    }
    return new Scaffold(
      drawer: getDrawer(),
      appBar: getAppBar(),
      backgroundColor: Colors.white,
//      backgroundColor: Theme.of(context).primaryColor,
      bottomNavigationBar: getBottomNavigationBar(),
      body: this.bodyWidgets[this.bodyIndex],
      floatingActionButton: getFAB()
    );
  }




  Widget getFAB()
  {
    return  new FloatingActionButton(
        heroTag: Helpers.FAB_TAG_HERO,

          backgroundColor: Helpers.fabColor,
          foregroundColor: Colors.white,
          child: new Icon(Icons.add),
          onPressed: (){
            if(LoggedInUser.loggedInUser.boss){
              // choose a user
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => (ChooseAUser()))
              );
            }
            else{
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => (CreateAppointment()))
              );
            }

          });
  }



  //produces the body of the app
  Widget getBody()
  {
    if(LoggedInUser.loggedInUser==null){
      //it has not loaded yet
      return new Center(child: new CircularProgressIndicator(),);
    }else{
      if(LoggedInUser.loggedInUser.appointments!=null){
        int size = LoggedInUser.loggedInUser.appointments.length;
        if(size==0){
          // no appointment has been made
          return noAppointment();
        }else{
          //show the appointments
          List<Appointment> appointments = LoggedInUser.loggedInUser.appointments;
          return new ListView.builder(
                itemCount: size,
                itemBuilder: (BuildContext context, int index){
                  return appointments.elementAt(index).getAppointmentWidget(context,appointmentsRef,connected,Colors.black);
                });
        }
      }else{
        return noAppointment();
      }
    }
  }


  Widget getNews()
  {
    if(this.newsList.isEmpty){
      return noNews();
    }else{
      return new ListView.builder(
        itemCount: this.newsList.length,
          itemBuilder: (context,index){
            return Padding(
                padding: const EdgeInsets.only(left: 8.0,right: 8.0,top: 8.0),
            child: new Card(
            elevation: 0.0,
            color: Helpers.themeColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: newsList[index].getNewsWidget(context, Colors.black))
            ));
          }
      );
    }
  }

  Widget noAppointment()
  {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Icon(Icons.event_available,color: Colors.black38,),
          SizedBox(width: 5.0,),
          new Text("No Appointment",
            style: TextStyle(
              fontSize: Helpers.TITLE_FONT_SIZE+2,
                color: Colors.black38
            ),),
        ],
      ),
    );
  }


  //produces the app bar of the main menu
  Widget getAppBar()
  {
    if(LoggedInUser.loggedInUser.boss){
      return new AppBar(
        //elevation: 2.0,
        centerTitle: true,
        actions: <Widget>[
          new IconButton(icon: Icon(Icons.today), onPressed: todayAppointments)
        ],
        title: new Text(widget.title),
      );
    }
    return new AppBar(
      centerTitle: true,
      title: new Text(widget.title),
    );
  }

  todayAppointments()
  {
    DateTime today = DateTime.now();
    FirebaseDatabase.instance.reference().child(Helpers.DATE).child(today.year.toString())
        .child(today.month.toString()).child(today.day.toString()).once().then((DataSnapshot dataSnapshot){

      Day day = Helpers.getDefaultDaySetting(today);
      if(dataSnapshot.value!=null) {
        if (dataSnapshot.value[Helpers.DELETED] != null) {
          day.toDay(dataSnapshot.value);
        } else {
          day.appointments = Day.dataToAppointment(
              dataSnapshot.value[Helpers.APPOINTMENTS]);
        }
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => ( ReservedAppointments(day,title: "Today's Appointments",))));

    });
  }


  //Drawer Functions
  //produces the drawer header of the main
  Widget getDrawer ()
  {
    return new Drawer(
      child: ListView(
      padding: EdgeInsets.zero,
      children: getDrawerItems(),
      ),
    );
  }

  List<Widget> getDrawerItems()
  {
    List<Widget> low = new List<Widget>();
    low.add(getDrawerHeader());
    if(LoggedInUser.loggedInUser.boss){
      low.add(getCreateHairJob());
      low.add(getManageHairJob());
      low.add(getManageUsers());
//      low.add(getManageBoss());
      low.add(getCreateNews());
      low.add(getManageNews());
//      low.add(getCloseAtelier());
      low.add(getSettingDivider());
    }
    low.add(getWebsite());
    low.add(getContactUs());
    low.add(getAbout());
    low.add(getBlog());
    low.add(getDeveloper());
    return low;
  }

//  Widget getCloseAtelier()
//  {
//    return getDrawerTiles("Close Atelier", (){
//      Navigator.push(
//          context,
//          MaterialPageRoute(builder: (context) => (CloseAtelier())));
//    },icon: Icons.close);
//  }


  Widget getManageNews()
  {
    return getDrawerTiles("Manage News", (){
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => (ManageNews())));
    },icon: Icons.whatshot);
  }


  Widget getCreateNews()
  {
    return getDrawerTiles("Create News", (){
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => (NewsClass())));
    },icon: Icons.bubble_chart);
  }

//  Widget getManageBoss()
//  {
//    return getDrawerTiles("Manage Bosses", (){
//      Navigator.push(
//          context,
//          MaterialPageRoute(builder: (context) => ( ManageBoss())));
//    },icon: Icons.group);
//  }

  Widget getManageUsers()
  {
    return getDrawerTiles("Manage Users", (){
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ( ManageUsers())));
    },icon: Icons.supervisor_account);
  }

  Widget getSettingDivider(){
    if(LoggedInUser.loggedInUser.boss){
      return Column(
        children: <Widget>[

          Divider(),
        ],
      );
    }
    else{
      return SizedBox();
    }
  }



  //produces the drawer header of the drawer
  Widget getDrawerHeader()
  {

    return Container(
      height: 500.0,
      child: DrawerHeader(
          child: Center(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Image(image: logo),
                new Text("Developed by Moh Yaghoub")
              ],
            ),
          )),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor
          ),
          margin: EdgeInsets.all(0.0),
          padding: EdgeInsets.all(0.0)
      ),
    );
  }

  //produces the drawer tiles of the drawer
  Widget getDrawerTiles(String text,VoidCallback vcb,{IconData icon,String sub})
  {
    return new ListTile(
        onTap: vcb,
        title: Text(text),
      leading: new Icon(icon),
    );
  }




  //returns a drawer tile with boss abilities if the user is the boss
  Widget getCreateHairJob()
  {
    if(LoggedInUser.loggedInUser.boss){
      return getDrawerTiles("Create New HairJob", (){
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ( NewHairJob()))
      );
      },
          icon:Icons.create,
      );
    }else{
      return new SizedBox(width: 0);
    }
  }

  //returns a drawer tile with boss abilities if the user is the boss
  Widget getManageHairJob()
  {
    if(LoggedInUser.loggedInUser.boss){
      return getDrawerTiles("Manage HairJobs", (){
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ( ManageHairJobs()))
        );
      },
        icon:Icons.gesture,
      );
    }else{
      return new SizedBox(width: 0);
    }
  }






  //return contact us
  Widget getContactUs()
  {
    return getDrawerTiles("Contact us",
    ()=> launchURL("https://siminbeautyatelier.com/contact/"),
    icon: Icons.contact_mail);
  }

  Widget getAbout()
  {
    return getDrawerTiles("About",
            ()=> launchURL("https://siminbeautyatelier.com/about/"),
        icon: Icons.info);
  }

  Widget getBlog()
  {
    return getDrawerTiles("Blog",
            ()=> launchURL("https://siminbeautyatelier.com/blog"),
        icon: Icons.blur_circular);
  }

  Widget getWebsite()
  {
    return getDrawerTiles("Our Website",
            ()=> launchURL("https://siminbeautyatelier.com/"),
        icon: Icons.web);
  }

  Widget getDeveloper()
  {
    return getDrawerTiles("Developer",
            ()=> launchURL("https://motrixofficial.wixsite.com/profile"),
        icon: Icons.person_outline);
  }


  //produce the bottom navigation bar
  Widget getBottomNavigationBar()
  {

    return new Theme(
            data: Theme.of(context).copyWith(
                  // sets the background color of the `BottomNavigationBar`
                    canvasColor: Colors.white,
                    // sets the active color of the `BottomNavigationBar` if `Brightness` is light
                    primaryColor: Helpers.fabColor,

                    textTheme: Theme
                        .of(context)
                        .textTheme
                        .copyWith(caption: new TextStyle(color: Colors.black54))
            ), // sets the inactive color of the `BottomNavigationBar`
            child: new BottomNavigationBar(

              currentIndex: bodyIndex,
                items: getBottomNavigationBarItems(),
              onTap: (int index){
                  setState(() {
                    bodyIndex = index;
                  });
              },
            ),
    );
  }

  List<BottomNavigationBarItem> getBottomNavigationBarItems()
  {
    List<BottomNavigationBarItem> items = new List<BottomNavigationBarItem>();
    BottomNavigationBarItem bnbi = new BottomNavigationBarItem(
        icon: Icon(Icons.line_weight),
      title: Text("My Appointments")
    );

    BottomNavigationBarItem bnbi2 = new BottomNavigationBarItem(
        icon: Icon(Icons.bubble_chart),
        title: Text("News")
    );

    BottomNavigationBarItem bnbi3 = new BottomNavigationBarItem(
        icon: Icon(Icons.style),
        title: Text("Our Work")
    );

    items.add(bnbi);
    items.add(bnbi2);
    items.add(bnbi3);

    return items;
  }





  //checking internet
  checkConnectivity() async{
    checkInternet();
  }

  listenForConnectivityChanges()
  {
    subscription = new Connectivity();
    subscription.onConnectivityChanged.listen((ConnectivityResult result) {
      // Got a new connectivity status!
      checkInternet();
      bodyWidgets[0] = getBody();
    });
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
      });
    }
  }


  Widget getHairJobsWidget()
  {
    if(this.hairJobs!=null){
      if(this.hairJobs.length!=0){
        return new ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.all(10.0),
          itemCount: this.hairJobs.length,
          itemBuilder: (BuildContext context, int index){
            TypeOfHairJob tohj =  this.hairJobs.elementAt(index);
            return Card(
              elevation: Helpers.ELEVATION,
                color: Helpers.themeColor,
                shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                child: Padding(
                  padding: const EdgeInsets.only(left:8.0,right: 8.0,top: 8.0),
                  child: Column(
                    children: <Widget>[
                      tohj.getTypeOfHairJobWidget(context,Colors.black),
                      SizedBox(height: 7.5,),
                    ],
                  ),
                )
            );
          },
        );
      }else{
        return noWork();
      }
    }else{
      return new Center(
        child: new CircularProgressIndicator(),
      );
    }
  }

  Widget noWork()
  {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Icon(Icons.work,color: Colors.black38,),
          SizedBox(width: 5.0,),
          new Text("No Work could be found",
            style: TextStyle(
                fontSize: Helpers.TITLE_FONT_SIZE+2,
                color: Colors.black38
            ),),
        ],
      ),
    );
  }

  Widget noNews()
  {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Icon(Icons.bubble_chart,color: Colors.black38,),
          SizedBox(width: 5.0,),
          new Text("No News Found",
            style: TextStyle(
                fontSize: Helpers.TITLE_FONT_SIZE+2,
                color: Colors.black38
            ),),
        ],
      ),
    );
  }






  launchURL(String url) async {

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }







}

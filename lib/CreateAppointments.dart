import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simin_saloon/Buttons/Fancy.dart';
import 'package:simin_saloon/Helpers.dart';
import 'package:simin_saloon/LoggedInUser.dart';

import 'package:simin_saloon/Appointment/TypeOfHairJob.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:simin_saloon/DaySetting/Day.dart';

import 'package:simin_saloon/DaySetting/Time.dart';
import 'package:simin_saloon/Appointment/Appointment.dart';
import 'package:connectivity/connectivity.dart';

import 'package:simin_saloon/ChooseAHairJob.dart';
import 'package:async/async.dart';
import 'package:simin_saloon/ReservedAppointments.dart';
import 'package:simin_saloon/User/User.dart';

import 'package:simin_saloon/Manage/ManageDay.dart';






class CreateAppointment extends StatefulWidget
{
  //this field is not null if the manager is trying to edit the date of an appointment or moving it to another date;
  final Appointment changeThisAppointment;

  //this is when the owner is trying to make an appointment for someone who either does  not have an account or using theirs to make
  final User chosenUser;

  CreateAppointment({this.changeThisAppointment,this.chosenUser});

  @override
  _CreateAppointmentState createState() => new _CreateAppointmentState();
}

class _CreateAppointmentState extends State<CreateAppointment>
{

  String _SelectedDateTime;

  String _nameOfHairJob;


//  Future<List<TypeOfHairJob>> futureHairJobs;
//  List<TypeOfHairJob> hairJobs;

  Day _day;
  TypeOfHairJob selectedTypeOfHairJob;

  DatabaseReference _dayRef;

  Time selectedTime;

  bool loadAgain;
  bool connected;
  int loadForReserveAppointment;


//  FocusNode focusNode;
//  FocusScopeNode focusScopeNode;




  Connectivity subscription;

  List<Time> avTimes;

  int cont = 0;

  CancelableOperation completer;




  var removeListen,addListen,changeListen;
  //initializer
  void initState()
  {


    /// day needs to be set by the day of the database
    /// if there aren't any days for that particular date
    /// then the day is set to default
    /// e.g isOpen is true
    /// working hours is set to default
    /// defaults can be either the times of weekday default or weekend defaults
    /// the boss can change this day
    /// by changing or removing appointments but the user is notified as well;

    if(LoggedInUser.loggedInUser.isNotAVisitor()){
      this._day = Helpers.getDefaultDaySetting(DateTime.now());
      initDayRef();
      avTimes = new List<Time>();
      loadAgain = true;
      connected = false;
      loadForReserveAppointment = 0;
      _SelectedDateTime = Helpers.SELECT_A_DATE;
      setInitialHairJob();
      Helpers.onResultTypeOfHairJob = null;
      connected = true;
      checkConnectivity();
      listenForConnectivityChanges();
    }

    super.initState();

  }


  void setInitialHairJob(){
    if(widget.changeThisAppointment!=null){
      this.selectedTypeOfHairJob = widget.changeThisAppointment.typeOfHairJob;
      this._nameOfHairJob = this.selectedTypeOfHairJob.name;
    }else{
      this._nameOfHairJob = Helpers.CHOOSE_HAIR_JOB_TYPE;
    }
  }


  void resetTypeOfHairJob()
  {
    this._nameOfHairJob = Helpers.CHOOSE_HAIR_JOB_TYPE;
    Helpers.onResultTypeOfHairJob = null;
  }

  checkConnectivity() async{
    var connectivityResult = await (new Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        // I am connected to a mobile network.
        checkInternet();
      } else if (connectivityResult == ConnectivityResult.wifi) {
        // I am connected to a wifi network.
        checkInternet();
      }else{
        // they are not connected
        checkInternet();
      }
  }

  listenForConnectivityChanges()
  {
    subscription = new Connectivity();
        subscription.onConnectivityChanged.listen((ConnectivityResult result) {
      // Got a new connectivity status!
          checkInternet();

//            if (result == ConnectivityResult.mobile) {
//              // I am connected to a mobile network.
//              if(super.mounted){
//                setState(() {
//                  connected = true;
//
//                });
//              }
//
//
//            } else if (result == ConnectivityResult.wifi) {
//              // I am connected to a wifi network.
//              if(super.mounted){
//                setState(() {
//                  connected = true;
//
//                });
//              }
//
//            }else{
//              // they are not connected
//              if(super.mounted){
//                setState(() {
//                  connected = false;
//                });
//              }
//
//            }


    });
  }

//  getHairJobs()
//  {
//    this.futureHairJobs = Helpers.getFutureHairJobs();
//    this.futureHairJobs.then((List<TypeOfHairJob> hjs){
//      setState(() {
//        this.hairJobs = hjs;
//      });
//    });
//  }




  void initDayRef()
  {

    this._dayRef = FirebaseDatabase.instance.reference().
    child(Helpers.DATE).
    child(this._day.getYearOfDateTime()).
    child(this._day.getMonthOfDateTime()).
    child(this._day.getDayOfDateTime());


    updateRef();



    if(cont==0){
      // to refresh the list multiple times!
      changeListen = _dayRef.onChildChanged.listen(onChildEventDayRef);
      addListen = _dayRef.onChildAdded.listen(onChildEventDayRef);
      removeListen = _dayRef.onChildRemoved.listen(onChildEventDayRef);
      _dayRef.keepSynced(true);
      cont++;
    }

  }


  Future<Null> updateRef() async
  {
    await this._dayRef.once().then((DataSnapshot dataSnapshot){

      if(dataSnapshot.value!=null){
        setState(() {
            if(dataSnapshot.value[Helpers.IS_OPEN]!=null){
              this._day.toDay(dataSnapshot.value);
              this.loadAgain = false;
              updateTimes();
            }else{
              this._day = Helpers.getDefaultDaySetting(_day.dateTime);
              this._day.appointments = Day.dataToAppointment(dataSnapshot.value[Helpers.APPOINTMENTS]);
              this.loadAgain = false;
              updateTimes();
            }
        });
      }
      else{
        setState(() {
            this._day = Helpers.getDefaultDaySetting(_day.dateTime);
            this.loadAgain = false;
            updateTimes();
        });

      }

    });
  }

  void updateTimes()
  {
    if(!this._SelectedDateTime.contains(Helpers.SELECT_A_DATE)&&this.selectedTypeOfHairJob!=null) {
      if (!loadAgain) {
        avTimes = Time.getAvailableAppointmentTimes(this._day, double.parse( this.selectedTypeOfHairJob.timeItTakes));
      }
    }

  }



  //if someone picks the appointment before them
  onChildEventDayRef(Event event) {

      if (event.snapshot.value!=null) {
        this.loadAgain = true;
        this.initDayRef();
      }

  }


  checkInternet() async
  {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if(mounted){
          setState(() {
            connected = true;
          });
        }

      }
    } on SocketException catch (_) {
      if(mounted){
        setState(() {
          connected = false;
        });
      }
    }
  }







    //produces the scaffold of the createAppointment
    @override
    Widget build(BuildContext context) {
      // TODO: implement build
      return Hero(
        tag: Helpers.FAB_TAG_HERO,
        child: new Scaffold(
            appBar: getAppBar(context),
            body: Builder(
                builder: (BuildContext context) {
                  return getBody(context);
                }
            ),
            backgroundColor: getBackgroundColor(),
            resizeToAvoidBottomPadding: true,
        ),
      );
    }

    Color getBackgroundColor()
    {
      switch(this.loadForReserveAppointment){

        case Helpers.LOADING_STATE:
          return Colors.blue;
          break;
        case Helpers.SUCCESSFUL_STATE:
          return Colors.green;
          break;
        case Helpers.FAILED_STATE:
          return Colors.red;
          break;
        default:
          return Helpers.themeColor;
          break;
      }
    }

    //produces the app bar of Create Appointment
    Widget getAppBar(BuildContext context)
    {
        return new AppBar(
          backgroundColor: getBackgroundColor(),
          centerTitle: true,
          elevation: 0.0,
          actions: <Widget>[
            Builder(
                builder: (BuildContext context)
                {
                  return getBossActions(context);
                }
            ),
          ],
          title: new Text("Appointment"),
        );
    }

    Widget getBossActions(BuildContext context)
    {
      if(LoggedInUser.loggedInUser.boss&&this.widget.changeThisAppointment==null){
        return new PopupMenuButton<String>(
            onSelected: (String s){
              selectBossOptions(s,context);
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) {
              return Helpers.BOSS_SETTINGS.map((String m){
                return new PopupMenuItem<String>(
                  value: m,
                  child: new Text(m),
                );
              }).toList();
            });
//        return new FlatButton.icon(
//            onPressed: (){
//              if(chosenDate()){
//                //launch the activity
//                Navigator.push(context, MaterialPageRoute(builder: (context) => ( ReservedAppointments(_day))));
//              }else{
//
//              }
//            },
//            icon: Icon(Icons.date_range),
//            label: new Text("Reserved"));
      }else{
        return SizedBox();
      }
    }

    selectBossOptions(String s,BuildContext context)
    {
      if(chosenDate()){
        switch(s)
        {
          case Helpers.RESERVED_APPOINTMENTS:
            Navigator.push(context, MaterialPageRoute(builder: (context) => ( ReservedAppointments(_day))));
            break;
          case Helpers.DAY_SETTINGS:
            Navigator.push(context, MaterialPageRoute(builder: (context) => ( ManageDay(_day))));
            break;
        }
      }else{
        Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("Choose a date please!",textAlign: TextAlign.center,)));
      }

    }


    //produces the body of the scaffold createAppointment
    Widget getBody(BuildContext context)
    {
      if(!LoggedInUser.loggedInUser.isNotAVisitor()){
        return GestureDetector(
          onTap: (){
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/homepage');
          },
          child: getCarded("Tap here to sign up first !",Icons.verified_user),
        );
      }
      else if(this.loadForReserveAppointment==Helpers.LOADING_STATE){
        return Center(child: CircularProgressIndicator());
      }
      else if(this.loadForReserveAppointment == Helpers.SUCCESSFUL_STATE){
        return infoUpdate("Successful!",Icons.done_all);
      }
      else if(this.loadForReserveAppointment == Helpers.FAILED_STATE){
        return infoUpdate("Sorry we could not reserve an appointment right now. Try agian later",Icons.error);
      }
      else if(connected){
        return  new Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            reservingFor(),
            Expanded(child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: showAvailableTimes(context)),
              ],
            )),
            getDatePickerButton(context),
            chooseAHairJob(context),
          ],
        );
      }else{
        return getCarded("No internet detected",Icons.perm_scan_wifi);
      }

    }


    Widget reservingFor()
    {
      if(widget.chosenUser!=null){
        return new Text("Reserving Appointment for \""+widget.chosenUser.fullName()+"\"");
      }else{
        return SizedBox();
      }
    }

    Widget infoUpdate(String text, IconData id)
    {
      return SafeArea(
        child: Center(
          child: new Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Icon(id,color: Colors.white,),
              new Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white,fontSize: Helpers.TITLE_FONT_SIZE),)
            ],
          ),
        ),
      );
    }

    //produces a list of available times
    Widget showAvailableTimes(BuildContext context)
    {
      if(!this._SelectedDateTime.contains(Helpers.SELECT_A_DATE)&&!this._nameOfHairJob.contains(Helpers.CHOOSE_HAIR_JOB_TYPE)){
        if(!loadAgain){
          return showTimes(context);
        }
        else{
          return Center(child: CircularProgressIndicator(),);
        }
      }
      else{
        if(this._SelectedDateTime.contains(Helpers.SELECT_A_DATE)){
          //choose date
          return getCarded("Choose a date",Icons.calendar_today);
        }
        else{
          //choose a tohj
          return getCarded("Choose a hair job",Icons.gesture);
        }

      }

    }

    Widget getCarded(String text,IconData icon)
    {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 0.0,
            color: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Icon(icon,color: Helpers.themeColor),
                    SizedBox(width: 6.0,),
                    new Text(text,textAlign: TextAlign.center, style:
                    TextStyle(
                        fontSize: Helpers.TITLE_FONT_SIZE,
                      color: Helpers.themeColor
                    )
                    ),
                  ],
                )
            )
        ),
      );
    }

    Widget showTimes(BuildContext context)
    {
      if(!this._day.isOpen){
        return getCarded("Sorry, we are not open",Icons.close);
      }else{
        if(avTimes.isEmpty){
          return getCarded(Helpers.NO_MORE_APPOINTMENT,Icons.indeterminate_check_box);
        }else{
          return getAvailableAppointments();
        }
      }
    }




  Widget getAvailableAppointments()
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 0.0,
        color: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Icon(Icons.access_time,color: Colors.white,),
                  SizedBox(width: 5.0,),
                  new Text("Available Times",textAlign: TextAlign.center,style: new TextStyle(color:Colors.white,fontSize: 17),),
                ],
              ),
              SizedBox(height: 10.0,),
              Expanded(
                child: GridView.count(
                    // Create a grid with 2 columns. If you change the scrollDirection to
                    // horizontal, this would produce 2 rows.
                    crossAxisCount: 2,
                    shrinkWrap: true,

                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    children: getListOfWidgets(),
                  ),
              ),
            ],
          ),
        ),

      ),
    );
  }

  List<Widget> getListOfWidgets()
  {
    List<Widget> low = new List<Widget>();
    for(int i = 0;i<this.avTimes.length;i++) {
      low.add(getButtonOfTime(avTimes[i],context));
    }
    return low;
  }


    Widget getButtonOfTime(Time time,BuildContext context)
    {
      if(time.tap==1){
        // they have already pressed it
        return getStateOfTime(time,context);
      }
      else{
        return GestureDetector(
          onTap: (){
            setState(() {
              time.tap++;
            });
          },
          child: new Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: time.getColor(),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Icon(time.getIcon()),
                        new SizedBox(width: 5.0,),
                        new Text(time.showTime()),
                      ]
                  ),
                  time.bossEye(context,_day)
                ],
              ),
            ),
          ),
        );
      }
    }


    Widget getStateOfTime(Time time,BuildContext context)
    {
      if(LoggedInUser.loggedInUser.boss){
        return availableState(time,context);
      }else{
        switch(time.state)
        {
          case 0:
            return availableState(time,context);
            break;
          case 1:
            return closeState(time);
            break;
          case 2:
            return negotiableState(time);
            break;
          default:
            return availableState(time,context);
            break;
        }
      }
    }


  Widget closeState(Time time)
  {
    return Card(

      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child:
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text("Sorry you can not reserve an appointment at\n"+time.showTime(),textAlign: TextAlign.center,style: TextStyle(fontSize: 16.0),),
              ),
              Padding(
                padding: const EdgeInsets.only(left:8.0,right:8.0),
                child: new Fancy(
                  iconData: Icons.cancel,
                  color: Colors.red,
                  radius: 100.0,
                  onTap: (){
                    setState(() {
                      time.tap--;
                    });
                  },
                ),
              )
            ],
          ),
    );
  }

  Widget negotiableState(Time time)
  {
    return Card(

      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child:
      Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left:8.0,right:8.0,top: 8.0),
            child: new Text("The owner might be able to reserve this appointment for you, please contact them to make sure.",textAlign: TextAlign.center,style: TextStyle(fontSize: 16.0),),
          ),
           Padding(
             padding: const EdgeInsets.only(left:8.0,right:8.0),
             child: new Fancy(
                iconData: Icons.cancel,
                color: Colors.red,
                radius: 100.0,
                onTap: (){
                  setState(() {
                    time.tap--;
                  });
                },
          ),
           )
        ],
      ),
    );
  }





    Widget availableState(Time time, BuildContext context)
    {
      return Card(

        elevation: 10.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Text("Are you sure you want to make an appointment at \n"+time.showTime()+"?",textAlign: TextAlign.center,style: TextStyle(fontSize: 16.0),),
            ),
            Padding(
              padding: const EdgeInsets.only(left:8.0,right:8.0),
              child: new Row(
                children: <Widget>[
                  Expanded(
                    child: new Fancy(
                      iconData: Icons.check,
                      color: Colors.green,
                      radius: 100.0,
                      onTap: (){
                        setState(() {
                          if(LoggedInUser.loggedInUser.isNotAVisitor()){
                            reserveAppointment(time,context);
                          }else{
                            signUpSnackBar(context);
                          }

                        });
                      },
                    ),
                  ),
                  new SizedBox(width: 10.0,),
                  Expanded(
                    child: new Fancy(
                      iconData: Icons.cancel,
                      color: Colors.red,
                      radius: 100.0,
                      onTap: (){
                        setState(() {
                          time.tap--;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    }


    void signUpSnackBar(BuildContext context)
    {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("You need to sign up first!"),
        action: new SnackBarAction(label: "Sign up", onPressed: (){
          Navigator.pushReplacementNamed(context, '/homepage');
        }),
      ));
    }





    //produces the button to open a date picker
    Widget getDatePickerButton(BuildContext context)
    {
      return Padding(
        padding: const EdgeInsets.only(left:8.0,right: 8.0),
        child: new Fancy(
          text: _SelectedDateTime,
          spaceBetweenTI: 10.0,
          radius: 100.0,
          elevation: 0.0,
          textColor: Colors.white,
          color: Colors.black,
          iconData: Icons.calendar_today,
          onTap: ()=>selectDateFromPicker(context),
        ),
      );
    }

    //choose a date from the date picker
    Future<Null> selectDateFromPicker(BuildContext context) async {
      DateTime selected = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(Helpers.yearStart),
        lastDate: new DateTime(Helpers.yearEnd),
      );

      if (selected != null) {
        DateTime convert = new DateTime(selected.year,selected.month,selected.day,23,59,59);
        if(convert.isBefore(DateTime.now())){
          //they cant choose appointments before today obviously right??!!!

          Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("You can not choose a date before today!",textAlign: TextAlign.center,)));
        }else {
          setState(() {
            this._day.setDateTime(selected);
            _SelectedDateTime = this._day.showDateTime();
            loadAgain = true;
            initDayRef();
            if(this.selectedTypeOfHairJob!=null&&this.selectedTypeOfHairJob.isNotProvided(selected).isNotEmpty){
              resetTypeOfHairJob();
            }
          });
        }
      }
    }



    Widget chooseAHairJob(BuildContext context)
    {
        return Padding(
          padding: const EdgeInsets.only(left:8.0,right:8.0),
          child: new Fancy(
            text: this._nameOfHairJob,
            spaceBetweenTI: 10.0,
            radius: 100.0,
            elevation: 0.0,
            color: Colors.black,
            textColor: Colors.white,
            iconData: Icons.gesture,
            onTap: ()=> chooseAHairJobActivity(context),
          ),
        );
    }




    //set the name of hair job
    Future chooseAHairJobActivity(BuildContext context) async
    {
      if(chosenDate()){
        await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => (ChooseAHairJob(this._day.dateTime)))
        ).then((var val){
          if(Helpers.onResultTypeOfHairJob!=null) {
            setState(() {
              this.selectedTypeOfHairJob = Helpers.onResultTypeOfHairJob;
              this._nameOfHairJob = Helpers.cutN(this.selectedTypeOfHairJob.name,20) ;
              updateTimes();
              //search the ref
            });
          }
        });
      }else{
        //plz choose a date
        Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("Choose a date please!",textAlign: TextAlign.center,)));
      }

    }

  DatabaseReference userRef(String ref)
  {
    return FirebaseDatabase.instance.reference().
    child(Helpers.USERS).child(ref).child(Helpers.APPOINTMENTS);
  }




    Future reserveAppointment(Time st,BuildContext context) async
    {
      loadForReserveAppointment = Helpers.LOADING_STATE;
      //adding it to the database
      Appointment appointment = getAppointment(st);
      //adding it to their own account
      //insertion sort
      this._day.appointments = Appointment.insertSortTime(this._day.appointments, appointment);

      checkInternet();
      if(connected){
        await _dayRef.child(Helpers.APPOINTMENTS).runTransaction((transaction) async{
          bool ISA = true;

            List<Appointment> appointments = Day.dataToAppointment(await transaction.value);
            ISA = isStillAvailable(appointments,appointment);

            if(ISA||(LoggedInUser.loggedInUser.boss&&st.state!=0)){
              //UPDATE THE VALUE
              appointments = Appointment.insertSortTime(appointments, appointment);
              transaction.value = (Day.appointmentJsonStatic(appointments));
            }else{
              this.loadForReserveAppointment = Helpers.FAILED_STATE;
              //show them error
            }

            return transaction;

        }).timeout(Duration(seconds: 3),onTimeout: (){
              setState(() {
                this.loadForReserveAppointment = Helpers.FAILED_STATE;
                FirebaseDatabase.instance.purgeOutstandingWrites().whenComplete((){
                  print("removed writes");
                });

              //  this._day.appointments.remove(appointment);
                //removeById(appointment);
               // _dayRef.child(Helpers.APPOINTMENTS).set(this._day.appointmentJson());
              });
        }).whenComplete((){
              setState(() {
                if(this.loadForReserveAppointment!=Helpers.FAILED_STATE){
                  //add the appointment for the user
                  appointment.addAppointmentToUserDataBase(userRef(appointment.user.uid), appointment,widget.changeThisAppointment,context);
                  //updateUserAppointments();
                  this.loadForReserveAppointment = Helpers.SUCCESSFUL_STATE;
                }else{
//                  this._day.appointments.remove(appointment);
//                  _dayRef.child(Helpers.APPOINTMENTS).update(this._day.appointmentJson());
//                  return false;
                }
              });}).catchError((e){
          setState(() {
            this.loadForReserveAppointment = Helpers.FAILED_STATE;
          });

        });

      }else{
        setState(() {
          this.loadForReserveAppointment = Helpers.FAILED_STATE;
        });
      }
    }

    void removeById(Appointment appointment)
    {
      for(Appointment app in this._day.appointments){
        if(app.id==appointment.id){
          this._day.appointments.remove(app);
        }
      }
    }


    bool isStillAvailable(List<Appointment> appointments,Appointment app)
    {

      for(int i = 0;i<appointments.length;i++){
        if(!appointments[i].deleted&&Time.timeCoincide(app.getTime(), appointments[i].getTime())!=0){
          return false;
        }
      }
      return true;
    }






    Appointment getAppointment(Time st)
    {
      DateTime cv = new DateTime(
        this._day.dateTime.year,
        this._day.dateTime.month,
        this._day.dateTime.day,
        23,59,59
      );
      if(widget.changeThisAppointment!=null){
        return new Appointment(cv, this.selectedTypeOfHairJob, st, widget.changeThisAppointment.user);
      } else if(widget.chosenUser!=null){
        return new Appointment(cv, this.selectedTypeOfHairJob, st, widget.chosenUser);
      }
      return new Appointment(cv, this.selectedTypeOfHairJob, st, LoggedInUser.loggedInUser);
    }


    //gets an id from appointment and deletes it on that day
    void removeId(String id)
    {
      for(int i = 0;i<this._day.appointments.length;i++){
        Appointment ap = this._day.appointments[i];
        if(ap.id==(id)){
          if(ap.user.getUID()==(LoggedInUser.loggedInUser.getUID())){
            this._day.appointments[i].deleted = true;
            break;
          }
        }
      }

      for(int i = 0;i<LoggedInUser.loggedInUser.appointments.length;i++){
        Appointment ap = LoggedInUser.loggedInUser.appointments[i];
        if(ap.id==(id)){
          LoggedInUser.loggedInUser.appointments[i].deleted = true;
        }
      }
    }



    // returns true if they have chosen a date
    bool chosenDate()
    {
      return !this._SelectedDateTime.contains(Helpers.SELECT_A_DATE);
    }



  @override
  void dispose()
  {
    // Clean up the focus node when the Form is disposed
    if(removeListen!=null){
      removeListen.cancel();
      addListen.cancel();
      changeListen.cancel();
      _dayRef.onDisconnect();
    }


    super.dispose();
  }






  }






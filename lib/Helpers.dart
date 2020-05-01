

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simin_saloon/Appointment/TypeOfHairJob.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:simin_saloon/DaySetting/Day.dart';
import 'package:simin_saloon/DaySetting/Time.dart';
import 'package:simin_saloon/Appointment/Appointment.dart';
import 'package:simin_saloon/LoggedInUser.dart';

class Helpers{

  //static Color themeColor = Colors.cyan[200];
  static Color themeColor = Colors.white;
  static Color rejectColor = Colors.redAccent;
  static Color acceptColor = Colors.green;
  static Color fabColor = Colors.black;

  static const double ELEVATION = 3.0;

  //ratio for reserving
  static const double OK_RATIO = 1/6;

  //Random object
  static Random random = new Random();

  //List of available times in String
  static List<String> availableTimes = new List();

  //on-result data
  static TypeOfHairJob onResultTypeOfHairJob;





  static const String DATE = "Dates";

  //constant fields
  //Strings
  static const String ID = "Id";
  static const String NAME = "Name";
  static const String LAST_NAME = "LastName";
  static const String PHONE_NUMBER = "PhoneNumber";
  static const String UID = "uid";
  static const String DELETED = "Deleted";
  static const String NOTIFICATION_TOKEN = "NotificationToken";

  //database references
  static const String TYPE_OF_HAIR_JOB = "TypeOfHairJob";
  static const String USERS = "User";
  static const String BOSS = "Boss";
  static const String SWITCH = "Switch";
  static const String NEWS = "News";
  static const String BLOCKED_NUMBERS = "BlockedNumbers";


  static const String DATE_TIME = "DateTime";
  static const String DESCRIPTION = "Description";
  static const String TIME_IT_TAKES = "Time It Takes";
  static const String PRICE = "Price";
  static const String NOT_PROVIDED = "NotProvided";
  static const String INDEX = "Index";


  static const String HAS_IMAGE = "hasImage";
  static const String URL = "url";

  static const String CHOOSE_HAIR_JOB_TYPE = "Choose Hair Job";

      //genders
  static const String GENDER = "GENDER";
  static const String MALE = "Male";
  static const String FEMALE = "Female";
  static const String NOT_SPECIFIED = "NA";
  static const String BOTH = "Both";
  static const String CHOOSE_GENDER = "Choose Gender";

  //list of genders
  static const List<String> GENDERS = [Helpers.MALE,Helpers.FEMALE,Helpers.BOTH,Helpers.NOT_SPECIFIED];


  //week days
  static const String MONDAY = "Monday";
  static const String TUESDAY = "Tuesday";
  static const String WEDNESDAY = "Wednesday";
  static const String THURSDAY = "Thursday";
  static const String FRIDAY = "Friday";
  static const String SATURDAY = "Saturday";
  static const String SUNDAY = "Sunday";

  static const String SELECT_A_DATE = "Select a date";

  //list of weekdays
  static var weekdays = [MONDAY,TUESDAY,WEDNESDAY,THURSDAY,FRIDAY,SATURDAY,SUNDAY];


  //Doubles for size fonts

  static const double SIZE_VARIABLE = 4;
  static const double FONT_SIZE = 16;
  static const double TITLE_FONT_SIZE = FONT_SIZE + SIZE_VARIABLE;
  static const double DESCRIPTION_FONT_SIZE = FONT_SIZE - SIZE_VARIABLE;



  //Error Codes
  static const String NAME_ERROR_EMPTY = "The name can not be empty";
  static const String PRICE_ERROR_EMPTY = "The price can not be empty";
  static const String TIME_ERROR_EMPTY = "The time can not be empty";
  static const String GENDER_ERROR_EMPTY = "Please choose a gender";
  static const String NEED_INTERNET = "Please Connect to internet to verify";
  static const String DESCRIPTION_ERROR_EMPTY = "Description of a news can not be empty";




  //day refrences
  static const String IS_OPEN =  "IsOpen";
  static const String APPOINTMENTS = "Appointments";
  static const String WORKING_HOURS = "WorkingHours";



  //widgets
  static const Widget EMPTY_BOX = SizedBox(height: 0.0, width: 0.0);



  //hero animation tags
  static const String FAB_TAG_HERO = "FAB_TAG_HERO";
  static const String CHOOSE_USER_TAG_HERO = "CHOOSE_USER_TAG_HERO";
  static const String BACK_TAG_HERO = "BACK_TAG_HERO";



  //communication
  static const String SUCCESSFUL_DELETE = "Appointment was successfully deleted!";
  static const String FAILED_DELETE = "Sorry we could not delete the appointment."
      " Make sure you are connected to internet.";

  //Text of Widgets
  static const String CREATE = "Create";
  static const String EDIT = "Edit";



  //Time
  static const String AM = "am";
  static const String PM = "pm";
  static const double ROUND_LIMIT = 15.0;
  static const String START_TIME = "startTime";
  static const String END_TIME = "endTime";



  //appointments
  static const String NO_MORE_APPOINTMENT = "Sorry we are full!";
  static const int MAX_SIZE_APPOINTMENTS = 20000;


  //states
  static const int LOADING_STATE = 39402111;
  static const int FAILED_STATE  = -912481;
  static const int SUCCESSFUL_STATE = 912481;



  static const String RESERVED_APPOINTMENTS = "Reserved Appointments";
  static const String DAY_SETTINGS = "Day Setting";
  static const List<String> BOSS_SETTINGS = [Helpers.RESERVED_APPOINTMENTS,Helpers.DAY_SETTINGS];



  //Widget Functions
  static void getSnackBar(String text,BuildContext context)
  {
    Scaffold.of(context).showSnackBar(
        new SnackBar(
            content: new Text(
              text,
              textAlign: TextAlign.center,
            )));
  }





  //Helper Functions

  //Generate Random Id based on the given info
  static String generateRandomId()
  {
    int randomId = random.nextInt(1000000000);
    int randomId1 = random.nextInt(1000000000);
    int randomId2 = random.nextInt(1000000000);

    String idToString = randomId.toString()+randomId1.toString()+randomId2.toString();
    return idToString;
  }


  //get the hair jobs from the database
  static Future<List<TypeOfHairJob>> getFutureHairJobs() async
  {
    //getting the hair jobs from data base one by one
    //parsing and then adding it to the list
    List<TypeOfHairJob> hairJobs = new List();
    await FirebaseDatabase.instance.reference().child(Helpers.TYPE_OF_HAIR_JOB).once().then((DataSnapshot data){
      Map<dynamic,dynamic> map = data.value;
      map.forEach((dynamic k, dynamic v){
        TypeOfHairJob typeOfHairJob = new TypeOfHairJob("", "", "", "", "");
        typeOfHairJob.toTypeOfHairJob(v);
        if(!typeOfHairJob.isDeleted()){
          hairJobs.add(typeOfHairJob);
        }
      });
    });
    return hairJobs;
  }




  //produce the numbers of the string only am and pm matters
//  static int getNumbers(String str)
//  {
//    String numbers = "";
//    var unicodes = str.codeUnits.toList();
//    for(int i = 0; i<str.length; i++){
//      if(isNumber(unicodes[i])){
//        numbers+=str.substring(i,i+1);
//      }
//    }
//
//    if(str==(PM)){
//      return 1200 + int.parse(numbers);
//    }else{
//      return int.parse(numbers);
//    }
//  }

  //returns true if the given char is a number
  static bool isNumber(var a)
  {
    return (a>=48&&a<=57);
  }




  // takes an integer and returns the default setting for that day
  static const double AM_11 = 1100;
  static const double PM_5 = 1700;
  static Time WH_TIME_SUNDAYS = new Time(AM_11, PM_5);

  static const double AM_9 = 900;
  static const double PM_7 = 1900;
  static Time WH_TIME_BUT_SUNDAY = new Time(AM_9, PM_7);

  static Day getDefaultDaySetting(DateTime dt)
  {
    if(dt.weekday==7){
      return Day(dt, WH_TIME_SUNDAYS, null);
    }
    else{
      return Day(dt, WH_TIME_BUT_SUNDAY, null);
    }
  }



  //get and set the appointments of the user
  static Future<int> getAppointments(DatabaseReference ref) async
  {
    List<Appointment> appointments = new List<Appointment>();
    ref.once().then((DataSnapshot snap){
      if(snap.value!=null){
        appointments = Day.dataToAppointment(snap.value);
        LoggedInUser.loggedInUser.appointments = new List<Appointment>();
        for(int i = 0;i<appointments.length;i++){
          if(!appointments.elementAt(i).deleted){
            LoggedInUser.loggedInUser.appointments.add(appointments[i]);
          }
        }
        return 1;
      }
    });
    return 0;
  }


  //if the given string has length>10 return a substring of length 10 + ...
  static String cut10(String s)
  {
    return cutN(s,10);
  }


  static String cutN(String s, int n)
  {
    if(s.length>n){
      return s.substring(0,n) + "...";
    }
    return s;
  }


  // takes a phone number and makes it fancier like 6053294111 -> 605-329-4111

  static String makeFancy(String pn)
  {
    if(pn.length==10){
      return pn.substring(0,3) + "-" + pn.substring(3,6) + "-" + pn.substring(6);
    }
    return pn;
  }




  static const int yearEnd = 2025;
  static const int yearStart  = 2018;










}
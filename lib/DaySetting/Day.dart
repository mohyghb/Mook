import 'package:simin_saloon/DaySetting/Time.dart';
import 'package:simin_saloon/Appointment/Appointment.dart';
import 'package:simin_saloon/Helpers.dart';


class Day{

  //whether the saloon is open or not
  bool _isOpen;


  // the complete \ date of the day
  DateTime _dateTime;



  // start and finish time of that day
  Time _workingHours;

  // appointments of that day
  List<Appointment> _appointments;



  Day(DateTime dt, Time wh, List<Appointment> apts)
  {
    this._dateTime = dt;
    this._workingHours = wh;

    if(apts==null){
      this._appointments = new List<Appointment>();
    }else{
      this._appointments = apts;
    }

    this._isOpen = true;
  }


  Time get workingHours => _workingHours;

  set workingHours(Time value) {
    _workingHours = value;
  }

  bool get isOpen => _isOpen;

  set isOpen(bool value) {
    _isOpen = value;
  }

  //produces an string which only contains the date of DateTime
  String showDateTime()
  {
    String dt_str = this.dateTime.toString();
    List<String> sep_dt_str = dt_str.split(" ");
    return sep_dt_str.first;
  }

  DateTime get dateTime => _dateTime;

  void setDateTime(DateTime value) {
    _dateTime = value;
  }



  String getDayOfDateTime()
  {
    return this.dateTime.day.toString();
  }

  String getMonthOfDateTime()
  {
    return this.dateTime.month.toString();
  }

  String getYearOfDateTime()
  {
    return this.dateTime.year.toString();
  }

  List<Appointment> get appointments => _appointments;

  set appointments(List<Appointment> value) {
    _appointments = value;
  }


  toJson(){
   return{
     Helpers.IS_OPEN:_isOpen,
     Helpers.APPOINTMENTS:appointmentJson(),
     Helpers.WORKING_HOURS:_workingHours.toJson(),
     Helpers.DATE_TIME:showDateTime(),
   };

  }

  appointmentJson()
  {
    Map<String, Map> map = new Map();
    if(_appointments!=null){
      for(int i =0;i<_appointments.length;i++){
        map.putIfAbsent(i.toString(), ()=>_appointments[i].toJson());
      }
    }
    return map;
  }

  static appointmentJsonStatic(List<Appointment> appointments)
  {
    Map<String, Map> map = new Map();
    if(appointments!=null){
      for(int i =0;i<appointments.length;i++){
        map.putIfAbsent(i.toString(), ()=>appointments[i].toJson());
      }
    }
    return map;
  }

  DateTime getDateTimeFromString(String data)
  {
    List<String> split = data.split("-");
    return new DateTime(int.parse(split[0]),int.parse(split[1]),int.parse(split[2]));
  }


  toDay(dynamic data)
  {
    try{
      this._isOpen = data[Helpers.IS_OPEN];
      this._workingHours = new Time(0, 0);
      _workingHours.toTime(data[Helpers.WORKING_HOURS]);
      this._dateTime = getDateTimeFromString(data[Helpers.DATE_TIME]);
    }catch(e){

    }
    try{
      this._appointments = dataToAppointment(data[Helpers.APPOINTMENTS]);
    }catch(e){

    }

  }


  static List<Appointment> dataToAppointment(dynamic map)
  {
    List<Appointment> appointments = new List<Appointment>();

    for(int i = 0;i<Helpers.MAX_SIZE_APPOINTMENTS;i++){
      try{
        dynamic value = map[i];
        if(value!=null){
          Appointment appointment = new Appointment(null, null, null, null);
          appointment.toAppointment(value);
          appointments.add(appointment);
        }
        else{
          break;
        }
      }catch(e){
        break;
      }
    }


    return appointments;
  }


  static List<Appointment> dataToAppointmentUser(dynamic map)
  {
    List<Appointment> appointments = new List<Appointment>();

    for(int i = 0;i<Helpers.MAX_SIZE_APPOINTMENTS;i++){
      try{
        dynamic value = map[i];
        if(value!=null){
          Appointment appointment = new Appointment(null, null, null, null);
          appointment.toAppointmentForUser(value);
          appointments.add(appointment);
        }
        else{
          break;
        }
      }catch(e){
        break;
      }
    }


    return appointments;
  }

/// add toJson and toDay functions
/// upload and download info for the day class



  int inSessionAppointments()
  {
    int count = 0;
    for(int i = 0;i<this.appointments.length;i++){
      if(!appointments[i].deleted){
        count++;
      }
    }
    return count;
  }

}
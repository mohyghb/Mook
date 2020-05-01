import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simin_saloon/Buttons/Fancy.dart';
import 'package:simin_saloon/Helpers.dart';
import 'package:simin_saloon/Appointment/TypeOfHairJob.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:simin_saloon/Upload/UploadingScreen.dart';
import 'package:simin_saloon/Appointment/WeekDay.dart';
import 'package:simin_saloon/Create/NotProvidedDays.dart';

/// names can not contain symbol only letters

class NewHairJob extends StatefulWidget
{
  TypeOfHairJob tohj;
  NewHairJob({this.tohj});
  @override
  _NewHairJobState createState() => new _NewHairJobState();
}

class _NewHairJobState extends State<NewHairJob>
{

  //text controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _timeItTakesController = TextEditingController();


  TypeOfHairJob typeOfHairJob;


  List<WeekDay> notProvidedList;

  //for picking an image or video
  File sampleImage;

  Future getImage() async {
    var tempImage;
    try{
       tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    }catch(e){
      print(e);
    }
    setState(() {
      if(tempImage!=null){
        sampleImage = tempImage;
      }
    });
  }

  Widget showImage() {
    if(this.sampleImage!=null){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
            elevation: 1.0,
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image(image: Image.file(sampleImage).image ,),
            )
        ),
      );
    }
    else if(this.isChanging){
      return widget.tohj.showImage(context,Colors.black);
    }
    else{
      return SizedBox();
    }
  }



  bool isChanging;
  String
      _name_HJ,
      _description_HJ,
      _price_HJ,
      _timeItTakesHJ,
      _gender
  ;

  //initializer
  void initState()
  {
    initVars();
    super.initState();
  }

  //init all the vars
  void initVars()
  {
    if(widget.tohj!=null){
      //they are changing
      _name_HJ = widget.tohj.name;
      _description_HJ = widget.tohj.description;
      _price_HJ = widget.tohj.price;
      _timeItTakesHJ = widget.tohj.timeItTakes;
      _gender = widget.tohj.gender;

      //add provider
      setControllerValues();
      notProvidedList = widget.tohj.notProvided;

      isChanging = true;
    }else{
      //they are making a new one
      _name_HJ = "";
      _description_HJ = "";
      _price_HJ = "";
      _timeItTakesHJ = "";
      _gender = Helpers.CHOOSE_GENDER;
      isChanging = false;
      notProvidedList = getWeekDays();
    }

  }




  void setControllerValues()
  {
    this._nameController.text = this._name_HJ;
    this._descriptionController.text = this._description_HJ;
    this._priceController.text = this._price_HJ;
    this._timeItTakesController.text = this._timeItTakesHJ;
  }

  void getControllerValues()
  {
    this._name_HJ = this._nameController.text;
    this._description_HJ = this._descriptionController.text ;
    this._price_HJ = this._priceController.text ;
    this._timeItTakesHJ = this._timeItTakesController.text ;
  }

  //produces the scaffold of the createAppointment
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: getAppBar(),
      body: Builder(
        builder: (BuildContext context) {
          return getBody(context);
        }
      ),
      backgroundColor: Theme.of(context).primaryColor,
      resizeToAvoidBottomPadding: true,
    );
  }


  //produce the appbar
  Widget getAppBar()
  {
    return new AppBar(
      elevation: 0.0,
      centerTitle: true,
      title: new Text("New Hair Job"),
    );
  }


  //produces the body of the manger
  Widget getBody(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: SingleChildScrollView(
          child: new Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  getTextFieldForName(),
                  getTextFieldForDescription(),
                  getTextFieldForPrice(),
                  getTextFieldForTime(),
                  getGender(),
                  getButtonForProvided(context),
                  showImage(),
                  getImageButton(context),
                  getButtonForNewHairJob(context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  //get the name TextField
  Widget getTextFieldForName()
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new TextField(
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
            autofocus: false,
            decoration: new InputDecoration(
                icon: Icon(Icons.title),
                labelText: "Enter a Name",
                hintText: "Name",
                hintStyle: TextStyle(
                    fontSize: Helpers.FONT_SIZE)
            ),
      ),
    );
  }
  //set the name of HJ on change
  void changeName(String n){
    this._name_HJ = n;
  }


  //get the description TextField
  Widget getTextFieldForDescription()
  {
    return Padding(
          padding: const EdgeInsets.all(8.0),
          child: new TextField(
            maxLines: 4,
            keyboardType: TextInputType.multiline,
            controller: this._descriptionController,
            enabled: true,
            obscureText: false,
            cursorColor: Theme.of(context).cursorColor,
            cursorWidth: 2,
            style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: Helpers.FONT_SIZE
            ),

            autofocus: false,
            decoration: new InputDecoration(
                icon: Icon(Icons.description),
                labelText: "Enter a Description",
                hintText: "Description (optional)",
                hintStyle: TextStyle(
                    fontSize: Helpers.FONT_SIZE)
            ),
          ),
    );
  }
  //set the description of HJ on change
  void changeDescription(String d){
    this._description_HJ = d;
  }


  //get the price TextField
  Widget getTextFieldForPrice()
  {
    return Padding(
      padding: const EdgeInsets.only(left:8.0,right:8.0,top:8.0),
      child: new TextField(
          //is not working
          keyboardType: TextInputType.numberWithOptions(
              decimal: false,
              signed: false),
          maxLines: 1,
          controller: this._priceController,
          enabled: true,
          obscureText: false,
          cursorColor: Theme.of(context).cursorColor,
          cursorWidth: 2,
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: Helpers.FONT_SIZE
          ),

          autofocus: false,
          decoration: new InputDecoration(
              icon: Icon(Icons.attach_money),
              labelText: "Enter a Price in CAD",
              hintText: "Price (CAD \$)",
              hintStyle: TextStyle(
                  fontSize: Helpers.FONT_SIZE)
          ),
        ),
    );
  }
  //set the price of HJ on change
  void changePrice(String p){
    this._price_HJ = p;
  }


  //get the time TextField
  Widget getTextFieldForTime()
  {
    return Padding(
      padding: const EdgeInsets.only(left:8.0,right:8.0,top:8.0),
      child: new TextField(
          //!!! is not working (negative and decimal not working when set to false)
          keyboardType: TextInputType.numberWithOptions(
              decimal: false,
              signed: false),
          maxLines: 1,
          controller: this._timeItTakesController,
          enabled: true,
          obscureText: false,
          cursorColor: Theme.of(context).cursorColor,
          cursorWidth: 2,
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontSize: Helpers.FONT_SIZE
          ),

          autofocus: false,
          decoration: new InputDecoration(
              icon: Icon(Icons.timelapse),
              labelText: "Enter the time that this takes",
              hintText: "Time to finish (minutes)",
              hintStyle: TextStyle(
                  fontSize: Helpers.FONT_SIZE)
          ),
        ),
    );
  }
  //set the time of HJ on change
  void changeTime(String t){
    this._timeItTakesHJ = t;
  }



  //get the gender
  Widget getGender()
  {
    return new PopupMenuButton<String>(
        onSelected: selectGender,
        child: Padding(
          padding: const EdgeInsets.only(left:8.0,top:8.0,right: 8.0),
          child: new Fancy(
            disabledColor: Colors.black,
            text: this._gender,
            textColor: Colors.white,
            color: Colors.black,
            radius: 20.0,
          ),
        ),
        itemBuilder: (BuildContext context) {
          return Helpers.GENDERS.map((String m){
            return new PopupMenuItem<String>(
              value: m,
              child: new Text(m),
            );
          }).toList();
        });
  }

  //


  //select the gender
  void selectGender(String selected)
  {
    setState(() {
      this._gender = selected;
    });
  }


  //create the button for createNewHairJob
  Widget getButtonForNewHairJob(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Fancy(
        iconData: Icons.add,
        text: getTextForButton(),
        textColor: Colors.white,
        color: Theme.of(context).accentColor,
        radius: 20.0,
        onTap: ()=>checkName(context),
      ),
    );
  }


  Widget getButtonForProvided(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.only(left:8.0,right:8.0,bottom: 8.0),
      child: new Fancy(
        text: getTextForProvided(),
        onTap: ()=> changeNotProvidedDays(context),
        radius: 100,
        color: Colors.black,
        textColor: Colors.white,
      ),
    );
  }



  Future changeNotProvidedDays(BuildContext context) async
  {
      await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => (NotProvidedDays(notProvided: this.notProvidedList,)))
      ).then((var val){
          setState(() {
//            this.selectedTypeOfHairJob = Helpers.onResultTypeOfHairJob;
//            this._nameOfHairJob = Helpers.cutN(this.selectedTypeOfHairJob.name,20) ;
//            updateTimes();
            //search the ref
          });
      });
  }

  String getTextForProvided()
  {
    String orig = "What days is this NOT available? (optional)";
    String created = "";

    for(int i = 0;i<this.notProvidedList.length;i++){
      if(this.notProvidedList[i].notProvided){
        created+=this.notProvidedList[i].name.substring(0,3)+" ";
      }
    }

    if(created.isEmpty){
      return orig;
    }else{
      return created;
    }
  }


  //gets the appropriate text for the button
  String getTextForButton()
  {
    if(!this.isChanging){
      return Helpers.CREATE;
    }else{
      return Helpers.EDIT;
    }
  }


  //produce the button for picking images
  Widget getImageButton(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.only(left:8.0,right:8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: new Fancy(
              text: "Select an image",
              onTap: getImage,
              color: Colors.black,
              textColor: Colors.white,
              radius: 100.0,
            ),
          ),
          new SizedBox(width: 10.0,),
          new Fancy(
            iconData: Icons.close,
            color: Colors.red,
            textColor: Colors.white,
            radius: 100.0,
            onTap: (){
              setState(() {
                int i = 0;
                if(this.sampleImage!=null){
                  i++;
                  this.sampleImage = null;
                }
                if(this.isChanging&&widget.tohj.url.isNotEmpty){
                  i++;
                  widget.tohj.url = "";
                }
                if(i>0){
                  Helpers.getSnackBar("Image was removed", context);
                }else{
                  Helpers.getSnackBar("We could not find an image to delete!", context);
                }

              });
            },
          )
        ],
      ),
    );
  }


  //checks to see if the name is provided
  void checkName(BuildContext context)
  {
    getControllerValues();
    if(this._name_HJ.isEmpty){
      Helpers.getSnackBar(Helpers.NAME_ERROR_EMPTY, context);
    }
    else{
      if(this._price_HJ.isEmpty){
        Helpers.getSnackBar(Helpers.PRICE_ERROR_EMPTY, context);
      }else{
        if(this._timeItTakesHJ.isEmpty){
          Helpers.getSnackBar(Helpers.TIME_ERROR_EMPTY, context);
        }else{
          if(this._gender.contains(Helpers.CHOOSE_GENDER)){
            Helpers.getSnackBar(Helpers.GENDER_ERROR_EMPTY, context);
          }else{
            createNewHairJob(context);
          }

        }
      }
    }
  }

  //create a new HairJob
  void createNewHairJob(BuildContext context)
  {
      typeOfHairJob =
                                  new TypeOfHairJob(
                                      this._nameController.text,
                                      this._descriptionController.text,
                                      this._gender,
                                      this._priceController.text,
                                      this._timeItTakesController.text);
      typeOfHairJob.notProvided = this.notProvidedList;
    if(this.isChanging){
      typeOfHairJob.id = widget.tohj.id;
    }
    updateHairJobs(context);
  }

  //publish the newly created HairJob
  updateHairJobs(BuildContext context) async
  {
    bool c = await checkInternet();
    if(c){
      uploadImage();
      FirebaseDatabase.instance.reference().child(Helpers.TYPE_OF_HAIR_JOB)
          .child(typeOfHairJob.id).set(typeOfHairJob.toJson());
    }else{
      Scaffold.of(context).showSnackBar(new SnackBar(backgroundColor:Colors.red,content: new Text("Please connect to internet",textAlign: TextAlign.center,style: TextStyle(color: Colors.white),)));
    }

  }






  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    this._nameController.dispose();
    this._descriptionController.dispose();
    this._priceController.dispose();
    this._timeItTakesController.dispose();
    super.dispose();
  }



  uploadImage() async
  {
    if(this.sampleImage!=null){
      final StorageReference fireBaseStorageRef =
      FirebaseStorage.instance.ref().child(Helpers.TYPE_OF_HAIR_JOB).child(typeOfHairJob.id);
      final StorageUploadTask task =
      fireBaseStorageRef.putFile(sampleImage);


      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => (UploadingScreen(
            task: task,
            typeOfHairJob: this.typeOfHairJob,
          )))
      );
    } else{
      if(this.isChanging){
        typeOfHairJob.url = widget.tohj.url;
      }
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => (UploadingScreen()))
      );
    }

  }














//  //not provided days dialog
//  notProvidedDaysDialog (BuildContext mcontext)
//  {
//    return showDialog<void>(
//      context:  mcontext,
//      builder: (BuildContext context){
//        return new AlertDialog(
//
//          title: new Text("Choose the days on which this hair job is NOT provided",textAlign: TextAlign.center,),
//          content: SingleChildScrollView(
//            child: Column(
//                children: <Widget>[
//                  getDaysOfTheWeekChecker(context),
//                  getProvidedAllDaysButton(context),
//                  new Fancy(
//                    text: "cancel",
//                    radius: 100.0,
//                    onTap: (){
//                      Navigator.pop(context);
//                    },
//                  )
//                ],
//            ),
//          ),
//        );
//      },
//    );
//  }
//
//  Widget getProvidedAllDaysButton(BuildContext context)
//  {
//    return new Fancy(
//      text: "It is provided on all days",
//      radius: 100.0,
//      onTap: (){
//        setState(() {
//          this.notProvidedList = getWeekDays();
//        });
//        Navigator.pop(context);
//      },
//    );
//  }
//
//  Widget getDaysOfTheWeekChecker(BuildContext context)
//  {
//
//    return new ListView.builder(
//      itemCount: notProvidedList.length,
//        shrinkWrap: true,
//        addAutomaticKeepAlives: true,
//        itemBuilder: (BuildContext context, int index){
//        WeekDay day = notProvidedList[index];
//        return Row(
//          children: <Widget>[
//            new Checkbox(
//                value: day.notProvided,
//                onChanged: (bool b){
//                  setState(() {
//                    notProvidedList[index].notProvided = b;
//                    Navigator.pop(context);
//                    notProvidedDaysDialog(super.context);
//                  });
//                }
//            ),
//            new Text(day.name)
//          ],
//        );
//        }
//    );
//  }



  List<WeekDay> getWeekDays()
  {
    List<WeekDay> days = new List<WeekDay>();
    for(int i = 0;i<Helpers.weekdays.length;i++){
      WeekDay day = new WeekDay(Helpers.weekdays[i], i, false);
      days.add(day);
    }
    return days;
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

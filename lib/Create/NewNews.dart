import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simin_saloon/Buttons/Fancy.dart';
import 'package:simin_saloon/Helpers.dart';


import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:simin_saloon/Upload/UploadingScreen.dart';
import 'package:simin_saloon/Appointment/WeekDay.dart';
import 'package:simin_saloon/Create/News.dart';

/// names can not contain symbol only letters

class NewsClass extends StatefulWidget
{
  final News news;
  NewsClass({this.news});
  @override
  _NewsState createState() => new _NewsState();
}

class _NewsState extends State<NewsClass>
{

  //text controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  News typeOfHairJob;


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
            elevation: 0.0,
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
      return widget.news.showImage(context,Colors.black);
    }
    else{
      return SizedBox();
    }
  }



  bool isChanging;


  //initializer
  void initState()
  {
    initVars();
    super.initState();
  }

  //init all the vars
  void initVars()
  {
    if(widget.news!=null){
      this.isChanging = true;
      this._nameController.text = widget.news.title;
      this._descriptionController.text = widget.news.description;
    }else{
      this.isChanging = false;
    }

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
      title: new Text("New News"),
    );
  }


  //produces the body of the manger
  Widget getBody(BuildContext context)
  {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  getTextFieldForName(),
                  getTextFieldForDescription(),
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
      padding: const EdgeInsets.only(left:8.0,right:8.0,top:8.0),
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
          decoration: new InputDecoration(
            icon: Icon(Icons.title,color: Colors.black,),
              hintText: "Title",
              labelText: "Enter a title",
              labelStyle: TextStyle(
                color: Colors.black
              ),
              hintStyle: TextStyle(
                  fontSize: Helpers.FONT_SIZE)
          ),
      ),
    );
  }
  //set the name of HJ on change


  //get the description TextField
  Widget getTextFieldForDescription()
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new TextField(
            keyboardType: TextInputType.multiline,
            controller: this._descriptionController,
            cursorColor: Theme.of(context).cursorColor,
            cursorWidth: 2,
            style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: Helpers.FONT_SIZE
            ),
            maxLines: 6,
            decoration: new InputDecoration(

                hintText: "Description",
                icon: Icon(Icons.description,color: Colors.black,),

                labelText: "Write a description",
                labelStyle: TextStyle(
                  color: Colors.black
                ),
                hasFloatingPlaceholder: true,
                hintStyle: TextStyle(
                    fontSize: Helpers.FONT_SIZE)
            ),
          ),
    );
  }
  //set the description of HJ on change







  //get the gender


  //


  //select the gender



  //create the button for createNewHairJob
  Widget getButtonForNewHairJob(BuildContext context)
  {
    return Padding(
      padding: const EdgeInsets.only(left:8.0,right: 8.0,top: 8.0),
      child: new Fancy(
        iconData: Icons.add,
        text: getTextForButton(),
        radius: 20.0,
        onTap: ()=>checkName(context),
      ),
    );
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
                if(this.isChanging&&widget.news.url.isNotEmpty){
                  i++;
                  widget.news.url = "";
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
    if(this._nameController.text.isEmpty){
      Helpers.getSnackBar(Helpers.NAME_ERROR_EMPTY, context);
    }
    else{
      if(this._descriptionController.text.isEmpty){
        Helpers.getSnackBar(Helpers.DESCRIPTION_ERROR_EMPTY, context);
      }else{
            createNewHairJob();
          }
    }
  }

  //create a new HairJob
  void createNewHairJob()
  {
    typeOfHairJob =
    new News(
        this._nameController.text,
        this._descriptionController.text,
        );

    if(this.isChanging){
      typeOfHairJob.id = widget.news.id;
    }
    updateHairJobs();
  }

  //publish the newly created HairJob
  updateHairJobs() async
  {
    uploadImage();
    FirebaseDatabase.instance.reference().child(Helpers.NEWS)
        .child(typeOfHairJob.id).set(typeOfHairJob.toJson());
    //!!! launch the success menu

    print("done added");
  }






  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    this._nameController.dispose();
    this._descriptionController.dispose();
    super.dispose();
  }



  uploadImage() async
  {
    if(this.sampleImage!=null){
      final StorageReference fireBaseStorageRef =
      FirebaseStorage.instance.ref().child(Helpers.NEWS).child(typeOfHairJob.id);
      final StorageUploadTask task =
      fireBaseStorageRef.putFile(sampleImage);


      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => (UploadingScreen(
            task: task,
            news: this.typeOfHairJob,
          )))
      );
    } else{
      if(this.isChanging){
        typeOfHairJob.url = widget.news.url;
      }
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => (UploadingScreen()))
      );
    }

  }














  //not provided days dialog
  notProvidedDaysDialog (BuildContext mcontext)
  {
    return showDialog<void>(
      context:  mcontext,
      builder: (BuildContext context){
        return new AlertDialog(
          title: new Text("Choose the days on which this hair job is NOT provided",textAlign: TextAlign.center,),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              getDaysOfTheWeekChecker(context),
              getProvidedAllDaysButton(context),
              new Fancy(
                text: "cancel",
                onTap: (){
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget getProvidedAllDaysButton(BuildContext context)
  {
    return new Fancy(
      text: "It is provided on all days",
      onTap: (){
        this.notProvidedList = getWeekDays();
        Navigator.pop(context);
      },
    );
  }

  Widget getDaysOfTheWeekChecker(BuildContext context)
  {
    return new ListView.builder(
        itemCount: notProvidedList.length,
        shrinkWrap: true,
        addAutomaticKeepAlives: true,
        itemBuilder: (BuildContext context, int index){
          WeekDay day = notProvidedList[index];
          return Row(
            children: <Widget>[
              new Checkbox(
                  value: day.notProvided,
                  onChanged: (bool b){
                    setState(() {
                      notProvidedList[index].notProvided = b;
                      Navigator.pop(context);
                      notProvidedDaysDialog(super.context);
                    });
                  }
              ),
              new Text(day.name)
            ],
          );
        }
    );
  }



  List<WeekDay> getWeekDays()
  {
    List<WeekDay> days = new List<WeekDay>();
    for(int i = 0;i<Helpers.weekdays.length;i++){
      WeekDay day = new WeekDay(Helpers.weekdays[i], i, false);
      days.add(day);
    }
    return days;
  }













}

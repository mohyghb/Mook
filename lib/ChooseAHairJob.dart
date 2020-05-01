import 'package:flutter/material.dart';
import 'package:simin_saloon/Buttons/Fancy.dart';
import 'package:simin_saloon/Helpers.dart';
import 'package:simin_saloon/Appointment/TypeOfHairJob.dart';

import 'package:firebase_database/firebase_database.dart';




class ChooseAHairJob extends StatefulWidget
{
  final DateTime dateTime;

  ChooseAHairJob(this.dateTime);

  @override
  _ChooseAHairJobState createState() => new _ChooseAHairJobState();
}

class _ChooseAHairJobState extends State<ChooseAHairJob>
{


  List<TypeOfHairJob> hairJobs;
  bool isSearching;

  //initializer
  void initState()
  {
    isSearching = false;
    hairJobs = new List<TypeOfHairJob>();
    super.initState();
    getHairJobs();
  }

  //get the hair jobs from the database
  void getHairJobs() async
  {
    //getting the hair jobs from data base one by one
    //parsing and then adding it to the list
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
    setState(() {

    });

  }

  //produces the scaffold of the createAppointment
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: getAppBar(),
      body: getBody(context),
      backgroundColor: Theme.of(context).primaryColor,
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
        title: new Text(Helpers.CHOOSE_HAIR_JOB_TYPE),
      );
    }
  }

  void onSearchChange(String changedText)
  {
    String lowCaseText = changedText.toLowerCase();
      for(int i = 0;i<hairJobs.length;i++){
        TypeOfHairJob user = hairJobs[i];
        if(changedText.isEmpty||(user.name.toLowerCase().contains(lowCaseText)||
            user.description.toLowerCase().contains(lowCaseText)||
            user.price.contains(changedText)||
            user.timeItTakes.contains(changedText)||
            user.gender.toLowerCase().contains(lowCaseText))){
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
    if(this.hairJobs.length!=0){
      return new ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.all(10.0),
        itemCount: this.hairJobs.length,
        itemBuilder: (BuildContext context, int index){
          TypeOfHairJob tohj =  this.hairJobs.elementAt(index);
          if(!tohj.isInList){
            return SizedBox();
          }
          return Card(
              elevation: 1.0,
              color: Colors.black,
              shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: const EdgeInsets.only(left:8.0,right: 8.0,top: 8.0),
                child: Column(
                  children: <Widget>[
                    tohj.getTypeOfHairJobWidget(context,Colors.white),
                    SizedBox(height: 5.0,),
                    getChooseButton(index),
                    new SizedBox(height: 10.0,)
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

  Widget getChooseButton(int index)
  {
    String name = this.hairJobs[index].isNotProvided(widget.dateTime);
    if(name.isNotEmpty){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Text("Sorry, this hair job is not provided on $name"+"s",textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),),
      );
    }else{
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Fancy(
          text: "Choose",
          iconData: Icons.check,
          color: Helpers.themeColor,
          textColor: Colors.black,
          radius: 100.0,
          onTap: ()=> choseThis(index,context),
        ),
      );
    }

  }


  //remove the respective type of job from the server
  void choseThis(int index, BuildContext context)
  {
    Helpers.onResultTypeOfHairJob = this.hairJobs.elementAt(index);
    Navigator.pop(context);
  }



//  void filterOutNotProvidedHairJobs()
//  {
//    for(int i = 0;i<this.hairJobs.length;i++){
//      if(hairJobs[i].isNotProvided(widget.dateTime)){
//        this.hairJobs.removeAt(i);
//      }
//    }
//  }




}

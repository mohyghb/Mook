import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simin_saloon/Buttons/Fancy.dart';
import 'package:simin_saloon/Helpers.dart';
import 'package:simin_saloon/Appointment/TypeOfHairJob.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:simin_saloon/Create/NewHairJob.dart';



class ManageHairJobs extends StatefulWidget
{
  @override
  _ManageHairJobsState createState() => new _ManageHairJobsState();
}

class _ManageHairJobsState extends State<ManageHairJobs>
{


  List<TypeOfHairJob> hairJobs;
  bool isSearching;

  //initializer
  void initState()
  {

    hairJobs = new List<TypeOfHairJob>();
    isSearching = false;
    getHairJobs();
    super.initState();

  }

  //get the hair jobs from the database
  void getHairJobs() async
  {
    //getting the hair jobs from data base one by one
    //parsing and then adding it to the list
    await FirebaseDatabase.instance.reference().child(Helpers.TYPE_OF_HAIR_JOB).once().then((DataSnapshot data){
      Map<dynamic,dynamic> map = data.value;
      if(map!=null){
        map.forEach((dynamic k, dynamic v){
          TypeOfHairJob typeOfHairJob = new TypeOfHairJob("", "", "", "", "");
          typeOfHairJob.toTypeOfHairJob(v);
          hairJobs.add(typeOfHairJob);
        });
      }
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
      body: Builder(builder: (context) => getBody(context)),
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
        title: new Text("Manage Hair Jobs"),
      );
    }

  }

//  void removeIsInList()
//  {
//    for(TypeOfHairJob tohj in this.hairJobs){
//      tohj.isInList = true;
//    }
//    setState(() {
//
//    });
//  }


  void onSearchChange(String changedText)
  {
    String lowCaseText = changedText.toLowerCase();
    for(int i = 0;i<hairJobs.length;i++){
      TypeOfHairJob user = hairJobs[i];
      if(user.name.toLowerCase().contains(lowCaseText)||
          user.description.toLowerCase().contains(lowCaseText)||
      user.price.contains(changedText)||
      user.timeItTakes.contains(changedText)||
      user.gender.toLowerCase().contains(lowCaseText)){
        setState(() {
          user.isInList = true;
        });

      }else{
        setState(() {
          user.isInList = false;
        });

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
                    color: getColor(tohj),
                    shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    child: Padding(
                      padding: const EdgeInsets.only(left:8.0,right: 8.0,top: 8.0),
                      child: Column(
                        children: <Widget>[
                         tohj.getTypeOfHairJobWidget(context,Colors.white),
                          new Fancy(
                            text: getText(tohj),
                            radius: 100.0,
                            color: Colors.white,
                            onTap: ()=> removeAt(index,context),
                          ),
                          new Fancy(
                            text: "Edit",
                            radius: 100.0,
                            color: Colors.white,
                            onTap: ()=> this.editActivity(index),
                          )
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

  Color getColor(TypeOfHairJob tohj)
  {
    if(tohj.isDeleted()){
      return Colors.red;
    }
    else{
      return Colors.green;
    }
  }

  String getText(TypeOfHairJob tohj)
  {
    if(tohj.isDeleted()){
      return "Add back";
    }
    else{
      return "remove";
    }
  }


  //remove the respective type of job from the server
  void removeAt(int index, BuildContext context) async
  {
    TypeOfHairJob tohj = this.hairJobs.elementAt(index);

    bool c = await checkInternet();
    if(c){
      if(tohj.isDeleted()){

        setState(() {
          tohj.setDeleted(false);
          FirebaseDatabase.instance.reference().child(Helpers.TYPE_OF_HAIR_JOB).child(tohj.id).set(tohj.toJson());
        });

      }else{
        setState(() {
          tohj.delete();
          FirebaseDatabase.instance.reference().child(Helpers.TYPE_OF_HAIR_JOB).child(tohj.id).set(tohj.toJson());
        });
      }
    }else{
      Scaffold.of(context).showSnackBar(new SnackBar(backgroundColor:Colors.red,content: new Text("Please make sure your internet connection works. We could not create a user at this moment.",textAlign: TextAlign.center,)));
    }


  }
  
  
  //open the createNewTOHJ but set the tohj
  void editActivity(int index){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ( NewHairJob(tohj: this.hairJobs.elementAt(index),))));
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

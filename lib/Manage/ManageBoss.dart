import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simin_saloon/Buttons/Fancy.dart';
import 'package:simin_saloon/Helpers.dart';


import 'package:firebase_database/firebase_database.dart';




class ManageBoss extends StatefulWidget
{
  @override
  _ManageBossState createState() => new _ManageBossState();
}

class _ManageBossState extends State<ManageBoss>
{


  List<String> bosses;
  final _priceController = TextEditingController();

  //initializer
  void initState()
  {
    bosses = new List<String>();
    super.initState();
    getBosses();
  }

  getBosses()
  {
    FirebaseDatabase.instance.reference().
    child(Helpers.BOSS).once().then((DataSnapshot snap){
      if(snap.value!=null){
        List<dynamic> bossNumbers = snap.value;
        if(bossNumbers!=null){
          bossNumbers.forEach((dynamic bn){
            bosses.add(bn.toString());
          });
        }
        setState(() {

        });
          }
        });
  }


  //produces the scaffold of the createAppointment
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: getAppBar(),
      body: Builder(builder:(context) => scaffoldBody(context)),
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
    );
  }

  Widget getAppBar()
  {
    return new AppBar(
      elevation: 0.0,
      centerTitle: true,
      title: new Text("Manage Bosses"),
    );
  }


  Widget scaffoldBody(context)
  {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(child: getTextFieldForPrice()),
              new Fancy(
                iconData: Icons.add,
                onTap: ()=>addThisPhoneNumber(context),
                radius: 100.0,
                color: Colors.green,
              )
            ],
          ),
        ),
        Expanded(child: getBody(context)),
      ],
    );
  }


  //produces the body of the manger
  Widget getBody(BuildContext mcontext)
  {
    int size = this.bosses.length;
    if(size!=0){
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 50.0,
          child: new ListView.builder(
            itemCount: size,
              itemBuilder: (BuildContext context,int index){
              return Padding(
                padding: const EdgeInsets.all(0.0),
                child: Row(
                  children: <Widget>[
                    new SizedBox(width: 10.0,),
                    new Icon(Icons.call_end),
                    new SizedBox(width: 10.0,),
                    new Text(Helpers.makeFancy(this.bosses[index]),style: TextStyle(fontSize: Helpers.FONT_SIZE),),
                    new IconButton(icon: Icon(Icons.close,color: Colors.red,), onPressed: ()=> removeThisNumber(bosses[index], mcontext))
                  ],
                )
              );
              }
          ),
        ),
      );
    }else{
      return new Center(
        child: new CircularProgressIndicator(),
      );
    }
  }



  Widget getTextFieldForPrice()
  {
    return Padding(
      padding: const EdgeInsets.only(left:8.0,right:8.0,top:8.0),
      child: TextField(
        maxLines: 1,
        controller: this._priceController,
        enabled: true,
        keyboardType: TextInputType.numberWithOptions(
            decimal: false,
            signed: false),
        obscureText: false,
        cursorColor: Theme.of(context).cursorColor,
        cursorWidth: 2,
        style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: Helpers.FONT_SIZE
        ),
        textAlign: TextAlign.center,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: "Enter a Phone Number",
            hintStyle: TextStyle(
                fontSize: Helpers.FONT_SIZE)
        ),
      ),
    );
  }


  void dispose()
  {
    super.dispose();
    this._priceController.dispose();
    this._priceController.clear();
  }


  addThisPhoneNumber(BuildContext context) async
  {
    String n = this._priceController.text;
    if(bosses.contains(n)){
      Scaffold.of(context).showSnackBar(new SnackBar(backgroundColor:Colors.green,content: new Text("This number has been added already!",textAlign: TextAlign.center,style: TextStyle(color: Colors.white),)));
    }else{
      this.bosses.add(n);
      Map<String,String> map = new Map();
      if(this.bosses!=null){
        for(int i =0;i<this.bosses.length;i++){
          map.putIfAbsent(i.toString(), ()=> bosses[i]);
        }
      }
      bool c = await checkInternet();
      if(c){
        FirebaseDatabase.instance.reference().
        child(Helpers.BOSS).set(map);
      }else{
        Scaffold.of(context).showSnackBar(new SnackBar(backgroundColor:Colors.red,content: new Text("Please connect to internet",textAlign: TextAlign.center,style: TextStyle(color: Colors.white),)));
      }
    }
    setState(() {

    });
  }


  removeThisNumber(String n,BuildContext context) async
  {
      bool c = await checkInternet();
      if(c){
        this.bosses.remove(n);
        Map<String,String> map = new Map();
        if(this.bosses!=null){
          for(int i =0;i<this.bosses.length;i++){
            map.putIfAbsent(i.toString(), ()=> bosses[i]);
          }
        }
        FirebaseDatabase.instance.reference().
        child(Helpers.BOSS).set(map);
        Scaffold.of(context).showSnackBar(new SnackBar(backgroundColor:Colors.green,content: new Text(n+" Was removed",textAlign: TextAlign.center,style: TextStyle(color: Colors.white),)));

      }else{
        Scaffold.of(context).showSnackBar(new SnackBar(backgroundColor:Colors.red,content: new Text("Please connect to internet",textAlign: TextAlign.center,style: TextStyle(color: Colors.white),)));
      }

    setState(() {

    });
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

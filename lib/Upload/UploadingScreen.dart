import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:simin_saloon/Appointment/TypeOfHairJob.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:simin_saloon/Helpers.dart';
import 'package:simin_saloon/Create/News.dart';

class UploadingScreen extends StatefulWidget
{

  final StorageUploadTask task;
  final VoidCallback onDismissed;
  final VoidCallback onDownload;
  final TypeOfHairJob typeOfHairJob;
  final News news;
  final Future<void> voidTask;

   UploadingScreen({
     Key key,
     this.task,
     this.onDismissed,
     this.onDownload,
     this.typeOfHairJob,
     this.voidTask,
     this.news,
   })
      : super(key: key);

  @override
  _UploadingState createState() => new _UploadingState();
}

class _UploadingState extends State<UploadingScreen> {



  Color currentColor;
  int state;





  Widget get status {
    String result;
    IconData icon;
    Color c;

    if (widget.task.isComplete) {

      if (widget.task.isSuccessful) {
        result = 'Complete';
        icon = Icons.done;
        c = Colors.green;
        updateHairJobs();
      } else if (widget.task.isCanceled) {
        result = 'Canceled';
        icon = Icons.cancel;
        c = Colors.red;
      } else {
        result = 'Failed ERROR: ${widget.task.lastSnapshot.error}';
        icon = Icons.error;
        c = Colors.red;
      }
    } else if (widget.task.isInProgress) {
      result = 'Uploading';
      c = Colors.blue;
      icon = Icons.cloud_upload;
    } else if (widget.task.isPaused) {
      result = 'Paused';
      c = Colors.amber;
      icon = Icons.pause_circle_filled;
    }else{
      result = "...";
      icon = Icons.file_upload;
      c = Colors.amber;
    }
    currentColor = c;
    return Scaffold(
      backgroundColor: c,
      appBar: getAppBar("Uploading Screen",c),
      body: SafeArea(
        child: Center(
          child: new Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Icon(icon,color: Colors.white,),
                  new Text(result,style: TextStyle(fontSize: Helpers.TITLE_FONT_SIZE,color: Colors.white),)
                ],
          ),
        ),
      ),
    );
  }



  //initializer
  void initState() {

    super.initState();
    getState();
  }




  updateHairJobs() async
  {
    if(widget.task!=null){
      String url = await getUrl();
      if(widget.typeOfHairJob!=null){
        FirebaseDatabase.instance.reference().child(Helpers.TYPE_OF_HAIR_JOB)
            .child(widget.typeOfHairJob.id).child(Helpers.URL).set(url);
      }else if(widget.news!=null){
        FirebaseDatabase.instance.reference().child(Helpers.NEWS)
            .child(widget.news.id).child(Helpers.URL).set(url);
      }
    }
  }

  void getState()
  {
    if(this.widget.task!=null){
      state = 1;
    }else if(this.widget.voidTask!=null){
      state = Helpers.LOADING_STATE;
      this.widget.voidTask.timeout(Duration(seconds: 5),onTimeout: (){
        setState(() {
          state = Helpers.FAILED_STATE;
        });
      }).whenComplete((){
        setState(() {
          state = Helpers.SUCCESSFUL_STATE;
        });
      }).catchError((e){
        state = Helpers.FAILED_STATE;
      });
    }else{
      state = 0;
    }
  }

  Future<String> getUrl() async {
    StorageReference ref;
    if(widget.typeOfHairJob!=null){
      ref = FirebaseStorage.instance.ref().child(Helpers.TYPE_OF_HAIR_JOB).child(widget.typeOfHairJob.id);
      String url = (await ref.getDownloadURL()).toString();
      return url;
    }else if(widget.news!=null){
      ref = FirebaseStorage.instance.ref().child(Helpers.NEWS).child(widget.news.id);
      String url = (await ref.getDownloadURL()).toString();
      return url;
    }

    //might be the problem
    return "";
  }



  //produces the scaffold of the createAppointment
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return getBody();
  }



  Widget getAppBar(String title,Color c)
  {
    return new AppBar(
      elevation: 0.0,
      backgroundColor: c,
      centerTitle: true,
      title: new Text(title),
    );
  }



  Widget getBody()
  {
    switch(this.state)
    {
      case 1:
        return getTaskWidget();
        break;
      case 2:
        return getLoadingScreenWidget();
        break;
      case Helpers.LOADING_STATE:
        return getLoadingScreenWidget();
        break;
      default:
        return getDefaultWidget();
        break;
    }

  }

  Widget getTaskWidget()
  {
    return StreamBuilder<StorageTaskEvent>(
        stream: widget.task.events,
        builder: (BuildContext context,
            AsyncSnapshot<StorageTaskEvent> asyncSnapshot) {

          if (asyncSnapshot.hasData) {

            final StorageTaskEvent event = asyncSnapshot.data;
            final StorageTaskSnapshot snapshot = event.snapshot;
            return status;
          } else {
            return status;
          }});
  }

  Widget getDefaultWidget()
  {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: getAppBar("Uploading Screen",Colors.green),
      body: SafeArea(
        child: Center(
          child: new Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Icon(Icons.done_all,color: Colors.white,),
              new Text("Successful!",style: TextStyle(fontSize: Helpers.TITLE_FONT_SIZE,color: Colors.white),)
            ],
          ),
        ),
      ),
    );
  }




  Widget getLoadingScreenWidget()
  {
    return new Scaffold(
      appBar: getAppBar("Uploading Screen",Theme.of(context).primaryColor),
      body: new CircularProgressIndicator(),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }






}

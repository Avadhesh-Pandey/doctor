import 'dart:io';

import 'package:doctor/blocs/BlocProvider.dart';
import 'package:doctor/blocs/NotesBloc.dart';
import 'package:doctor/data/Database.dart';
import 'package:doctor/model/DoctorListResponseModel.dart';
import 'package:doctor/process/ContactProcess.dart';
import 'package:doctor/ui/DoctorDetailScreen.dart';
import 'package:doctor/ui/OTPScreen.dart';
import 'package:doctor/ui/widgets/CommonWebView.dart';
import 'package:doctor/ui/widgets/ContactListItemWidget.dart';
import 'package:doctor/ui/widgets/HeaderWidgetLight.dart';
import 'package:doctor/utility/AppDialog.dart';
import 'package:doctor/utility/Loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doctor/network/Apis.dart';
import 'package:doctor/utility/AppUtill.dart';
import 'package:doctor/utility/CommonUIs.dart';
import 'package:doctor/values/AppSetings.dart';
import 'package:sqflite/sqflite.dart';

class HomeScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return HomeWidget();
  }
}


class HomeWidget extends State<HomeScreen> {
  Size _size;
  List<DoctorListResponseModel> _doctorList=List();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getContacts();
    });


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return WillPopScope(child:
    AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.white,
      ),
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Image.asset("images/bima_doctor_name_logo.png",fit: BoxFit.fitWidth,),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
        ),
        backgroundColor: AppColors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: AppColors.themeColor, //change your color here
          ),
          titleSpacing: 0,
          elevation: 1,
          backgroundColor: AppColors.white,
          automaticallyImplyLeading: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset("images/bima_doctor_name_logo.png",height: 50,),
              Image.asset("images/bima_logo.png",height: 50,fit: BoxFit.fitHeight,),
            ],
          ),
        ),
        body: ListView.separated(itemBuilder: (_, index){
          return ContactListItemWidget(_doctorList[index],onSelected: ()
            {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                    return DoctorDetailScreen(_doctorList[index]);
                  }));
            },);
        }, separatorBuilder: (context, index) => Divider(
        ), itemCount: _doctorList.length)
      ),

    ), onWillPop: (){
      Navigator.pop(context);
      exit(0);
    });
  }

  getContacts()
  {
    DBProvider.db.getNotes().then((value) {
      if(value!=null && value.length>0)
        {
          AppUtill.showToast("Data Retrieved from Local Database", context);
          AppUtill.printAppLog("DBProvider.db.getNotes.length:: ${value.length}");
          setState(() {_doctorList=value;});
        }
      else
        {
          Loader.showLoader(context);
          ContactProcess().getAllContacts((apiResponse) {
            Loader.hideLoader();
            if(apiResponse.status)
            {
              setState(() {
                AppUtill.printAppLog("apiResponse::::${apiResponse.raw}");
                _doctorList=apiResponse.raw != null ? (apiResponse.raw as List).map((i) => DoctorListResponseModel.fromJson(i)).toList() : List();
                AppUtill.printAppLog("apiResponse::::${_doctorList.length}");
              });

              _doctorList.forEach((element) {
                DBProvider.db.newNote(element);
              });

              DBProvider.db.getNotes().then((value) {
                AppUtill.printAppLog("DBProvider.db.getNotes.length:: ${value.length}");
                _doctorList=value;
              });

            }
          });
        }
    });
  }

}

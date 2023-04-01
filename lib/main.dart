import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:workmanager/workmanager.dart';
import 'database.dart';

void main()  {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  runApp( MyApp());
}

void scheduleTask(){
  Workmanager().registerPeriodicTask(
    "sendEmail",
    "sendErrorEmailTask",
    inputData: {
      'table': 'transaction_table',
      'error': true,
    },
    frequency: Duration(minutes: 15),
    initialDelay: Duration(minutes: 5),
  );
}

 void callbackDispatcher() {
  print("callbackDispatcher");

  try{
    print("inside try of callbackDispatcher");
    Workmanager().executeTask((task, inputData) async {
      String table = inputData!['table'];
      bool hasError = inputData['error'];
      await sendEmail();
      return true;
    });
  } catch(e){
    print(e);
  }
}

Future<void> sendEmail() async {
  print("here");
  try{
    final errorTransactions = await DatabaseHelper.instance.getErrorTransactions();
    if (errorTransactions.isNotEmpty) {
      print("not Empty");
      final Email email = Email(
        body: 'Hello, Admin!\n\nThere are error records in the transaction table are ${errorTransactions.toString()}.',
        subject: 'Error Records in Transaction Table',
        recipients: ['harishyogan123@gmail.com'],
        isHTML: false,
      );
      try{
        await FlutterEmailSender.send(email);
      } catch(e){
        print(e);
      }

    }else{
      print("empty");
    }
  } catch(e){
    print(e);
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    callQuery();
    scheduleTask();
  }

  callQuery() async {
    final db = DatabaseHelper.instance;
    final allRows = await db.getErrorTransactions();
    print("all rows $allRows");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: Scaffold(
        appBar: AppBar(title: Text('Daily Mailer'),),
        body: Container(
          child: Center(child: Text("Mail Admin Component"),),
        ),
      ),
    );
  }
}

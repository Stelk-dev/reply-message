import 'dart:math';

import 'package:flutter/material.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false,
    debugShowMaterialGrid: false,
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool havePermission = false;
  String errorMessage = "";
  final List<ServiceNotificationEvent> events = [];

  @override
  void initState() {
    super.initState();
    print("INIT STATE");
    checkPermission();
  }

  Future<void> checkPermission() async {
    /// check if notification permession is enebaled
    bool status = await NotificationListenerService.isPermissionGranted();

    if (!status) {
      await Future.delayed(Duration(seconds: 1));
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Permission"),
          content: Text("This app need notfs permission to works"),
          actions: [
            TextButton(
              onPressed: () async {
                status = await NotificationListenerService.requestPermission();
                setState(() {});

                if (status) {
                  Navigator.pop(context);
                  listen();
                }
              },
              child: Text("Active"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Go back",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    } else
      listen();

    havePermission = status;
    setState(() {});
  }

  Future<void> listen() async {
    try {
      print("LISTEN");
      NotificationListenerService.notificationsStream.listen((event) {
        print("NEW EVENT: ");
        print(event);

        events.add(event);
        setState(() {});
        // if (event.packageName == null) return;

        // if (event.packageName!.contains("telegram")) sendReply(event);
      });
      print("EVERYTHING GOOD");
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 100));
      errorMessage = e.toString();
      setState(() {});
    }
  }

  // Future<void> sendReply(ServiceNotificationEvent event) async {
  //   await Future.delayed(Duration(seconds: 2));

  //   print(event.packageName?.contains("telegram"));

  //   if (event.packageName?.contains("telegram") ?? false) {
  //     final msg = ["hiiii", "Come va?", "Sono una AI replier"];
  //     event.sendReply(msg[Random().nextInt(3)]);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('App Reply Messages'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Permission added: ${havePermission ? "Yes" : "No"}"),
              SizedBox(height: 32),
              Text("Error: ${errorMessage.isNotEmpty}"),
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 32),
              Text("Your notification"),
              ListView.separated(
                itemCount: events.length,
                padding: EdgeInsets.symmetric(vertical: 32),
                shrinkWrap: true,
                separatorBuilder: (_, i) => Divider(color: Colors.black),
                itemBuilder: (_, i) => Row(
                  children: [
                    Expanded(
                      child: Text(
                        "packageName: ${events[i].packageName}\ntitle: ${events[i].title}\ncontent: ${events[i].content}\ncanReply: ${events[i].canReply}",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

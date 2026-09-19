import 'package:flutter/material.dart';

class LatihanListView extends StatelessWidget {
  const LatihanListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tampilan Basic List"),
        backgroundColor: const Color.fromARGB(255, 238, 255, 0)
      ),

      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.access_alarm),
              title: Text('Alarm'),
            ),
          ),
          ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone'),
            ),
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Camera'),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Message'),
            ),
        ],
      ),
    );
  }
}
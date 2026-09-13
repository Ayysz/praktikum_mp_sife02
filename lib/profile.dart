import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: CircleAvatar(radius: 40, backgroundImage: AssetImage('assets/cat_aaa.jpeg')),
            ),
            Text("Nama: Ammar"),
            Text("NIM: 241011750161"),
            ElevatedButton(
              onPressed: () {
                debugPrint("LOGUTT BANG>>");
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('loguttt>>'),
            ),
          ],
        ),
      ),
    );
  }
}

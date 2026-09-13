import 'package:flutter/material.dart';

class Materi extends StatelessWidget {
  const Materi({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('04SIFE002 Mobile Programming'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            ListTile(title: Text("Pertemuan 1")),
            ListTile(title: Text("Pertemuan 2")),
            ListTile(title: Text("Pertemuan 3")),
          ],
        ),
      )
    );
  }
}
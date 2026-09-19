import 'package:flutter/material.dart';
import 'package:praktikum_mp_04sife02_ammar/ptm3/latihan_list_view.dart';

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
            ListTile(
              title: Text("Pertemuan 4"), 
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LatihanListView()));
              },
            )
          ],
        ),
      )
    );
  }
}
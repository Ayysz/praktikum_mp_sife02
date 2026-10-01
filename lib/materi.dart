import 'package:flutter/material.dart';
import 'package:praktikum_mp_04sife02_ammar/ptm3/latihan_list_view.dart';
import 'package:praktikum_mp_04sife02_ammar/ptm4/alert_toast.dart';

class Materi extends StatelessWidget {
  const Materi({super.key});
  @override
  Widget build(BuildContext context) {

    void navigateTo(Widget ptmKe) {
      
      Navigator.push(context, MaterialPageRoute(builder: (context) => ptmKe));
    }

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
              title: Text("Pertemuan 4 - List View"), 
              onTap: () => navigateTo(LatihanListView()),
            ),
            ListTile(title: Text("Pertemuan 5 - Toast dan Alert"), onTap: () => navigateTo(AlertToast())),
            ListTile(title: Text("Pertemuan 6"), onTap: () => navigateTo(LatihanListView())),
            ListTile(title: Text("Pertemuan 7"), onTap: () => navigateTo(LatihanListView())),
            ListTile(title: Text("Pertemuan 8"), onTap: () => navigateTo(LatihanListView())),
          ],
        ),
      )
    );
  }
}
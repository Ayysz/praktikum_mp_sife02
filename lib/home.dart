import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              'ini isi Home bang atau judul nya',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: CircleAvatar(
                radius: 35,
                child: Icon(Icons.person)
              )
            ),
            Text('Ini Pembuatan Home dan navbar di pertemuan ke-2 \n matakuliah mobile programming'),
            SizedBox(height: 20),// ini seperti br gtu kalo di html
            ElevatedButton(
              onPressed: () {},
              child: Text('Jelajahi Materi \n(ini pakai component ElevatedButton)'),
            )
          ],
        ),
      )
    );
  }
}
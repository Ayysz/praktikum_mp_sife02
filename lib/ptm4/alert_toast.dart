import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AlertToast extends StatelessWidget {
  const AlertToast({super.key});

  void tampilkanToast() {
    Fluttertoast.showToast(
      msg: "Ini adalah pesan Toast",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Color.fromRGBO(255, 30, 40, 0.5),
      webBgColor: "linear-gradient(to right, #96c93d, #00b09b)",
      webPosition: "left",
      textColor: Colors.white,
      fontSize: 16.0
    );
  }

  void tampilkanAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Ini kepala Alert"),
          content: Text("Ini adalah isi Alert"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pertemuan 4 Belajar Alert & Toast"),
        backgroundColor: const Color.fromARGB(255, 1, 252, 126)
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: <Widget>[
              ElevatedButton(
              onPressed: () => tampilkanToast(),
              child: Text("Tampilkan Toast"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => tampilkanAlert(context),
              child: Text("Tampilkan Alert"),
            ),
            ],
          ),
        )
      ),
    );
  }
}
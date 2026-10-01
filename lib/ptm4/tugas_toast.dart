import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TugasToast extends StatelessWidget {
  const TugasToast({super.key});

  final List<String> datamakanan = const [
    'Nasi Goreng',
    'Mie Goreng',
    'Ayam Bakar',
    'Ikan Bakar',
    'Sate',
    'Bakso',
    'Sop',
  ];

  void _elvBtnOnTap() {
    Fluttertoast.showToast(
      msg: "Selamat datang pada aplikasi ini!!",
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

  void _txtBtnOnTap(BuildContext context, String menu) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Konfirmasi Pilihan"),
          content: Text("Apakah anda yakin ingin memesan $menu?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Ya"),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tugas Toast")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text("Daftar Menu Makanan Siap Saji", 
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    )),
                  ]
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: (){
                    _elvBtnOnTap();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Pesan"),
                ),
              ]
            ),
            SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: datamakanan.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: TextButton(
                      onPressed: () {
                        _txtBtnOnTap(context, datamakanan[index]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          datamakanan[index],
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ), 
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

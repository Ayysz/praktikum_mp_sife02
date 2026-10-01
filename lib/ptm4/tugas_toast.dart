import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TugasToast extends StatelessWidget {
  const TugasToast({super.key});

  final List<Map<String, dynamic>> datamakanan = const [
    {'nama': 'Nasi Goreng', 'icons': Icons.rice_bowl},
    {'nama': 'Mie Goreng', 'icons': Icons.ramen_dining},
    {'nama': 'Ayam Bakar', 'icons': Icons.local_dining},
    {'nama': 'Ikan Bakar', 'icons': Icons.set_meal},
    {'nama': 'Sate', 'icons': Icons.kebab_dining},
    {'nama': 'Bakso', 'icons': Icons.soup_kitchen},
    {'nama': 'Sop', 'icons': Icons.soup_kitchen},
  ];

  void _elvBtnOnTap() {
    Fluttertoast.showToast(
      msg: "Selamat datang pada aplikasi ini!!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Color.fromRGBO(255, 196, 0, 1),
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
      appBar: AppBar(
        title: const Text("Tugas Toast"),
        backgroundColor: const Color.fromARGB(255, 255, 153, 0),
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
              top: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Daftar Menu Makanan Siap Saji", 
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  )),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: ElevatedButton(
                    onPressed: (){
                      _elvBtnOnTap();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Pesan"),
                  ),
                ),
              ]
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: datamakanan.length,
              itemBuilder: (context, index) {
                final item = datamakanan[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: ListTile(
                    leading: Icon(item['icons'] as IconData, color: Colors.blue),
                    title: Text(
                      item['nama'] as String,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    onTap: () {
                      _txtBtnOnTap(context, item['nama'] as String);
                    },
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

import 'package:flutter/material.dart';

class Gesture extends StatefulWidget {
  const Gesture({super.key});

  @override
  State<Gesture> createState() => _GestureState();
}

class _GestureState extends State<Gesture> {

  // Data State Widget
  String _teks = "Click this box";
  Color _warna = Colors.blue;
  int _jumlah = 0;

  void _ubahWarna(BuildContext context, String teks, Color warna) => setState(() {
    _teks = teks;
    _warna = warna;
    _jumlah++;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gesture Detector"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _ubahWarna(context, "Klik sekali", Colors.red);
                  },
                  onDoubleTap: () {
                    _ubahWarna(context, "Double tap", Colors.purple);
                  },
                  onLongPress: () {
                    _ubahWarna(context, "Long press", Colors.green);
                  },
                  onVerticalDragStart: (details) {
                    _ubahWarna(context, "Drag Vertical", Colors.black);
                  },
                  onHorizontalDragStart: (details) {
                    _ubahWarna(context, "Drag Horizontal ", Colors.lightGreen);
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _warna,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          spreadRadius: 5,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _teks, 
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
            ),
            SizedBox(height: 20),
            Text("Jumlah Klik : $_jumlah", style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ), 
            SizedBox(height: 10),
            ElevatedButton(onPressed: (){
              setState(() {
                _jumlah = 0;
                _teks = "Click this box";
                _warna = Colors.blue;
              });
            }, child: Text("Hapus Jumlah Klik")),
              ],
            )
            
        ),
    );
  }
}
import 'package:flutter/material.dart';

class TugasGesture extends StatefulWidget {
  const TugasGesture({super.key});

  @override
  State<TugasGesture> createState() => _TugasGestureState();
}

class _TugasGestureState extends State<TugasGesture> {

  bool isLightOn = false ;
  String text = "Lampu Menyala";
  Color lightColor = Colors.black;

  void _changeLight() => setState(() {
    isLightOn = !isLightOn;
    text = isLightOn ? "Lampu Menyala" : "Lampu Mati" ;
    lightColor = isLightOn ? Colors.amber : Colors.black ;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tugas Gesture Detector"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _changeLight,
              child: Icon(
              Icons.lightbulb, 
              size: 100,
              color: lightColor,
              ),
            ),
            SizedBox(height: 20),
            Text(
              text,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: lightColor,
              ),
            ),
          ],
        )
      ),
    );
  } 
}
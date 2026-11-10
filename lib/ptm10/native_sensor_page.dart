import 'package:flutter/material.dart';
import 'package:praktikum_mp_04sife02_ammar/ptm10/camera_tab.dart';
import 'package:praktikum_mp_04sife02_ammar/ptm10/location_tab.dart';
import 'package:praktikum_mp_04sife02_ammar/ptm10/notification_tab.dart';

class NativeSensorPage extends StatelessWidget {
  const NativeSensorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Native & Sensor'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.camera_alt),
                text: 'Kamera',
              ),
              Tab(
                icon: Icon(Icons.location_on),
                text: 'Lokasi GPS',
              ),
              Tab(
                icon: Icon(Icons.notifications),
                text: 'Notifikasi',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CameraTab(),
            LocationTab(),
            NotificationTab(),
          ],
        ),
      ),
    );
  }
}


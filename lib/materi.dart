import 'package:flutter/material.dart';
import 'package:praktikum_mp_04sife02_ammar/ptm3/latihan_list_view.dart';
import 'package:praktikum_mp_04sife02_ammar/ptm4/alert_toast.dart';
import 'package:praktikum_mp_04sife02_ammar/ptm4/tugas_toast.dart';

class Materi extends StatelessWidget {
  const Materi({super.key});

  void _navigateTo(BuildContext context, Widget ptmKe) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ptmKe));
  }

  void _showUnavailableToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('materi pertemuan belum ada'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildExpansionTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> subItems,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        shape: const Border(), // Menghilangkan border atas/bawah bawaan saat terbuka
        children: subItems.map((item) {
          final IconData subIcon = item['icon'] ?? Icons.article_outlined;
          return ListTile(
            leading: Icon(subIcon, size: 20, color: Colors.grey[600]),
            title: Text(item['title']),
            contentPadding: const EdgeInsets.only(left: 32.0, right: 16.0),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () {
              if (item['page'] != null) {
                _navigateTo(context, item['page'] as Widget);
              } else {
                _showUnavailableToast(context);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Data list pertemuan, memudahkan pengaturan konten tanpa hardcode satu-satu
    final List<Map<String, dynamic>> pertemuanData = [
      {
        "title": "Pertemuan 1",
        "icon": Icons.folder,
        "subItems": [
          {'title': 'Sub Materi 1', 'page': null, 'icon': Icons.folder_off},
        ]
      },
      {
        "title": "Pertemuan 2",
        "icon": Icons.folder,
        "subItems": [
          {'title': 'Sub Materi 1', 'page': null, 'icon': Icons.folder_off},
        ]
      },
      {
        "title": "Pertemuan 3",
        "icon": Icons.folder,
        "subItems": [
          {'title': 'Sub Materi 1', 'page': null, 'icon': Icons.folder_off},
        ]
      },
      {
        "title": "Pertemuan 4 - List View",
        "icon": Icons.list_alt,
        "subItems": [
          {'title': 'Latihan List View', 'page': const LatihanListView(), 'icon': Icons.visibility},
        ]
      },
      {
        "title": "Pertemuan 5 - Toast dan Alert",
        "icon": Icons.notifications_active,
        "subItems": [
          {'title': 'Latihan Toast/Alert', 'page': const AlertToast(), 'icon': Icons.visibility},
          {'title': 'Tugas Alert Pemesanan Makanan', 'page': const TugasToast(), 'icon': Icons.food_bank},
        ]
      },
      {
        "title": "Pertemuan 6",
        "icon": Icons.folder,
        "subItems": [
          {'title': 'Sub Materi 1', 'page': null, 'icon': Icons.folder_off},
        ]
      },
      {
        "title": "Pertemuan 7",
        "icon": Icons.folder,
        "subItems": [
          {'title': 'Sub Materi 1', 'page': null, 'icon': Icons.folder_off},
        ]
      },
      {
        "title": "Pertemuan 8",
        "icon": Icons.folder,
        "subItems": [
          {'title': 'Sub Materi 1', 'page': null, 'icon': Icons.folder_off},
        ]
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('04SIFE002 Mobile Programming'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: pertemuanData.length,
        itemBuilder: (context, index) {
          final data = pertemuanData[index];
          return _buildExpansionTile(
            context: context,
            title: data['title'],
            icon: data['icon'],
            subItems: data['subItems'],
          );
        },
      ),
    );
  }
}

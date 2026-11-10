import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationTab extends StatefulWidget {
  const NotificationTab({super.key});

  @override
  State<NotificationTab> createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController(
    text: 'Praktikum Mobile Programming',
  );
  final TextEditingController _bodyController = TextEditingController(
    text: 'Halo! Ini adalah notifikasi lokal dari modul Pertemuan 10.',
  );

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  PermissionStatus _permissionStatus = PermissionStatus.denied;
  bool _isScheduling = false;
  int _notificationCounter = 0;
  String? _lastNotificationTime;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Callback saat pengguna menekan notifikasi di status bar
      },
    );

    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.notification.status;
    if (!mounted) return;
    setState(() {
      _permissionStatus = status;
    });
  }

  Future<bool> _requestPermission() async {
    final status = await Permission.notification.request();
    if (!mounted) return false;
    setState(() {
      _permissionStatus = status;
    });

    if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog();
      return false;
    }
    return status.isGranted;
  }

  void _showPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izin Notifikasi Ditolak Permanen'),
        content: const Text(
          'Aplikasi membutuhkan izin untuk memunculkan notifikasi di status bar '
          '(terutama pada Android 13 / Tiramisu ke atas). '
          'Silakan aktifkan izin notifikasi pada Pengaturan Aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  NotificationDetails _getNotificationDetails() {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'ptm10_sensor_channel',
      'Praktikum 10 - Native & Sensor',
      channelDescription:
          'Kanal notifikasi lokal untuk praktikum modul 10 Mobile Programming',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker_ptm10',
      icon: '@mipmap/ic_launcher',
    );

    return const NotificationDetails(
      android: androidDetails,
    );
  }

  Future<void> _showInstantNotification() async {
    if (!_formKey.currentState!.validate()) return;

    final isGranted = await _requestPermission();
    if (!isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin notifikasi tidak diberikan.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    _notificationCounter++;
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    try {
      await _notificationsPlugin.show(
        id: _notificationCounter,
        title: title,
        body: body,
        notificationDetails: _getNotificationDetails(),
        payload: 'instant_notification_#$_notificationCounter',
      );

      if (!mounted) return;
      setState(() {
        _lastNotificationTime =
            DateTime.now().toLocal().toString().split('.').first;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Notifikasi instan terkirim! Silakan cek status bar Anda.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim notifikasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showDelayedNotification() async {
    if (!_formKey.currentState!.validate()) return;

    final isGranted = await _requestPermission();
    if (!isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin notifikasi tidak diberikan.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isScheduling = true;
    });

    _notificationCounter++;
    final currentId = _notificationCounter;
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifikasi dijadwalkan: akan muncul dalam 5 detik...'),
        duration: Duration(seconds: 4),
        backgroundColor: Colors.indigo,
      ),
    );

    Future.delayed(const Duration(seconds: 5), () async {
      try {
        await _notificationsPlugin.show(
          id: currentId,
          title: '[Tertunda 5s] $title',
          body: body,
          notificationDetails: _getNotificationDetails(),
          payload: 'delayed_notification_#$currentId',
        );

        if (mounted) {
          setState(() {
            _isScheduling = false;
            _lastNotificationTime =
                DateTime.now().toLocal().toString().split('.').first;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isScheduling = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengirim notifikasi tertunda: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  Widget _buildStatusChip() {
    Color chipColor;
    String statusText;
    IconData icon;

    if (_permissionStatus.isGranted) {
      chipColor = Colors.green;
      statusText = 'Izin Diberikan';
      icon = Icons.check_circle_outline;
    } else if (_permissionStatus.isPermanentlyDenied) {
      chipColor = Colors.red;
      statusText = 'Ditolak Permanen';
      icon = Icons.block;
    } else {
      chipColor = Colors.orange;
      statusText = 'Belum Diberikan';
      icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: chipColor),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: chipColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kartu Status Izin Notifikasi
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.notifications_active, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Status Izin Notifikasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      _buildStatusChip(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pada Android 13+ (API 33), izin POST_NOTIFICATIONS wajib disetujui '
                    'pengguna agar notifikasi lokal dapat muncul di layar.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _checkPermission,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Periksa Status'),
                      ),
                      const SizedBox(width: 8),
                      if (!_permissionStatus.isGranted &&
                          !_permissionStatus.isPermanentlyDenied)
                        ElevatedButton.icon(
                          onPressed: _requestPermission,
                          icon: const Icon(Icons.security, size: 18),
                          label: const Text('Minta Izin'),
                        ),
                      if (_permissionStatus.isPermanentlyDenied)
                        ElevatedButton.icon(
                          onPressed: openAppSettings,
                          icon: const Icon(Icons.settings, size: 18),
                          label: const Text('Pengaturan'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Form Input Notifikasi
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.edit_note, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text(
                          'Kustomisasi Konten Notifikasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Judul Notifikasi',
                        hintText: 'Masukkan judul notifikasi',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Judul notifikasi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bodyController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Isi / Pesan Notifikasi',
                        hintText: 'Masukkan pesan notifikasi yang ingin dikirim',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.message),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Isi pesan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tombol Aksi Notifikasi
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showInstantNotification,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'Kirim Instan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isScheduling ? null : _showDelayedNotification,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: _isScheduling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.timer),
                  label: Text(
                    _isScheduling ? 'Menunggu 5s...' : 'Tertunda (5s)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Log Ringkasan Pengiriman
          Card(
            elevation: 1,
            color: Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Kanal Notifikasi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• Channel ID: ptm10_sensor_channel\n'
                    '• Channel Name: Praktikum 10 - Native & Sensor\n'
                    '• Importance: High (Popup banner & suara)\n'
                    '• Icon: @mipmap/ic_launcher\n'
                    '• Total notifikasi dikirim: $_notificationCounter kali',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  if (_lastNotificationTime != null) ...[
                    const Divider(height: 16),
                    Text(
                      'Waktu pengiriman terakhir: $_lastNotificationTime',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


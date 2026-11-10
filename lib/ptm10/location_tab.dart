import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationTab extends StatefulWidget {
  const LocationTab({super.key});

  @override
  State<LocationTab> createState() => _LocationTabState();
}

class _LocationTabState extends State<LocationTab>
    with AutomaticKeepAliveClientMixin {
  Position? _currentPosition;
  bool _isLoading = false;
  bool _isTracking = false;
  bool _isServiceEnabled = false;
  LocationPermission _permissionStatus = LocationPermission.denied;
  String? _statusMessage;
  StreamSubscription<Position>? _positionStream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _checkServiceAndPermission();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _checkServiceAndPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();
    if (!mounted) return;
    setState(() {
      _isServiceEnabled = serviceEnabled;
      _permissionStatus = permission;
    });
  }

  void _showServiceDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Layanan Lokasi (GPS) Mati'),
        content: const Text(
          'GPS pada perangkat Anda saat ini sedang dinonaktifkan. '
          'Silakan aktifkan GPS pada pengaturan perangkat agar aplikasi dapat membaca posisi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text('Buka Pengaturan GPS'),
          ),
        ],
      ),
    );
  }

  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izin Lokasi Ditolak Permanen'),
        content: const Text(
          'Aplikasi membutuhkan izin akses lokasi perangkat. '
          'Izin telah ditolak secara permanen. Silakan berikan izin melalui Pengaturan Aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      _isServiceEnabled = serviceEnabled;
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _statusMessage =
              'Layanan GPS tidak aktif. Silakan hidupkan GPS perangkat.';
          _isLoading = false;
        });
        _showServiceDisabledDialog();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      _permissionStatus = permission;

      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _statusMessage = 'Izin akses lokasi ditolak oleh pengguna.';
          _isLoading = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _statusMessage =
              'Izin lokasi ditolak permanen. Aktifkan lewat Pengaturan Aplikasi.';
          _isLoading = false;
        });
        _showPermissionPermanentlyDeniedDialog();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _statusMessage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi GPS saat ini berhasil diambil!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Terjadi kesalahan saat membaca GPS: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleLiveTracking() async {
    if (_isTracking) {
      await _positionStream?.cancel();
      _positionStream = null;
      if (!mounted) return;
      setState(() {
        _isTracking = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Live tracking GPS dinonaktifkan.'),
        ),
      );
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    _isServiceEnabled = serviceEnabled;
    if (!serviceEnabled) {
      _showServiceDisabledDialog();
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    _permissionStatus = permission;

    if (permission == LocationPermission.deniedForever) {
      _showPermissionPermanentlyDeniedDialog();
      return;
    }

    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin lokasi diperlukan untuk live tracking.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isTracking = true;
      _statusMessage = null;
    });

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        if (!mounted) return;
        setState(() {
          _currentPosition = position;
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _isTracking = false;
          _statusMessage = 'Gagal memantau pergerakan lokasi: $e';
        });
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Live tracking GPS aktif. Memperbarui realtime.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildStatusChip(
    String label,
    bool isOk, {
    String? customOkText,
    String? customBadText,
  }) {
    final color = isOk ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOk ? Icons.check_circle : Icons.error_outline,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isOk
                ? (customOkText ?? '$label: Aktif')
                : (customBadText ?? '$label: Mati'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final bool isPermissionGranted =
        _permissionStatus == LocationPermission.always ||
            _permissionStatus == LocationPermission.whileInUse;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kartu Status Layanan & Izin
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
                          Icon(Icons.satellite_alt, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Status Sensor GPS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        tooltip: 'Periksa Status',
                        onPressed: _checkServiceAndPermission,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildStatusChip('GPS Service', _isServiceEnabled),
                      _buildStatusChip(
                        'Izin Lokasi',
                        isPermissionGranted,
                        customOkText: 'Izin: Diberikan',
                        customBadText:
                            _permissionStatus == LocationPermission.deniedForever
                                ? 'Izin: Ditolak Permanen'
                                : 'Izin: Belum Diberikan',
                      ),
                      if (_isTracking)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.5)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.stream, size: 14, color: Colors.blue),
                              SizedBox(width: 4),
                              Text(
                                'Live Tracking Aktif',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (!_isServiceEnabled ||
                      _permissionStatus == LocationPermission.deniedForever) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (!_isServiceEnabled)
                          OutlinedButton.icon(
                            onPressed: Geolocator.openLocationSettings,
                            icon: const Icon(Icons.location_on, size: 16),
                            label: const Text('Aktifkan GPS'),
                          ),
                        if (_permissionStatus ==
                            LocationPermission.deniedForever)
                          OutlinedButton.icon(
                            onPressed: Geolocator.openAppSettings,
                            icon: const Icon(Icons.settings, size: 16),
                            label: const Text('Buka Pengaturan'),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (_statusMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.amber.shade800),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _statusMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Kartu Data Koordinat
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
                          Icon(Icons.place, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Data Koordinat & Posisi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (_currentPosition == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_searching,
                              size: 56,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada data koordinat',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tekan tombol di bawah untuk membaca lokasi',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    _buildDetailRow(
                      Icons.navigation,
                      'Latitude (Lintang)',
                      _currentPosition!.latitude.toStringAsFixed(6),
                    ),
                    _buildDetailRow(
                      Icons.navigation_outlined,
                      'Longitude (Bujur)',
                      _currentPosition!.longitude.toStringAsFixed(6),
                    ),
                    _buildDetailRow(
                      Icons.gps_fixed,
                      'Akurasi',
                      '± ${_currentPosition!.accuracy.toStringAsFixed(2)} meter',
                    ),
                    _buildDetailRow(
                      Icons.height,
                      'Ketinggian (Altitude)',
                      '${_currentPosition!.altitude.toStringAsFixed(2)} mdpl',
                    ),
                    _buildDetailRow(
                      Icons.speed,
                      'Kecepatan (Speed)',
                      '${_currentPosition!.speed.toStringAsFixed(2)} m/s (${(_currentPosition!.speed * 3.6).toStringAsFixed(2)} km/h)',
                    ),
                    _buildDetailRow(
                      Icons.access_time,
                      'Waktu Pembacaan',
                      _currentPosition!.timestamp.toLocal().toString().split('.').first,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tombol Aksi Lokasi
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _getCurrentLocation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.my_location),
                label: Text(
                  _isLoading ? 'Mencari Koordinat...' : 'Ambil Lokasi Saat Ini',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _toggleLiveTracking,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: _isTracking ? Colors.red : Colors.blue.shade800,
                  side: BorderSide(
                    color: _isTracking ? Colors.red : Colors.blue.shade800,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  _isTracking ? Icons.stop_circle : Icons.play_circle_fill,
                ),
                label: Text(
                  _isTracking
                      ? 'Hentikan Live Tracking'
                      : 'Mulai Live Tracking (Realtime)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


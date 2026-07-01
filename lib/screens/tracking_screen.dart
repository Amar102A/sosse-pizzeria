import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';

class TrackingScreen extends StatefulWidget {
  final int narudzbaId;
  const TrackingScreen({super.key, required this.narudzbaId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final MapController _mapController = MapController();
  Timer? _timer;

  LatLng? _dostavljacLokacija;
  LatLng? _dostavaLokacija;
  String _status = 'Na čekanju';
  bool _isLoading = true;

  static const LatLng _pizzerija = LatLng(43.8476, 18.3564);

  @override
  void initState() {
    super.initState();
    _ucitajPodatke();
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _ucitajPodatke(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _ucitajPodatke() async {
    final podaci = await ApiService.getNarudzbaPracenje(widget.narudzbaId);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (podaci != null) {
        _status = podaci['status'] ?? 'Na čekanju';
        final dLat = podaci['dostavljacLatitude'];
        final dLng = podaci['dostavljacLongitude'];
        _dostavljacLokacija = (dLat != null && dLng != null)
            ? LatLng((dLat as num).toDouble(), (dLng as num).toDouble())
            : _pizzerija;
        final lat = podaci['latitude'];
        final lng = podaci['longitude'];
        if (lat != null && lng != null) {
          _dostavaLokacija =
              LatLng((lat as num).toDouble(), (lng as num).toDouble());
        }
      }
    });
  }

  Color get _statusBoja {
    switch (_status) {
      case 'U pripremi': return Colors.blue;
      case 'U dostavi': return Colors.green;
      case 'Dostavljeno': return Colors.grey;
      default: return Colors.orange;
    }
  }

  IconData get _statusIkona {
    switch (_status) {
      case 'U pripremi': return Icons.local_pizza;
      case 'U dostavi': return Icons.delivery_dining;
      case 'Dostavljeno': return Icons.check_circle;
      default: return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _dostavljacLokacija ?? _pizzerija;

    final markers = <Marker>[
      Marker(
        point: _pizzerija,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFB71C1C),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              const Icon(Icons.local_pizza, color: Colors.white, size: 18),
        ),
      ),
      if (_dostavljacLokacija != null)
        Marker(
          point: _dostavljacLokacija!,
          child: const Icon(Icons.delivery_dining, color: Colors.blue, size: 42),
        ),
      if (_dostavaLokacija != null)
        Marker(
          point: _dostavaLokacija!,
          child: const Icon(Icons.location_pin, color: Color(0xFFB71C1C), size: 42),
        ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB71C1C),
        title: const Text(
          'Praćenje narudžbe',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _ucitajPodatke,
          ),
        ],
      ),
      body: Column(
        children: [
          // STATUS KARTICA
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _statusBoja.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(_statusIkona, color: _statusBoja, size: 26),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status narudžbe',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(
                      _status,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _statusBoja,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFFB71C1C)),
                  ),
              ],
            ),
          ),

          // PROGRESS KORACI
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _Korak(label: 'Primljeno', icon: Icons.receipt_long, active: true),
                _Linija(
                    active: _status == 'U pripremi' ||
                        _status == 'U dostavi' ||
                        _status == 'Dostavljeno'),
                _Korak(
                    label: 'Priprema',
                    icon: Icons.local_pizza,
                    active: _status == 'U pripremi' ||
                        _status == 'U dostavi' ||
                        _status == 'Dostavljeno'),
                _Linija(
                    active: _status == 'U dostavi' ||
                        _status == 'Dostavljeno'),
                _Korak(
                    label: 'Dostava',
                    icon: Icons.delivery_dining,
                    active: _status == 'U dostavi' ||
                        _status == 'Dostavljeno'),
                _Linija(active: _status == 'Dostavljeno'),
                _Korak(
                    label: 'Dostavljeno',
                    icon: Icons.check_circle,
                    active: _status == 'Dostavljeno'),
              ],
            ),
          ),

          // LEGENDA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _LegendaItem(
                    icon: Icons.local_pizza,
                    color: const Color(0xFFB71C1C),
                    label: 'Pizzerija'),
                const SizedBox(width: 16),
                _LegendaItem(
                    icon: Icons.delivery_dining,
                    color: Colors.blue,
                    label: 'Dostavljač'),
                const SizedBox(width: 16),
                _LegendaItem(
                    icon: Icons.location_pin,
                    color: const Color(0xFFB71C1C),
                    label: 'Vaša lokacija'),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // MAPA SA ZOOM
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 13,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.pica_app',
                        ),
                        if (_dostavaLokacija != null &&
                            _dostavljacLokacija != null)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [
                                  _dostavljacLokacija!,
                                  _dostavaLokacija!
                                ],
                                strokeWidth: 3.5,
                                color: Colors.blue.withOpacity(0.55),
                              ),
                            ],
                          ),
                        MarkerLayer(markers: markers),
                      ],
                    ),
                    // ZOOM DUGMAD
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Column(
                        children: [
                          _ZoomButton(
                            icon: Icons.add,
                            onTap: () => _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom + 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _ZoomButton(
                            icon: Icons.remove,
                            onTap: () => _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom - 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // FOOTER
          Container(
            padding: const EdgeInsets.all(14),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Narudžba #${widget.narudzbaId}  •  osvježava se svakih 5s',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Korak extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  const _Korak({required this.label, required this.icon, required this.active});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFB71C1C) : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15,
              color: active ? Colors.white : Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? const Color(0xFFB71C1C) : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _Linija extends StatelessWidget {
  final bool active;
  const _Linija({required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: active ? const Color(0xFFB71C1C) : Colors.grey[200],
      ),
    );
  }
}

class _LegendaItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _LegendaItem({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}

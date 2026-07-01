import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/auth_state.dart';
import '../services/api_service.dart';
import 'tracking_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  String _nacinPlacanja = 'Gotovina';
  bool _isLoading = false;

  static const LatLng _defaultCenter = LatLng(43.8476, 18.3564);

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB71C1C),
        title: const Text(
          'Završi narudžbu',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: 'Lokacija dostave'),
                  const SizedBox(height: 4),
                  const Text(
                    'Tapnite na mapi da odaberete vašu lokaciju',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),

                  // MAPA SA ZOOM
                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _defaultCenter,
                              initialZoom: 13.5,
                              onTap: (tapPosition, point) {
                                setState(() {
                                  _selectedLocation = point;
                                });
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.pica_app',
                              ),
                              MarkerLayer(
                                markers: [
                                  if (_selectedLocation != null)
                                    Marker(
                                      point: _selectedLocation!,
                                      child: const Icon(
                                        Icons.location_pin,
                                        color: Color(0xFFB71C1C),
                                        size: 44,
                                      ),
                                    ),
                                ],
                              ),
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

                  const SizedBox(height: 10),
                  _LocationStatusBanner(location: _selectedLocation),

                  const SizedBox(height: 24),

                  _SectionTitle(title: 'Način plaćanja'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _PaymentOption(
                        label: 'Gotovina',
                        icon: Icons.payments_outlined,
                        selected: _nacinPlacanja == 'Gotovina',
                        onTap: () =>
                            setState(() => _nacinPlacanja = 'Gotovina'),
                      ),
                      const SizedBox(width: 12),
                      _PaymentOption(
                        label: 'Platna kartica',
                        icon: Icons.credit_card,
                        selected: _nacinPlacanja == 'Platna kartica',
                        onTap: () =>
                            setState(() => _nacinPlacanja = 'Platna kartica'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _SectionTitle(title: 'Pregled narudžbe'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ...cart.stavke.map((s) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${s.naziv} x${s.kolicina}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  Text(
                                    '${(s.cijena * s.kolicina).toStringAsFixed(2)} KM',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ukupno:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              '${cart.ukupno.toStringAsFixed(2)} KM',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFFB71C1C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.payment,
                                size: 15, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              _nacinPlacanja,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // POTVRDI DUGME
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: (_selectedLocation != null && !_isLoading)
                    ? () => _naruci(context, cart)
                    : null,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Potvrdi narudžbu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _naruci(BuildContext context, CartProvider cart) async {
    setState(() => _isLoading = true);

    final korisnik = AuthState.korisnik!;
    final stavke = cart.stavke
        .map((s) => {
              'pizzaId': s.pizzaId,
              'kolicina': s.kolicina,
              'cijena': s.cijena,
            })
        .toList();

    final narudzbaId = await ApiService.kreirajNarudzbu(
      korisnikId: korisnik['korisnikId'],
      ukupnaCijena: cart.ukupno,
      stavke: stavke,
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
      nacinPlacanja: _nacinPlacanja,
    );

    setState(() => _isLoading = false);
    if (!context.mounted) return;

    if (narudzbaId != null) {
      cart.ocistiKorpu();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TrackingScreen(narudzbaId: narudzbaId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Greška pri slanju narudžbe!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF212121)),
    );
  }
}

class _LocationStatusBanner extends StatelessWidget {
  final LatLng? location;
  const _LocationStatusBanner({this.location});

  @override
  Widget build(BuildContext context) {
    if (location != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Odabrana lokacija: ${location!.latitude.toStringAsFixed(4)}, '
                '${location!.longitude.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 12, color: Colors.green),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 18),
          SizedBox(width: 8),
          Text(
            'Tapnite na mapi da odaberete lokaciju dostave',
            style: TextStyle(fontSize: 12, color: Colors.orange),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFB71C1C) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFFB71C1C) : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? Colors.white : Colors.grey[600],
                  size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
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

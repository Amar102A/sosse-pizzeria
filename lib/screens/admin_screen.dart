import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';

class AdminAuth {
  static bool isLoggedIn = false;
  static const String _username = 'admin';
  static const String _password = 'admin123';

  static bool login(String username, String password) {
    if (username.trim() == _username && password == _password) {
      isLoggedIn = true;
      return true;
    }
    return false;
  }

  static void logout() => isLoggedIn = false;
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> _narudzbe = [];
  bool _isLoading = true;
  bool _apiGreska = false;
  String _filterStatus = 'Sve';
  Timer? _refreshTimer;

  static const List<String> _statusi = [
    'Sve', 'Na čekanju', 'U pripremi', 'U dostavi', 'Dostavljeno',
  ];

  @override
  void initState() {
    super.initState();
    if (AdminAuth.isLoggedIn) {
      _ucitaj();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (AdminAuth.isLoggedIn && mounted) _ucitaj();
    });
  }

  Future<void> _ucitaj() async {
    setState(() { _isLoading = true; _apiGreska = false; });
    try {
      final data = await ApiService.getAllNarudzbe();
      if (mounted) {
        setState(() {
          _narudzbe = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _apiGreska = true;
        });
      }
    }
  }

  List<dynamic> get _filtrirane {
    if (_filterStatus == 'Sve') return _narudzbe;
    return _narudzbe.where((n) => n['status'] == _filterStatus).toList();
  }

  Color _statusBoja(String? status) {
    switch (status) {
      case 'U pripremi': return Colors.blue;
      case 'U dostavi': return Colors.green;
      case 'Dostavljeno': return Colors.grey;
      default: return Colors.orange;
    }
  }

  Future<void> _promijeniStatus(int id, String noviStatus) async {
    await ApiService.azurirajStatusNarudzbe(id, noviStatus);
    _ucitaj();
  }

  void _logout() {
    AdminAuth.logout();
    _refreshTimer?.cancel();
    setState(() { _narudzbe = []; _apiGreska = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (!AdminAuth.isLoggedIn) {
      return _AdminLoginView(
        onLogin: () {
          setState(() {});
          _ucitaj();
          _startTimer();
        },
      );
    }

    final naCekanju =
        _narudzbe.where((n) => n['status'] == 'Na čekanju').length;
    final uDostavi =
        _narudzbe.where((n) => n['status'] == 'U dostavi').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF37474F),
        title: const Text(
          'Admin Panel',
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _ucitaj,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: _logout,
            tooltip: 'Odjavi se',
          ),
        ],
      ),
      body: Column(
        children: [
          // STATISTIKE
          Container(
            color: const Color(0xFF37474F),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _StatKartica(
                    label: 'Ukupno',
                    value: '${_narudzbe.length}',
                    icon: Icons.receipt_long,
                    color: Colors.white),
                const SizedBox(width: 10),
                _StatKartica(
                    label: 'Na čekanju',
                    value: '$naCekanju',
                    icon: Icons.hourglass_empty,
                    color: Colors.orange),
                const SizedBox(width: 10),
                _StatKartica(
                    label: 'U dostavi',
                    value: '$uDostavi',
                    icon: Icons.delivery_dining,
                    color: Colors.green),
              ],
            ),
          ),

          // FILTER CHIPS
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusi.map((s) {
                  final active = _filterStatus == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(s),
                      selected: active,
                      onSelected: (_) =>
                          setState(() => _filterStatus = s),
                      selectedColor: const Color(0xFF37474F),
                      labelStyle: TextStyle(
                        color: active ? Colors.white : Colors.black87,
                        fontWeight: active
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      checkmarkColor: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // LISTA / GRESKA
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _apiGreska
                    ? _ApiGreskaView(onRetry: _ucitaj)
                    : _filtrirane.isEmpty
                        ? const Center(
                            child: Text('Nema narudžbi',
                                style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _filtrirane.length,
                            itemBuilder: (context, i) {
                              final n = _filtrirane[i]
                                  as Map<String, dynamic>;
                              final id = n['narudzbaId'] as int;
                              final status = n['status'] as String? ??
                                  'Na čekanju';
                              return Card(
                                margin:
                                    const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('#$id',
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  fontSize: 16)),
                                          const SizedBox(width: 10),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 3),
                                            decoration: BoxDecoration(
                                              color: _statusBoja(status)
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20),
                                            ),
                                            child: Text(
                                              status,
                                              style: TextStyle(
                                                color:
                                                    _statusBoja(status),
                                                fontSize: 12,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            '${(n['ukupnaCijena'] as num).toStringAsFixed(2)} KM',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFB71C1C)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.person,
                                              size: 14,
                                              color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                              n['korisnikIme'] ??
                                                  'Nepoznat',
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey)),
                                          const SizedBox(width: 14),
                                          const Icon(Icons.payment,
                                              size: 14,
                                              color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                              n['nacinPlacanja'] ?? '-',
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildStatusAkcije(
                                          context, id, status, n),
                                    ],
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

  Widget _buildStatusAkcije(
      BuildContext context,
      int id,
      String status,
      Map<String, dynamic> n) {
    if (status == 'Na čekanju') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _promijeniStatus(id, 'U pripremi'),
          icon: const Icon(Icons.check_circle_outline,
              size: 18, color: Colors.white),
          label: const Text(
            'Prihvati narudžbu',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      );
    }

    if (status == 'Dostavljeno') {
      return const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.grey, size: 16),
          SizedBox(width: 6),
          Text('Narudžba završena',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatusChip(
            label: 'U pripremi',
            active: status == 'U pripremi',
            color: Colors.blue,
            onTap: () => _promijeniStatus(id, 'U pripremi'),
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'U dostavi',
            active: status == 'U dostavi',
            color: Colors.green,
            onTap: () => _promijeniStatus(id, 'U dostavi'),
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'Dostavljeno',
            active: false,
            color: Colors.grey,
            onTap: () => _promijeniStatus(id, 'Dostavljeno'),
          ),
          if (status == 'U dostavi') ...
          [
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _otvoriMapuDostavljaca(context, n),
              icon: const Icon(Icons.my_location, size: 14),
              label:
                  const Text('GPS', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _otvoriMapuDostavljaca(
      BuildContext context, Map<String, dynamic> narudzba) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DostavljacMapaSheet(
        narudzbaId: narudzba['narudzbaId'] as int,
        initialLat:
            (narudzba['dostavljacLatitude'] as num?)?.toDouble() ??
                43.8476,
        initialLng:
            (narudzba['dostavljacLongitude'] as num?)?.toDouble() ??
                18.3564,
        onSaved: _ucitaj,
      ),
    );
  }
}

// ─────────────────────── API GRESKA VIEW ───────────────────────

class _ApiGreskaView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ApiGreskaView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Nije moguće spojiti se na server',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Provjeri da li je API pokrenut na\nlocalhost:5188 i da li je baza spojena.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Pokušaj ponovo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF37474F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── ADMIN LOGIN ───────────────────────

class _AdminLoginView extends StatefulWidget {
  final VoidCallback onLogin;
  const _AdminLoginView({required this.onLogin});

  @override
  State<_AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<_AdminLoginView> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _error = false;
  bool _loading = false;

  void _login() {
    setState(() { _loading = true; _error = false; });
    final ok = AdminAuth.login(_usernameCtrl.text, _passwordCtrl.text);
    setState(() => _loading = false);
    if (ok) {
      widget.onLogin();
    } else {
      setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF37474F),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings,
                  size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'Admin Pristup',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Unesite pristupne podatke',
                style:
                    TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 36),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _usernameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Korisničko ime',
                        prefixIcon:
                            const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: _error ? ' ' : null,
                      ),
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Lozinka',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: _error
                            ? 'Pogrešno korisničko ime ili lozinka'
                            : null,
                      ),
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF37474F),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Prijava',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── DOSTAVLJAČ MAPA ───────────────────────

class _DostavljacMapaSheet extends StatefulWidget {
  final int narudzbaId;
  final double initialLat;
  final double initialLng;
  final VoidCallback onSaved;

  const _DostavljacMapaSheet({
    required this.narudzbaId,
    required this.initialLat,
    required this.initialLng,
    required this.onSaved,
  });

  @override
  State<_DostavljacMapaSheet> createState() =>
      _DostavljacMapaSheetState();
}

class _DostavljacMapaSheetState extends State<_DostavljacMapaSheet> {
  late LatLng _lokacija;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _lokacija = LatLng(widget.initialLat, widget.initialLng);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Postavi lokaciju dostavljača',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const Text(
                    'Tapnite na mapu da premjestite dostavljača',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _lokacija,
                initialZoom: 14,
                onTap: (_, point) =>
                    setState(() => _lokacija = point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.pica_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _lokacija,
                      child: const Icon(Icons.delivery_dining,
                          color: Colors.blue, size: 42),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        await ApiService.azurirajLokacijuDostavljaca(
                          widget.narudzbaId,
                          _lokacija.latitude,
                          _lokacija.longitude,
                        );
                        setState(() => _saving = false);
                        widget.onSaved();
                        if (mounted) Navigator.of(context).pop();
                      },
                child: _saving
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text('Postavi lokaciju',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── POMOĆNI WIDGETI ───────────────────────

class _StatKartica extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatKartica(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _StatusChip(
      {required this.label,
      required this.active,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: active ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color : Colors.transparent,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

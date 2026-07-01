import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_state.dart';
import '../services/api_service.dart';
import '../services/narudzba_state.dart';
import '../providers/cart_provider.dart';
import 'login_screen.dart';
import 'tracking_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int? _aktivnaNarudzbaId;

  @override
  void initState() {
    super.initState();
    _ucitajAktivnu();
  }

  Future<void> _ucitajAktivnu() async {
    final id = await NarudzbaState.ucitaj();
    if (mounted) setState(() => _aktivnaNarudzbaId = id);
  }

  @override
  Widget build(BuildContext context) {
    final korisnik = AuthState.korisnik;
    final isPrijavljen = AuthState.isPrijavljen;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB71C1C),
        title: const Text(
          "Profil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isPrijavljen
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // AKTIVNA NARUDZBA BANNER
                  if (_aktivnaNarudzbaId != null)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrackingScreen(
                                narudzbaId: _aktivnaNarudzbaId!),
                          ),
                        ).then((_) => _ucitajAktivnu());
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 28),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.delivery_dining,
                                color: Colors.white, size: 38),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'AKTIVNA NARUDŽBA',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2),
                                  ),
                                  Text(
                                    'Narudžba #$_aktivnaNarudzbaId',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Text(
                                    'Tapni za praćenje dostave →',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_forward_ios,
                                  color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // AVATAR
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB71C1C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person,
                        size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "${korisnik!['ime']} ${korisnik['prezime']}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "@${korisnik['username']}",
                    style:
                        TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    korisnik['email'],
                    style:
                        TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // INFO KARTICE
                  _infoKartica(
                      Icons.email, "Email", korisnik['email']),
                  const SizedBox(height: 12),
                  _infoKartica(Icons.person, "Username",
                      korisnik['username']),
                  const SizedBox(height: 32),

                  // LOGOUT
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.logout,
                          color: Colors.white),
                      label: const Text(
                        "Odjavi se",
                        style: TextStyle(
                            color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () {
                        AuthState.logout();
                        setState(() {});
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // MOJE PIZZE
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Moje spremljene pizze ❤️",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<dynamic>>(
                    future: ApiService.getCustomPizze(
                        korisnik['korisnikId']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFB71C1C)),
                        );
                      }
                      if (!snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              "Nemate spremljenih pizza",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final pizza = snapshot.data![index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_pizza,
                                    color: Color(0xFFB71C1C),
                                    size: 40),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pizza['naziv'] ?? 'Custom Pizza',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${pizza['velicina']} • ${pizza['tijesto']} • ${pizza['sos']}",
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${(pizza['ukupnaCijena'] as num).toStringAsFixed(2)} KM",
                                  style: const TextStyle(
                                    color: Color(0xFFB71C1C),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                      Icons.add_shopping_cart,
                                      color: Color(0xFFB71C1C)),
                                  onPressed: () {
                                    final cart =
                                        Provider.of<CartProvider>(
                                            context,
                                            listen: false);
                                    cart.dodajUKorpu(CartItem(
                                      pizzaId: 999,
                                      naziv: pizza['naziv'] ??
                                          'Custom Pizza',
                                      cijena: (pizza['ukupnaCijena']
                                              as num)
                                          .toDouble(),
                                      imagePath:
                                          "assets/images/margarita.png",
                                    ));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Pizza dodana u korpu! 🍕"),
                                        backgroundColor:
                                            Color(0xFFB71C1C),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    final uspjeh =
                                        await ApiService
                                            .obrisiCustomPizzu(
                                      pizza['customPizzaId'],
                                    );
                                    if (uspjeh && mounted) {
                                      setState(() {});
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text("Pizza obrisana!"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // HISTORIJA NARUDZBI
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Historija narudžbi 🛵",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<dynamic>>(
                    future: ApiService.getNarudzbe(
                        korisnik['korisnikId']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFB71C1C)),
                        );
                      }
                      if (!snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              "Nemate narudžbi",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final narudzba = snapshot.data![index];
                          final String status =
                              narudzba['status'] as String? ??
                                  'Na čekanju';
                          final int narudzbaId =
                              (narudzba['narudzbаId'] as num)
                                  .toInt();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.receipt_long,
                                    color: Color(0xFFB71C1C),
                                    size: 40),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Narudžba #$narudzbaId",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        status,
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${(narudzba['ukupnaCijena'] as num).toStringAsFixed(2)} KM",
                                  style: const TextStyle(
                                    color: Color(0xFFB71C1C),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                // PRATI dugme za aktivne narudzbe
                                if (status != 'Dostavljeno')
                                  IconButton(
                                    icon: const Icon(
                                        Icons.delivery_dining,
                                        color: Color(0xFFB71C1C)),
                                    tooltip: 'Prati narudžbu',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => TrackingScreen(
                                              narudzbaId: narudzbaId),
                                        ),
                                      ).then((_) => _ucitajAktivnu());
                                    },
                                  ),
                                // OBRISI
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    final uspjeh =
                                        await ApiService.obrisiNarudzbu(
                                      narudzbaId,
                                    );
                                    if (uspjeh && mounted) {
                                      setState(() {});
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Narudžba obrisana!"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Niste prijavljeni",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB71C1C),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                      setState(() {});
                    },
                    child: const Text(
                      "Prijavi se",
                      style:
                          TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoKartica(IconData icon, String label, String value) {
    return Container(
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
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFB71C1C)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}

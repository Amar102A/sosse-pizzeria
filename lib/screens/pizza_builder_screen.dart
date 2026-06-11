import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../services/auth_state.dart';

class PizzaBuilderScreen extends StatefulWidget {
  const PizzaBuilderScreen({super.key});

  @override
  State<PizzaBuilderScreen> createState() => _PizzaBuilderScreenState();
}

class _PizzaBuilderScreenState extends State<PizzaBuilderScreen> {
  String _velicina = 'Srednja';
  String _tijesto = 'Tanko';
  String _sos = 'Paradajz';
  List<dynamic> _sviSastojci = [];
  List<int> _odabraniSastojci = [];
  bool _loading = true;

  final Map<String, double> _velicinecijena = {
    'Mala': 5.00,
    'Srednja': 8.00,
    'Velika': 11.00,
  };

  @override
  void initState() {
    super.initState();
    _ucitajSastojke();
  }

  Future<void> _ucitajSastojke() async {
    try {
      final sastojci = await ApiService.getSastojci();
      setState(() {
        _sviSastojci = sastojci;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  double get _ukupnaCijena {
    double cijena = _velicinecijena[_velicina] ?? 8.00;
    for (var s in _sviSastojci) {
      if (_odabraniSastojci.contains(s['sastojakId'])) {
        cijena += (s['cijena'] as num).toDouble();
      }
    }
    return cijena;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB71C1C),
        title: const Text(
          "Pizza Builder",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFB71C1C)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // VELICINA
                  _sekcija("📏 Veličina"),
                  Row(
                    children: ['Mala', 'Srednja', 'Velika'].map((v) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _velicina = v),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _velicina == v
                                  ? const Color(0xFFB71C1C)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFB71C1C),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  v,
                                  style: TextStyle(
                                    color: _velicina == v
                                        ? Colors.white
                                        : const Color(0xFFB71C1C),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "${_velicinecijena[v]!.toStringAsFixed(2)} KM",
                                  style: TextStyle(
                                    color: _velicina == v
                                        ? Colors.white70
                                        : Colors.grey,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // TIJESTO
                  _sekcija("🫓 Tijesto"),
                  Row(
                    children: ['Tanko', 'Debelo', 'Punjeno'].map((t) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tijesto = t),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _tijesto == t
                                  ? const Color(0xFFB71C1C)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFB71C1C),
                              ),
                            ),
                            child: Text(
                              t,
                              style: TextStyle(
                                color: _tijesto == t
                                    ? Colors.white
                                    : const Color(0xFFB71C1C),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // SOS
                  _sekcija("🍅 Sos"),
                  Row(
                    children: ['Paradajz', 'Bijeli', 'BBQ'].map((s) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _sos = s),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _sos == s
                                  ? const Color(0xFFB71C1C)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFB71C1C),
                              ),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                color: _sos == s
                                    ? Colors.white
                                    : const Color(0xFFB71C1C),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // SASTOJCI
                  _sekcija("🧀 Sastojci"),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 3,
                    ),
                    itemCount: _sviSastojci.length,
                    itemBuilder: (context, index) {
                      final s = _sviSastojci[index];
                      final id = s['sastojakId'] as int;
                      final odabran = _odabraniSastojci.contains(id);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (odabran) {
                              _odabraniSastojci.remove(id);
                            } else {
                              _odabraniSastojci.add(id);
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: odabran
                                ? const Color(0xFFB71C1C)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFB71C1C),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                odabran
                                    ? Icons.check_circle
                                    : Icons.add_circle_outline,
                                color: odabran
                                    ? Colors.white
                                    : const Color(0xFFB71C1C),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  "${s['naziv']} +${(s['cijena'] as num).toStringAsFixed(2)}KM",
                                  style: TextStyle(
                                    color: odabran
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // UKUPNO I DODAJ
                  Container(
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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Ukupno:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${_ukupnaCijena.toStringAsFixed(2)} KM",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB71C1C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
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
                            icon: const Icon(Icons.shopping_cart,
                                color: Colors.white),
                            label: const Text(
                              "Dodaj u korpu",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              final cart = Provider.of<CartProvider>(
                                context,
                                listen: false,
                              );
                              cart.dodajUKorpu(CartItem(
                                pizzaId: 999,
                                naziv:
                                    "Custom Pizza ($_velicina, $_tijesto, $_sos)",
                                cijena: _ukupnaCijena,
                                imagePath: "assets/images/margarita.png",
                              ));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Custom pizza dodana u korpu! 🍕"),
                                  backgroundColor: Color(0xFFB71C1C),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
// SPREMI PICU - samo ako je korisnik prijavljen
if (AuthState.isPrijavljen)
  SizedBox(
    width: double.infinity,
    height: 50,
    child: OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFB71C1C), width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: const Icon(Icons.favorite, color: Color(0xFFB71C1C)),
      label: const Text(
        "Spremi picu",
        style: TextStyle(
          color: Color(0xFFB71C1C),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () async {
  // Popup za naziv
  final naziv = await showDialog<String>(
    context: context,
    builder: (context) {
      final controller = TextEditingController();
      return AlertDialog(
        title: const Text("Naziv pizze"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Npr. Moja specijalna pizza",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Odustani"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
            ),
            onPressed: () {
              Navigator.pop(context, controller.text);
            },
            child: const Text(
              "Spremi",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );

  if (naziv == null || naziv.isEmpty) return;

  final korisnik = AuthState.korisnik!;
  final uspjeh = await ApiService.spremiCustomPizzu(
    korisnikId: korisnik['korisnikId'],
    naziv: naziv,
    velicina: _velicina,
    tijesto: _tijesto,
    sos: _sos,
    cijena: _ukupnaCijena,
  );

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(uspjeh
            ? "\"$naziv\" uspješno spremljena! "
            : "Greška pri spremanju!"),
        backgroundColor: uspjeh ? Colors.green : Colors.red,
      ),
    );
  }
},
    ),
  ),
if (!AuthState.isPrijavljen)
  const Padding(
    padding: EdgeInsets.only(top: 8),
    child: Text(
      "Prijavite se da biste spremili svoju picu ",
      style: TextStyle(color: Colors.grey, fontSize: 13),
      textAlign: TextAlign.center,
    ),
  ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _sekcija(String naziv) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        naziv,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
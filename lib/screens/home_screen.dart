import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'pizza_builder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _pizze = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ucitajPizze();
  }

  Future<void> _ucitajPizze() async {
    try {
      final pizze = await ApiService.getPizze();
      print("Pizze iz API: $pizze");
      setState(() {
        _pizze = pizze;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  String _getImagePath(String? slika) {
    if (slika == null) return '';
    return 'assets/images/$slika';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB71C1C),
        title: const Text(
          "🍕 Sosse Pizzeria",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
       
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO BANNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB71C1C), Color(0xFF7F0000)],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "Napravi svoju savršenu picu! 🍕",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Svježi sastojci, dostava na kućni prag",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                    ),
                    icon: const Icon(Icons.add_circle,
                        color: Color(0xFFB71C1C)),
                    label: const Text(
                      "Napravi svoju picu",
                      style: TextStyle(
                        color: Color(0xFFB71C1C),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PizzaBuilderScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // MENU NASLOV
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                "Naš Menu",
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            // LOADING ILI GRID
            _loading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                  )
                : _pizze.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text("Nema pizza u meniju"),
                        ),
                      )
                    : Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            int columns =
                                constraints.maxWidth > 600 ? 3 : 2;
                            double itemHeight = 280;
                            double itemWidth =
                                constraints.maxWidth / columns;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio:
                                    itemWidth / itemHeight,
                              ),
                              itemCount: _pizze.length,
                              itemBuilder: (context, index) {
                                final pizza = _pizze[index];
                                return PizzaCard(
                                  pizzaId: pizza['pizzaId'] ?? 0,
                                  naziv: pizza['naziv'] ?? '',
                                  cijena: pizza['cijena'].toString(),
                                  imagePath:
                                      _getImagePath(pizza['slika']),
                                  opis: pizza['opis'] ?? '',
                                );
                              },
                            );
                          },
                        ),
                      ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class PizzaCard extends StatelessWidget {
  final int pizzaId;
  final String naziv;
  final String cijena;
  final String imagePath;
  final String opis;

  const PizzaCard({
    super.key,
    required this.pizzaId,
    required this.naziv,
    required this.cijena,
    required this.imagePath,
    required this.opis,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              imagePath,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 160,
                color: Colors.grey[200],
                child: const Icon(Icons.local_pizza,
                    size: 60, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  naziv,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  opis,
                  style:
                      TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$cijena KM",
                      style: const TextStyle(
                        color: Color(0xFFB71C1C),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                         final cart = Provider.of<CartProvider>(
                           context,
                           listen: false,
                         );
                        cart.dodajUKorpu(CartItem(
                          pizzaId: pizzaId,
                          naziv: naziv,
                          cijena: double.tryParse(cijena.replaceAll(',', '.')) ?? 0,
                          imagePath: imagePath,
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("$naziv dodana u korpu!"),
                            duration: const Duration(seconds: 1),
                            backgroundColor: const Color(0xFFB71C1C),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFB71C1C),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
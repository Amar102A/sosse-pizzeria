import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/auth_state.dart';
import 'order_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB71C1C),
        title: const Text(
          'Korpa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.stavke.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Vaša korpa je prazna',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // LISTA STAVKI
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.stavke.length,
                  itemBuilder: (context, index) {
                    final stavka = cart.stavke[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                          // SLIKA
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(12)),
                            child: Image.asset(
                              stavka.imagePath,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 90,
                                height: 90,
                                color: Colors.grey[200],
                                child: const Icon(Icons.local_pizza,
                                    color: Colors.grey),
                              ),
                            ),
                          ),

                          // INFO
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stavka.naziv,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${stavka.cijena.toStringAsFixed(2)} KM',
                                    style: const TextStyle(
                                      color: Color(0xFFB71C1C),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // KOLICINA KONTROLE
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      cart.smanjiKolicinu(stavka.pizzaId),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFB71C1C),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.remove,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  child: Text(
                                    '${stavka.kolicina}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => cart.dodajUKorpu(CartItem(
                                    pizzaId: stavka.pizzaId,
                                    naziv: stavka.naziv,
                                    cijena: stavka.cijena,
                                    imagePath: stavka.imagePath,
                                  )),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFB71C1C),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // UKUPNO I DUGME
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ukupno:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${cart.ukupno.toStringAsFixed(2)} KM',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB71C1C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB71C1C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          if (!AuthState.isPrijavljen) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Prijavite se da biste naručili!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const OrderScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Nastavi na narudžbu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

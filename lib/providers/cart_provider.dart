import 'package:flutter/material.dart';

class CartItem {
  final int pizzaId;
  final String naziv;
  final double cijena;
  final String imagePath;
  int kolicina;

  CartItem({
    required this.pizzaId,
    required this.naziv,
    required this.cijena,
    required this.imagePath,
    this.kolicina = 1,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _stavke = [];

  List<CartItem> get stavke => _stavke;

  double get ukupno =>
      _stavke.fold(0, (sum, item) => sum + item.cijena * item.kolicina);

  int get brojStavki =>
      _stavke.fold(0, (sum, item) => sum + item.kolicina);

  void dodajUKorpu(CartItem item) {
    final postojeci = _stavke.where((s) => s.pizzaId == item.pizzaId);
    if (postojeci.isNotEmpty) {
      postojeci.first.kolicina++;
    } else {
      _stavke.add(item);
    }
    notifyListeners();
  }

  void ukloniIzKorpe(int pizzaId) {
    _stavke.removeWhere((s) => s.pizzaId == pizzaId);
    notifyListeners();
  }

  void smanjiKolicinu(int pizzaId) {
    final stavka = _stavke.where((s) => s.pizzaId == pizzaId).firstOrNull;
    if (stavka != null) {
      if (stavka.kolicina > 1) {
        stavka.kolicina--;
      } else {
        _stavke.remove(stavka);
      }
      notifyListeners();
    }
  }

  void ocistiKorpu() {
    _stavke.clear();
    notifyListeners();
  }
}
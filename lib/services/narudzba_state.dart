import 'package:shared_preferences/shared_preferences.dart';

class NarudzbaState {
  static const String _kljucId = 'aktivna_narudzba_id';

  static Future<void> sacuvaj(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kljucId, id);
  }

  static Future<int?> ucitaj() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kljucId);
  }

  static Future<void> obrisi() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kljucId);
  }
}

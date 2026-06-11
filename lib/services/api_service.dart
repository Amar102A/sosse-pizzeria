import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5188';

  // GET sve pizze
  static Future<List<dynamic>> getPizze() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/Pizze/GetAll'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Greška pri učitavanju pizza');
    }
  }

  // GET svi sastojci
  static Future<List<dynamic>> getSastojci() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/Sastojci/GetAll'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Greška pri učitavanju sastojaka');
    }
  }

  // Spremi custom pizzu
static Future<bool> spremiCustomPizzu({
  required int korisnikId,
  required String naziv,
  required String velicina,
  required String tijesto,
  required String sos,
  required double cijena,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/CustomPizza/Spremi'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'korisnikId': korisnikId,
      'naziv': naziv,
      'velicina': velicina,
      'tijesto': tijesto,
      'sos': sos,
      'ukupnaCijena': cijena,
    }),
  );
  return response.statusCode == 200;
}
// Obrisi custom pizzu
static Future<bool> obrisiCustomPizzu(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/api/CustomPizza/Obrisi/$id'),
  );
  return response.statusCode == 200;
}

// Get custom pizze po korisniku
static Future<List<dynamic>> getCustomPizze(int korisnikId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/CustomPizza/GetByKorisnik/$korisnikId'),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return [];
}

// Kreiraj narudžbu
static Future<bool> kreirajNarudzbu({
  required int korisnikId,
  required double ukupnaCijena,
  required List<Map<String, dynamic>> stavke,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/Narudzbe/KreirajNarudzbu'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'korisnikId': korisnikId,
      'ukupnaCijena': ukupnaCijena,
      'stavke': stavke,
    }),
  );
  return response.statusCode == 200;
}

// Get narudžbe po korisniku
static Future<List<dynamic>> getNarudzbe(int korisnikId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/Narudzbe/GetByKorisnik/$korisnikId'),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return [];
}
// Obrisi narudžbu
static Future<bool> obrisiNarudzbu(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/api/Narudzbe/ObrisiNarudzbu/$id'),
  );
  return response.statusCode == 200;
}

  // Registracija
  static Future<bool> registracija({
    required String ime,
    required String prezime,
    required String email,
    required String username,
    required String lozinka,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Korisnici/Registracija'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ime': ime,
        'prezime': prezime,
        'email': email,
        'username': username,
        'lozinka': lozinka,
      }),
    );

    return response.statusCode == 200;
  }

  // Login
  static Future<Map<String, dynamic>?> login({
    required String username,
    required String lozinka,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Korisnici/Login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'lozinka': lozinka,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}
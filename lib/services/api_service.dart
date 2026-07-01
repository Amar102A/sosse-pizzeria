import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5188';

  static Future<List<dynamic>> getPizze() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/Pizze/GetAll'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Greška pri učitavanju pizza');
  }

  static Future<List<dynamic>> getSastojci() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/Sastojci/GetAll'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Greška pri učitavanju sastojaka');
  }

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

  static Future<bool> obrisiCustomPizzu(int id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/api/CustomPizza/Obrisi/$id'));
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getCustomPizze(int korisnikId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/api/CustomPizza/GetByKorisnik/$korisnikId'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  // Vraća narudzbaId ili null ako greška
  static Future<int?> kreirajNarudzbu({
    required int korisnikId,
    required double ukupnaCijena,
    required List<Map<String, dynamic>> stavke,
    double? latitude,
    double? longitude,
    String nacinPlacanja = 'Gotovina',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Narudzbe/KreirajNarudzbu'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'korisnikId': korisnikId,
        'ukupnaCijena': ukupnaCijena,
        'stavke': stavke,
        'nacinPlacanja': nacinPlacanja,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as int;
    }
    return null;
  }

  // Live praćenje: status + lokacija dostavljača
  static Future<Map<String, dynamic>?> getNarudzbaPracenje(
      int narudzbaId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/Narudzbe/GetNarudzbaPracenje/$narudzbaId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  // Admin: sve narudžbe
  static Future<List<dynamic>> getAllNarudzbe() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/Narudzbe/GetAll'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (_) {}
    return [];
  }

  // Admin: promijeni status narudžbe
  static Future<bool> azurirajStatusNarudzbe(
      int id, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/Narudzbe/AzurirajStatus/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    return response.statusCode == 200;
  }

  // Admin: postavi GPS lokaciju dostavljača
  static Future<bool> azurirajLokacijuDostavljaca(
      int id, double lat, double lng) async {
    final response = await http.put(
      Uri.parse(
          '$baseUrl/api/Narudzbe/AzurirajLokacijuDostavljaca/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'latitude': lat, 'longitude': lng}),
    );
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getNarudzbe(int korisnikId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/api/Narudzbe/GetByKorisnik/$korisnikId'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<bool> obrisiNarudzbu(int id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/api/Narudzbe/ObrisiNarudzbu/$id'));
    return response.statusCode == 200;
  }

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
    if (response.statusCode == 200) return jsonDecode(response.body);
    return null;
  }
}

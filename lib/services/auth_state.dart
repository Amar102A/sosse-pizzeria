class AuthState {
  static Map<String, dynamic>? _korisnik;

  static void setKorisnik(Map<String, dynamic> korisnik) {
    _korisnik = korisnik;
  }

  static void logout() {
    _korisnik = null;
  }

  static Map<String, dynamic>? get korisnik => _korisnik;
  static bool get isPrijavljen => _korisnik != null;
}
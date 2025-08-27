import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/country.dart';

class StorageService {
  static const String _keyCountries = "countries";

  Future<void> saveCountries(List<Country> countries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(countries.map((c) => c.toJson()).toList());
    await prefs.setString(_keyCountries, jsonString);
  }

  Future<List<Country>> loadCountries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyCountries);
    if (jsonString == null) return [];
    final List<dynamic> data = jsonDecode(jsonString);
    return data.map((e) => Country.fromJson(e)).toList();
  }
}

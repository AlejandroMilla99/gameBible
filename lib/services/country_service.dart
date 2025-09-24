import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../models/country.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

class CountryService {
  static const String _keyCountries = "countries";
  static const String _assetsPath = 'assets/data/countries.json';

  /// Load countries from local assets JSON
  static Future<List<Country>> loadCountriesFromAssets() async {
    final String response = await rootBundle.loadString(_assetsPath);
    final List<dynamic> data = json.decode(response);
    print("✅ Countries loaded from Local");
    return data.map((json) => Country.fromJson(json)).toList();
  }

  /// Main loader: tries Remote → Storage → Assets (in that order).
  static Future<List<Country>> loadCountries() async {
    List<Country> finalCountriesList = [];

    finalCountriesList = await loadCountriesFromRemote();
    if (finalCountriesList.isNotEmpty) {
      await saveCountries(finalCountriesList); // Cache
      await overwriteLocalJson(finalCountriesList); // Update local assets copy
      print("✅ Countries loaded from Remote");
      return finalCountriesList;
    }

    print("💥 Countries could not be loaded from Remote");
    finalCountriesList = await loadCountriesFromStorage();
    if (finalCountriesList.isNotEmpty){
      print("✅ Countries loaded from Storage Cache");
      return finalCountriesList;
    }

    print("💥 Countries could not be loaded from Storage");
    return await loadCountriesFromAssets();
  }

  /// Save countries to cache (SharedPreferences)
  static Future<void> saveCountries(List<Country> countries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(countries.map((c) => c.toJson()).toList());
    await prefs.setString(_keyCountries, jsonString);
  }

  /// Load countries from cache
  static Future<List<Country>> loadCountriesFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyCountries);
    if (jsonString == null) return [];
    final List<dynamic> data = jsonDecode(jsonString);
    return data.map((e) => Country.fromJson(e)).toList();
  }

  /// Fetch countries from REST Countries + World Bank API
  static Future<List<Country>> loadCountriesFromRemote() async {
    final List<Country> countries = [];

    try {
      // REST Countries API
      final restCountriesRes =
          await get(Uri.parse("https://restcountries.com/v3.1/all"));

      if (restCountriesRes.statusCode == 200) {
        final List<dynamic> data = jsonDecode(restCountriesRes.body);

        for (var country in data) {
          final name = country["name"]?["common"] ?? "Unknown";
          final es_name = country["es_name"]?["common"] ?? "Unknown";
          final capital = country["capital"]?["common"] ?? "Unknown";
          final capital_es = country["capital_es"]?["common"] ?? "Unknown";
          final flag = country["flag"] ?? "🏳️";
          final iso3 = country["cca3"]; // For World Bank queries
          final population = (country["population"] ?? 0);

          // World Bank GDP Example
          int gdpRank = 0;
          if (iso3 != null) {
            try {
              final wbRes = await get(Uri.parse(
                  "https://api.worldbank.org/v2/country/$iso3/indicator/NY.GDP.MKTP.CD?format=json"));
              if (wbRes.statusCode == 200) {
                final wbData = jsonDecode(wbRes.body);
                if (wbData is List && wbData.length > 1) {
                  final List<dynamic> values = wbData[1];
                  final latest = values.firstWhere(
                      (e) => e["value"] != null,
                      orElse: () => null);
                  if (latest != null) {
                    // Convert GDP into ranking-ish (mock transform)
                    gdpRank = ((latest["value"] ?? 0) ~/ 1000000000000) % 50;
                  }
                }
              }
            } catch (_) {
              // Ignore World Bank errors, fallback to 0
            }
          }

          countries.add(
            Country(
              name: name,
              flag: flag,
              es_name: es_name,
              capital: capital,
              capital_es: capital_es,
              rankings: {
                "GDP": gdpRank,
                "Population": population % 50,
                "Safety": 25, // TODO: integrate real source
                "Football": 10, // TODO: integrate FIFA rankings
                "Happiness": 20, // TODO: integrate UN Happiness Index
                "Tourism": 15, // TODO: integrate UNWTO
                "Education": 18, // TODO: integrate UNESCO
                "Technology": 12, // TODO: integrate ITU stats
              },
            ),
          );
        }
      }
    } catch (e) {
      print("❌ Error loading remote countries: $e");
    }

    return countries;
  }

  /// Overwrite local assets json (if writable, e.g. dev environment)
  static Future<void> overwriteLocalJson(List<Country> countries) async {
    try {
      final file = File(_assetsPath);
      if (await file.exists()) {
        final jsonString =
            jsonEncode(countries.map((c) => c.toJson()).toList());
        await file.writeAsString(jsonString);
        print("✅ Local JSON updated with remote data");
      }
    } catch (e) {
      print("⚠️ Could not overwrite local JSON: $e");
    }
  }
}

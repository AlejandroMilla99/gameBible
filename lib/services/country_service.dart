import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/country.dart';

class CountryService {
  Future<List<Country>> loadCountriesFromAssets() async {
    final String jsonString =
        await rootBundle.loadString('../assets/data/countries.json');
    final List<dynamic> data = jsonDecode(jsonString);
    return data.map((e) => Country.fromJson(e)).toList();
  }
}

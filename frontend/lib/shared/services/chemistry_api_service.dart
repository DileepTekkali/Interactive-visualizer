import 'dart:convert';
import 'package:http/http.dart' as http;

class ChemistryApiService {
  static Future<Map<String, dynamic>> getAtomData(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('\${AppConstants.apiBase}/chemistry/atom/$symbol'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {"success": false, "error": "Failed to fetch atom data"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> separationProcess(String method) async {
    try {
      final response = await http.get(Uri.parse(
          '\${AppConstants.apiBase}/chemistry/separation?method=$method'));
      if (response.statusCode == 200) return json.decode(response.body);
      return {"success": false, "error": "Failed to fetch separation data"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> atomBuilder(int p, int n, int e) async {
    try {
      final response = await http.get(Uri.parse(
          '\${AppConstants.apiBase}/chemistry/atom_builder?p=$p&n=$n&e=$e'));
      if (response.statusCode == 200) return json.decode(response.body);
      return {"success": false, "error": "Failed to fetch atom data"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> chemicalBonding(
      String el1, String el2) async {
    try {
      final response = await http.get(Uri.parse(
          '\${AppConstants.apiBase}/chemistry/bond?el1=$el1&el2=$el2'));
      if (response.statusCode == 200) return json.decode(response.body);
      return {"success": false, "error": "Failed to fetch bonding data"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> moleCalculator(
      double value, String mode, double molarMass) async {
    try {
      final response = await http.post(
        Uri.parse('\${AppConstants.apiBase}/chemistry/mole_calculator'),
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode({"value": value, "mode": mode, "molar_mass": molarMass}),
      );
      if (response.statusCode == 200) return json.decode(response.body);
      return {"success": false, "error": "Failed to calculate moles"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> changeDetector(String scenario) async {
    try {
      final response = await http.get(Uri.parse(
          '\${AppConstants.apiBase}/chemistry/change_detector?scenario=$scenario'));
      if (response.statusCode == 200) return json.decode(response.body);
      return {
        "success": false,
        "error": "Failed to fetch change detector data"
      };
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> kineticsGraph(
      double concentration, double k, int order) async {
    try {
      final response = await http.get(Uri.parse(
          '\${AppConstants.apiBase}/chemistry/kinetics?concentration=$concentration&k=$k&order=$order'));
      if (response.statusCode == 200) return json.decode(response.body);
      return {"success": false, "error": "Failed to fetch kinetics data"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> equilibriumSimulator(
      double tempChange) async {
    try {
      final response = await http.get(Uri.parse(
          '\${AppConstants.apiBase}/chemistry/equilibrium?temp_change=$tempChange'));
      if (response.statusCode == 200) return json.decode(response.body);
      return {"success": false, "error": "Failed to fetch equilibrium data"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> thermodynamicsViz(String rxnType) async {
    try {
      final response = await http.get(Uri.parse(
          '\${AppConstants.apiBase}/chemistry/thermodynamics?rxn_type=$rxnType'));
      if (response.statusCode == 200) return json.decode(response.body);
      return {"success": false, "error": "Failed to fetch thermodynamics data"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}

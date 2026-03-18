import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';


class PhysicsApiService {
  static Future<Map<String, dynamic>> getFrictionData(double mass, double mu, double angle) async {
    try {
      final response = await http.get(
        Uri.parse('\${AppConstants.apiBase}/physics/friction?mass=$mass&mu=$mu&angle=$angle'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {"success": false, "error": "Failed to fetch friction data"};
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> heatTransfer(String mode, double deltaT) async {
    try {
      final response = await http.get(Uri.parse('\${AppConstants.apiBase}/physics/heat_transfer?mode=$mode&delta_t=$deltaT'));
      if (response.statusCode == 200) return json.decode(response.body);
      return {"success": false, "error": "Failed to fetch heat transfer data"};
    } catch (e) { return {"success": false, "error": e.toString()}; }
  }

  static Future<Map<String, dynamic>> leverMachine(double effortArm, double loadArm, double loadMass) async {
    try {
      final response = await http.get(Uri.parse('\${AppConstants.apiBase}/physics/lever?effort_arm=$effortArm&load_arm=$loadArm&load_mass=$loadMass'));
      if (response.statusCode == 200) return json.decode(response.body);
      return {"success": false, "error": "Failed to fetch lever data"};
    } catch (e) { return {"success": false, "error": e.toString()}; }
  }

  static Future<Map<String, dynamic>> motionGraph(double accel, double initialV, double time) async {
    try {
      final response = await http.get(Uri.parse('\${AppConstants.apiBase}/physics/motion?accel=$accel&initial_v=$initialV&time=$time'));
      if (response.statusCode == 200) return json.decode(response.body);
      return {"success": false, "error": "Failed to fetch motion data"};
    } catch (e) { return {"success": false, "error": e.toString()}; }
  }

  static Future<Map<String, dynamic>> newtonsLaws(double force, double mass) async {
    try {
      final response = await http.get(Uri.parse('\${AppConstants.apiBase}/physics/newtons_laws?force=$force&mass=$mass'));
      if (response.statusCode == 200) return json.decode(response.body);
      return {"success": false, "error": "Failed to fetch Newton's laws data"};
    } catch (e) { return {"success": false, "error": e.toString()}; }
  }

  static Future<Map<String, dynamic>> energySimulator(double mass, double height, double velocity) async {
    try {
      final response = await http.get(Uri.parse('\${AppConstants.apiBase}/physics/energy?mass=$mass&height=$height&velocity=$velocity'));
      if (response.statusCode == 200) return json.decode(response.body);
      return {"success": false, "error": "Failed to fetch energy data"};
    } catch (e) { return {"success": false, "error": e.toString()}; }
  }

  static Future<Map<String, dynamic>> lightRaySimulator(double angle, double n1, double n2) async {
    try {
      final response = await http.get(Uri.parse('\${AppConstants.apiBase}/physics/optics?angle=$angle&n1=$n1&n2=$n2'));
      if (response.statusCode == 200) return json.decode(response.body);
      return {"success": false, "error": "Failed to fetch optics data"};
    } catch (e) { return {"success": false, "error": e.toString()}; }
  }

  static Future<Map<String, dynamic>> circuitSimulator(List<double> resistors, double voltage, bool isSeries) async {
    try {
      final response = await http.post(
        Uri.parse('\${AppConstants.apiBase}/physics/circuit'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"resistors": resistors, "voltage": voltage, "is_series": isSeries}),
      );
      if (response.statusCode == 200) return json.decode(response.body);
      return {"success": false, "error": "Failed to fetch circuit data"};
    } catch (e) { return {"success": false, "error": e.toString()}; }
  }

  static Future<Map<String, dynamic>> magneticField(double magnetStrength) async {
    try {
      final response = await http.get(Uri.parse('\${AppConstants.apiBase}/physics/magnetic_field?magnet_strength=$magnetStrength'));
      if (response.statusCode == 200) return json.decode(response.body);
      return {"success": false, "error": "Failed to fetch magnetic field data"};
    } catch (e) { return {"success": false, "error": e.toString()}; }
  }

  static Future<Map<String, dynamic>> waveSimulator(double amplitude, double frequency, double phase) async {
    try {
      final response = await http.get(Uri.parse('\${AppConstants.apiBase}/physics/wave?amplitude=$amplitude&frequency=$frequency&phase=$phase'));
      if (response.statusCode == 200) return json.decode(response.body);
      return {"success": false, "error": "Failed to fetch wave data"};
    } catch (e) { return {"success": false, "error": e.toString()}; }
  }
}

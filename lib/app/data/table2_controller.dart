import 'package:get/get.dart';

class Table2Controller extends GetxController {
  final Map<String, Map<String, dynamic>> layingConditions = {
    "Type 1": {"E'": 150, "Bedding angle deg": 30, "kb": 0.235, "kx": 0.108},
    "Type 2": {"E'": 300, "Bedding angle deg": 45, "kb": 0.21, "kx": 0.105},
    "Type 3": {"E'": 400, "Bedding angle deg": 60, "kb": 0.189, "kx": 0.103},
    "Type 4": {"E'": 500, "Bedding angle deg": 90, "kb": 0.157, "kx": 0.096},
    "Type 5": {"E'": 700, "Bedding angle deg": 150, "kb": 0.128, "kx": 0.085},
  };

  // Method to get E' and kx values for a specific type
  Map<String, dynamic>? getEAndKxValues(String type) {
    // Check if the type exists in the layingConditions
    if (layingConditions.containsKey(type)) {
      // Return the E' and kx values for the given type
      var condition = layingConditions[type];
      return {
        "E'": condition?["E'"],
        "kx": condition?["kx"],
        "kb": condition?["kb"],
      };
    } else {
      // Return null if the type is not found
      return null;
    }
  }
}

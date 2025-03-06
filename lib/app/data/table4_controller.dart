import 'package:get/get.dart';

class Table4Controller extends GetxController {
  // Map to store the R-values from Table 4.csv
  final Map<int, Map<String, double>> rValues = {
    3: {"<4": 1, "4 to 7": 1, "7 to 10": 1, ">10": 1},
    4: {"<4": 1, "4 to 7": 1, "7 to 10": 1, ">10": 1},
    6: {"<4": 1, "4 to 7": 1, "7 to 10": 1, ">10": 1},
    8: {"<4": 1, "4 to 7": 1, "7 to 10": 1, ">10": 1},
    10: {"<4": 1, "4 to 7": 1, "7 to 10": 1, ">10": 1},
    12: {"<4": 1, "4 to 7": 1, "7 to 10": 1, ">10": 1},
    14: {"<4": 0.92, "4 to 7": 1, "7 to 10": 1, ">10": 1},
    16: {"<4": 0.88, "4 to 7": 0.95, "7 to 10": 1, ">10": 1},
    18: {"<4": 0.85, "4 to 7": 0.9, "7 to 10": 1, ">10": 1},
    20: {"<4": 0.83, "4 to 7": 0.9, "7 to 10": 0.95, ">10": 1},
    24: {"<4": 0.81, "4 to 7": 0.85, "7 to 10": 0.95, ">10": 1},
    30: {"<4": 0.81, "4 to 7": 0.85, "7 to 10": 0.95, ">10": 1},
    36: {"<4": 0.8, "4 to 7": 0.85, "7 to 10": 0.9, ">10": 1},
    42: {"<4": 0.8, "4 to 7": 0.85, "7 to 10": 0.9, ">10": 1},
    48: {"<4": 0.8, "4 to 7": 0.85, "7 to 10": 0.9, ">10": 1},
    54: {"<4": 0.8, "4 to 7": 0.85, "7 to 10": 0.9, ">10": 1},
    60: {"<4": 0.8, "4 to 7": 0.85, "7 to 10": 0.9, ">10": 1},
    64: {"<4": 0.8, "4 to 7": 0.85, "7 to 10": 0.9, ">10": 1},
  };

  // Method to get the R-value
  double? getRValue(int pipeSize, double depthOfCover) {
    String depthKey;
    if (depthOfCover < 4) {
      depthKey = "<4";
    } else if (depthOfCover >= 4 && depthOfCover <= 7) {
      depthKey = "4 to 7";
    } else if (depthOfCover > 7 && depthOfCover <= 10) {
      depthKey = "7 to 10";
    } else {
      depthKey = ">10";
    }

    return rValues[pipeSize]?[depthKey];
  }
}

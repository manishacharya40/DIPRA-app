import 'package:get/get.dart';

class Table5Controller extends GetxController {
  final Map<int, Map<String, dynamic>> table5Data = {
    3: {
      "Outside dia": 3.96,
      "150": null,
      "200": null,
      "250": null,
      "300": null,
      "350": 0.25,
    },
    4: {
      "Outside dia": 4.8,
      "150": null,
      "200": null,
      "250": null,
      "300": null,
      "350": 0.25,
    },
    6: {
      "Outside dia": 6.9,
      "150": null,
      "200": null,
      "250": null,
      "300": null,
      "350": 0.25,
    },
    8: {
      "Outside dia": 9.05,
      "150": null,
      "200": null,
      "250": null,
      "300": null,
      "350": 0.25,
    },
    10: {
      "Outside dia": 11.1,
      "150": null,
      "200": null,
      "250": null,
      "300": null,
      "350": 0.26,
    },
    12: {
      "Outside dia": 13.2,
      "150": null,
      "200": null,
      "250": null,
      "300": null,
      "350": 0.28,
    },
    14: {
      "Outside dia": 15.3,
      "150": null,
      "200": null,
      "250": 0.28,
      "300": 0.3,
      "350": 0.31,
    },
    16: {
      "Outside dia": 17.4,
      "150": null,
      "200": null,
      "250": 0.3,
      "300": 0.32,
      "350": 0.34,
    },
    18: {
      "Outside dia": 19.5,
      "150": null,
      "200": null,
      "250": 0.31,
      "300": 0.34,
      "350": 0.36,
    },
    20: {
      "Outside dia": 21.6,
      "150": null,
      "200": null,
      "250": 0.33,
      "300": 0.36,
      "350": 0.38,
    },
    24: {
      "Outside dia": 25.8,
      "150": null,
      "200": 0.33,
      "250": 0.37,
      "300": 0.4,
      "350": 0.43,
    },
    30: {
      "Outside dia": 32,
      "150": 0.34,
      "200": 0.38,
      "250": 0.42,
      "300": 0.45,
      "350": 0.49,
    },
    36: {
      "Outside dia": 38.3,
      "150": 0.38,
      "200": 0.42,
      "250": 0.47,
      "300": 0.51,
      "350": 0.56,
    },
    42: {
      "Outside dia": 44.5,
      "150": 0.41,
      "200": 0.47,
      "250": 0.52,
      "300": 0.57,
      "350": 0.63,
    },
    48: {
      "Outside dia": 50.8,
      "150": 0.46,
      "200": 0.52,
      "250": 0.58,
      "300": 0.64,
      "350": 0.7,
    },
    54: {
      "Outside dia": 57.56,
      "150": 0.51,
      "200": 0.58,
      "250": 0.65,
      "300": 0.72,
      "350": 0.79,
    },
    60: {
      "Outside dia": 61.61,
      "150": 0.54,
      "200": 0.61,
      "250": 0.68,
      "300": 0.76,
      "350": 0.83,
    },
    64: {
      "Outside dia": 65.67,
      "150": 0.56,
      "200": 0.64,
      "250": 0.72,
      "300": 0.8,
      "350": 0.87,
    },
  };

  // Method to get the value (including Outside dia)
  double? getOutsideDia(int pipeSize) {
    // Check if the pipe size exists in the data
    if (table5Data.containsKey(pipeSize)) {
      // Return the "Outside dia" value for the given pipe size
      return table5Data[pipeSize]?["Outside dia"];
    } else {
      // Return null if the pipe size does not exist
      return null;
    }
  }

  // Method to get pressure and thickness
  Map<String, dynamic>? getPressureAndThickness(
    int pipeSize,
    double thickness,
  ) {
    // Check if the pipe size exists in the data
    if (table5Data.containsKey(pipeSize)) {
      var pressureClasses = ["150", "200", "250", "300", "350"];
      for (String pressure in pressureClasses) {
        var pressureValue = table5Data[pipeSize]?[pressure];

        // Skip null values
        if (pressureValue == null) {
          continue;
        }

        // If pressure value is greater than or equal to the provided thickness, return the result
        if (pressureValue >= thickness) {
          return {
            "pipeSize": pipeSize,
            "pressureClass": pressure,
            "thickness": pressureValue,
          };
        }
      }

      // If no suitable pressure class was found for the current pipe size, check the next pipe size
      List<int> sortedPipeSizes = table5Data.keys.toList()..sort();
      int nextPipeSize = sortedPipeSizes.firstWhere(
        (size) => size > pipeSize,
        orElse: () => pipeSize,
      );

      // Recursively call the function with the next pipe size if needed
      return getPressureAndThickness(nextPipeSize, thickness);
    }

    // Return null if pipe size not found
    return null;
  }
}

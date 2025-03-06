import 'package:get/get.dart';

class Table3Controller extends GetxController {
  final Map<int, double> castingAllowances = {
    3: 0.05,
    4: 0.05,
    6: 0.05,
    8: 0.05,
    10: 0.06,
    12: 0.06,
    14: 0.07,
    16: 0.07,
    18: 0.07,
    20: 0.07,
    24: 0.07,
    30: 0.07,
    36: 0.07,
    42: 0.07,
    48: 0.08,
    54: 0.09,
    60: 0.09,
    64: 0.09,
  };

  // Method to get casting allowance
  double? getCastingAllowance(int pipeSize) {
    return castingAllowances[pipeSize];
  }
}

import 'package:csv/csv.dart';
import 'package:dipra_app/app/data/table10_controller.dart';
import 'package:dipra_app/app/data/table11_controller.dart';
import 'package:dipra_app/app/data/table2_controller.dart';
import 'package:dipra_app/app/data/table3_controller.dart';
import 'package:dipra_app/app/data/table4_controller.dart';
import 'package:dipra_app/app/data/table5_controller.dart';
import 'package:dipra_app/app/data/table7_controller.dart';

import 'package:dipra_app/app/data/table8_controller.dart';
import 'package:dipra_app/app/data/table9_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:math';

class DipraController extends GetxController {
  //Reactive variables
  final RxInt pipeSize = 3.obs;
  final RxString trenchType = 'Type 1'.obs;
  RxBool isDropdownOpen = false.obs;

  //Instantiate Table4Controller
  final table2Conroller = Get.put(Table2Controller());
  final table3Controller = Get.put(Table3Controller());
  final table4Controller = Get.put(Table4Controller());
  final table5Controller = Get.put(Table5Controller());
  final table7Controller = Get.put(Table7Controller());
  final table8Controller = Get.put(Table8Controller());
  final table9Controller = Get.put(Table9Controller());
  final table10Controller = Get.put(Table10Controller());
  final table11Controller = Get.put(Table11Controller());

  //Text Editing Controllers
  final workingpressureController = TextEditingController();
  final densityController = TextEditingController(text: 120.0.toString());

  final surgeallowanceController = TextEditingController();
  final depthofcoverController = TextEditingController();
  final impactfactorController = TextEditingController(text: 1.5.toString());
  final bvalueController = TextEditingController(text: 1.5.toString());
  final wheelloadController = TextEditingController(text: 16000.0.toString());
  final pipelengthController = TextEditingController(text: 36.0.toString());
  final yieldstrengthController = TextEditingController(
    text: 42000.0.toString(),
  );
  final modulusController = TextEditingController(text: 24000000.toString());

  //Reactive variables for thickness
  var thickness = 0.0.obs;
  var earthLoad = 0.0.obs;

  // Method to calculate thickness
  void calculateThickness(
    int pipeSize,
    double workingPressure,
    double surgeAllowance,
    double depthOfCover,
    double density,
    String trenchType,
    double impactFactor,
    double bValue,
    double wheelLoad,
    double pipeLength,
    double yieldStrength,
    double modulus,
  ) async {
    //get outside diameter of pipe
    double? outside_dia = table5Controller.getOutsideDia(pipeSize);

    //Calculation of earth load
    earthLoad.value = (depthOfCover * density / 144);

    //Calculation of reduction factor from table 4
    double? getRValue = table4Controller.getRValue(pipeSize, depthOfCover);
    if (getRValue == null) {
      // Handle the error: R-value not found
      print(
        "Error: R-value not found for pipeSize: $pipeSize and depthOfCover: $depthOfCover",
      );

      thickness.value = 0.0; // Or some default value
      return; // Stop further calculation
    }

    //get Outside radius of pipe in ft
    double outsideRadius = outside_dia! / 24;

    //get surface load factor as per Equation 6 of AWWA C150
    double surfaceLoadFactor = calculateC(outsideRadius, bValue, depthOfCover);

    //get truck load
    /////
    print('.................');
    print(
      "R value is $getRValue. Impact factor is $impactFactor. Surface load factor is $surfaceLoadFactor. Wheel load is $wheelLoad. Pipe Length is $pipeLength. Outside dia $outside_dia",
    );

    double truckloadPt =
        getRValue *
        impactFactor *
        surfaceLoadFactor *
        wheelLoad /
        (pipeLength * outside_dia);
    print('Truck load is $truckloadPt');
    //get trench load
    double trenchloadPv = earthLoad.value + truckloadPt;
    print('Trench load is $trenchloadPv');
    //calculate Dt ratio based on bending stress
    double? Dt_bending = calculateDtratio(
      trenchType,
      "bending stress",
      trenchloadPv,
    );
    print('Dt ratio with bending stress method is $Dt_bending');

    //Net thickness from bending stress is
    double t_bending = outside_dia / Dt_bending!;

    //calculate Dt ratio based on deflection
    double? Dt_deflection = calculateDtratio(
      trenchType,
      "deflection",
      trenchloadPv,
    );
    print('Dt ratio with bending stress method is $Dt_deflection');

    //Net thickness from deflection is
    double t_deflection = outside_dia / Dt_bending;

    //net thickness is maximum of t_bending and t_deflection
    double t_bending_deflection = max(t_bending, t_deflection);
    print('Net thickness is $t_bending_deflection');

    //Step 2: Design for internal pressure
    double internal_pressure = 2 * (workingPressure + surgeAllowance);
    double thickness_internalpressure =
        internal_pressure * outside_dia / (2 * yieldStrength);

    //Step 3: Selection of net thickness and addition of allowance(0.08 inch is service allowance for all sizes of ductile-iron pipe)
    double? casting_allowance_Value = table3Controller.getCastingAllowance(
      pipeSize,
    );
    double service_allowance_Value = 0.08;
    double net_thickness =
        max(thickness_internalpressure, t_bending_deflection) +
        service_allowance_Value +
        casting_allowance_Value!;
    print('Net thickness is $net_thickness');

    //For pressure class, look at Table 5 and see pressure class with corresponding size and thickness
    var result = table5Controller.getPressureAndThickness(
      pipeSize,
      net_thickness,
    );
    if (result != null) {
      print("Pipe Size: ${result['pipeSize']}");
      print("Pressure Class: ${result['pressureClass']}");
      print("Thickness: ${result['thickness']}");
    } else {
      print("No suitable pressure class found.");
    }

    //Step 4:Check for deflection
    var pressureandthickness = table2Conroller.getEAndKxValues(trenchType);
    double kxvalue = pressureandthickness?['kx'];
    double Eprimevalue = pressureandthickness?["E'"];
    double Pv_basedondeflection = calculatePv_deflectioncheck(
      outside_dia,
      kxvalue,
      modulus,
      net_thickness,
      Eprimevalue,
    );
    if (Pv_basedondeflection < trenchloadPv) {
      print('Deflection is ok');
    } else {
      print('Deflection is not ok');
    }
  }

  //Method to calculate surface load factor as per Equation 6 of AWWA C150
  double calculateC(double A, double B, double H) {
    // Calculate the term inside the asin function
    double asinTerm =
        H *
        sqrt(
          (pow(A, 2) + pow(B, 2) + pow(H, 2)) /
              ((pow(A, 2) + pow(H, 2)) * (pow(B, 2) + pow(H, 2))),
        );

    // Calculate the second term (arcsin term)
    double secondTerm = (2 / pi) * asin(asinTerm);

    // Calculate the first fraction in the third term
    double fraction1 = (A * H * B) / sqrt(pow(A, 2) + pow(B, 2) + pow(H, 2));

    // Calculate the second set of fractions in the third term
    double fraction2 =
        (1 / (pow(A, 2) + pow(H, 2))) + (1 / (pow(B, 2) + pow(H, 2)));

    // Calculate the third term
    double thirdTerm = (2 / pi) * fraction1 * fraction2;

    // Calculate C
    double C = 1 - secondTerm + thirdTerm;

    return C;
  }

  //Method to calculate Dt ratio from table 7 to table 11
  double? calculateDtratio(
    String trenchType,
    String keytype,
    double trenchloadPv,
  ) {
    double? DtRatio = 0.0;
    switch (trenchType) {
      case 'Type 1':
        DtRatio = table7Controller.getDt(keytype, trenchloadPv);
        break;
      case 'Type 2':
        DtRatio = table8Controller.getDt(keytype, trenchloadPv);
        break;
      case 'Type 3':
        DtRatio = table9Controller.getDt(keytype, trenchloadPv);
        break;
      case 'Type 4':
        DtRatio = table10Controller.getDt(keytype, trenchloadPv);
        break;
      case 'Type 5':
        DtRatio = table11Controller.getDt(keytype, trenchloadPv);
        break;
      default:
        DtRatio = 0.0;
    }
    return DtRatio;
  }

  //Nethod to calculate Pv based on deflection check
  double calculatePv_deflectioncheck(
    double D,
    double Kx,
    double E,
    double t1,
    double EPrime,
  ) {
    // Calculate the (D/t1 - 1)^3 term
    double DOverT1Minus1Cubed =
        pow((D / t1) - 1, 3).toDouble(); // Convert to double

    // Calculate the term inside the square brackets
    double bracketTerm = (8 * E / DOverT1Minus1Cubed) + (0.732 * EPrime);

    // Calculate the (deltaX / D) term. it is 0.03 for ductile iron pipe.
    double deltaXOverD = 0.03;

    // Calculate Pv
    double Pv_def = (deltaXOverD / (12 * Kx)) * bracketTerm;

    return Pv_def;
  }
}

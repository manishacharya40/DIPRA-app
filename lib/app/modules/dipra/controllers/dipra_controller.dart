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
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:math';

import 'package:printing/printing.dart';

class DipraController extends GetxController {
  //Reactive variables
  final RxInt pipeSize = 3.obs;
  final RxString trenchType = 'Type 1'.obs;
  RxBool isDropdownOpen = false.obs;
  final isLoading = false.obs;

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

  //rxdouble para

  //Reactive variables for thickness
  var thickness = 0.0.obs;
  var earthLoad = 0.0.obs;
  var pressureClass = ''.obs;
  var RxpipeSize = 0.obs;

  void clearUserInput() {
    pdfBytes.value = null;
    isLoading.value = false;
    workingpressureController.clear();
    surgeallowanceController.clear();
    depthofcoverController.clear();
    densityController.text = 120.0.toString();
    impactfactorController.text = 1.5.toString();
    bvalueController.text = 1.5.toString();
    wheelloadController.text = 16000.0.toString();
    pipelengthController.text = 36.0.toString();
    yieldstrengthController.text = 42000.0.toString();
    modulusController.text = 24000000.0.toString();
  }

  void saveUserInput() {
    // Save user input to local storage
    // You can use shared_preferences or any other storage method
  }

  // Method to calculate thickness
  Future<void> calculateThickness(
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
    isLoading.value = true;
    //get outside diameter of pipe
    double? outside_dia = table5Controller.getOutsideDia(pipeSize) ?? 0;

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        pressureClass.value = result['pressureClass'];
        thickness.value = result['thickness'];
        RxpipeSize.value = result['pipeSize'];
        update();
      });
    } else {
      print("No suitable pressure class found.");
    }

    //Step 4:Check for deflection
    var pressureandthickness = table2Conroller.getEAndKxValues(trenchType);
    double kxvalue = pressureandthickness?['kx'];
    double Eprimevalue = pressureandthickness?["E'"].toDouble();
    double Pv_basedondeflection = calculatePv_deflectioncheck(
      outside_dia,
      kxvalue,
      modulus,
      net_thickness,
      Eprimevalue,
    );
    if (Pv_basedondeflection > trenchloadPv) {
      print('Deflection check is ok');
    } else {
      print('Deflection is not ok');
    }

    //Step 5: Check for bending stress, where we take kb as 48000 psi
    double Pv_basedonbendingstress = allowablePv_bendingstress(
      f: 48000,
      d: outside_dia,
      t: net_thickness,
      kb: pressureandthickness?['kb'],
      kx: kxvalue,
      e: modulus,
      ePrime: Eprimevalue,
    );
    if (Pv_basedonbendingstress > trenchloadPv) {
      print('Bending stress check is ok');
    } else {
      print('Bending stress check is not ok');
    }

    await generatePDFBytes(
      pipeSize,
      depthOfCover,
      workingPressure,
      surgeAllowance,
      trenchType,
      yieldStrength,
      density,
      getRValue,
      impactFactor,
      outside_dia,
      surfaceLoadFactor,
      wheelLoad,
      pipeLength,
      truckloadPt,
      trenchloadPv,
      Dt_bending,
      t_bending,
      Dt_deflection,
      t_deflection,
      net_thickness,
      t_bending_deflection,
      internal_pressure,
      thickness_internalpressure,
      casting_allowance_Value,
      service_allowance_Value,
      kxvalue,
      Eprimevalue,
      Pv_basedondeflection,
      Pv_basedonbendingstress,
      bValue,
    );
    isLoading.value = false;
  }

  //Method to calculate surface load factor as per Equation 6 of AWWA C150
  double calculateC(double A, double B, double H) {
    double asinTerm =
        H *
        sqrt(
          (pow(A, 2) + pow(B, 2) + pow(H, 2)) /
              ((pow(A, 2) + pow(H, 2)) * (pow(B, 2) + pow(H, 2))),
        );
    double secondTerm = (2 / pi) * asin(asinTerm);
    double fraction1 = (A * H * B) / sqrt(pow(A, 2) + pow(B, 2) + pow(H, 2));
    double fraction2 =
        (1 / (pow(A, 2) + pow(H, 2))) + (1 / (pow(B, 2) + pow(H, 2)));
    double thirdTerm = (2 / pi) * fraction1 * fraction2;
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

  //Nethod to calculate Pv allowable based on deflection check
  double calculatePv_deflectioncheck(
    double D,
    double Kx,
    double E,
    double t1,
    double EPrime,
  ) {
    double DOverT1Minus1Cubed =
        pow((D / t1) - 1, 3).toDouble(); // Convert to double
    double bracketTerm = (8 * E / DOverT1Minus1Cubed) + (0.732 * EPrime);
    double deltaXOverD = 0.03;
    double Pv_def = (deltaXOverD / (12 * Kx)) * bracketTerm;

    return Pv_def;
  }

  //Method to check Pv based on bending stress
  double allowablePv_bendingstress({
    required double f,
    required double d,
    required double t,
    required double kb,
    required double kx,
    required double e,
    required double ePrime,
  }) {
    double dtRatio = d / t;
    double bracketTerm =
        kb - (kx / ((8 * e) / (ePrime * pow(dtRatio - 1, 3)) + 0.732));
    double denominator = 3 * dtRatio * (dtRatio - 1) * bracketTerm;
    double pv = f / denominator;
    return pv;
  }

  Rx<Uint8List?> pdfBytes = Rx<Uint8List?>(null);
  // Method to generate PDF bytes and store them in pdfBytes
  Future<Uint8List> generatePDFBytes(
    pipeSize,
    depthOfCover,
    workingPressure,
    surgeAllowance,
    trenchType,
    yieldStrength,
    density,
    getRValue,
    impactFactor,
    outside_dia,
    surfaceLoadFactor,
    wheelLoad,
    pipeLength,
    truckload,
    trenchloadPv,
    Dt_bending,
    t_bending,
    Dt_deflection,
    t_deflection,
    net_thickness,
    t_bending_deflection,
    internal_pressure,
    thickness_internalpressure,
    casting_allowance_Value,
    service_allowance_Value,
    kxvalue,
    Eprimevalue,
    Pv_basedondeflection,
    Pv_basedonbendingstress,
    bValue,
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.timmanaRegular();
    final eqn6 = await rootBundle.load('lib/app/data/images/equation6.png');
    final imageBytes = eqn6.buffer.asUint8List();
    pw.Image eqn6_1 = pw.Image(pw.MemoryImage(imageBytes));
    final pageFormat = PdfPageFormat.a4.copyWith(
      marginLeft: 20,
      marginRight: 20,
      marginTop: 20,
      marginBottom: 20,
    );

    List<pw.Widget> pageContent = [];

    pageContent.add(
      pw.Text(
        '''Objective: The purpose of this document is intended to determine the capacity of buried ductile-iron pipe. 
        
Notes: User input are highlighted style.
    ":=" Defines a variable
    "=" Recalls a variable
           
References: 1906 ANSI/AWWA C150/A21.50-96 - Thickness of Ductile-Iron Pipe
            2006 Design of Ductile-Iron Pipe (DIPRA 2006)''',
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
    );
    pageContent.add(pw.SizedBox(height: 10));
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(pw.Container(height: 2, color: PdfColors.black));
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Design Input:',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Description/Code Ref:',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('D = $pipeSize in'),
          pw.Text('Outside diameter of pipe (Table 5: AWWA C150)'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));

    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text('H = $depthOfCover ft'), pw.Text('Depth of cover')],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Pw = $workingPressure psi'),
          pw.Text('Working Pressure'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Ps = $surgeAllowance psi'),
          pw.Text('Surge Allowance'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Laying Condition = $trenchType'),
          pw.Text('Laying Condition Type (AWWA C150)'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('S = $yieldStrength psi'),
          pw.Text('Minimum yield strength in tension'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(pw.Container(height: 2, color: PdfColors.black));
    pageContent.add(pw.SizedBox(height: 10));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Calculation:',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Description/Code Refs:',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 10));
    pageContent.add(
      pw.Text(
        'Step 1:',
        style: pw.TextStyle(
          fontSize: 12, // Set appropriate font size
          fontWeight: pw.FontWeight.bold, // Make it bold
          // A professional dark shade
        ),
      ),
    );

    pageContent.add(pw.SizedBox(height: 5));

    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('w = $density pcf'),
          pw.Text('Soil Weight (Section 4.4: AWWA C150)'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Pe = w * H = ${earthLoad.toStringAsFixed(3)} psi'),
          pw.Text('Earth Load (Equation 4: AWWA C150)'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('R = ${getRValue}'),
          pw.Text('Reduction Factor (Table 4)'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('F = $impactFactor'),
          pw.Text('Impact Factor (Section 4.4)'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Dn = $outside_dia in'),
          pw.Text('Effective Pipe Diameter (Table 5)'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('A = Dn/2 = ${outside_dia / 2} in.'),
          pw.Text('Effective Pipe Radius'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text('B = $bValue ft'), pw.Text('B Value (Table 4.4)')],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Container(
            alignment: pw.Alignment.center,
            height: 70,
            child: eqn6_1,
          ),
        ],
      ),
    );

    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('C = ${surfaceLoadFactor.toStringAsFixed(3)}'),
          pw.Text('Surface load factor (Equation 6: AWWA C150)'),
        ],
      ),
    );

    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('P = $wheelLoad lbf'),
          pw.Text('Wheel Load (Section 4.4)'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('b = $pipeLength in.'),
          pw.Text('Effective Pipe Length (Section 4.4)'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Pt = (R * F * C * P) / (b * D) = ${truckload.toStringAsFixed(3)} psi',
          ),
          pw.Text('Truck Load'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Pv = Pe + Pt = ${trenchloadPv.toStringAsFixed(3)} psi'),
          pw.Text('Trench Load'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text('D/t1 = ${Dt_bending} ')],
      ),
    );
    pageContent.add(
      pw.Wrap(
        children: [
          pw.Text(
            'Calculation of depth-thickness ratio based on bending stress from Table 7 to 11 based on laying condition type',
          ),
        ],
      ),
    );

    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('t1 = Dn/(Dn/t1) = ${t_bending.toStringAsFixed(3)} in.'),
          pw.Text('Net thickness (t) for bending stress'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text('D/t2 = $Dt_deflection')],
      ),
    );
    pageContent.add(
      pw.Wrap(
        children: [
          pw.Text(
            'Calculation of depth-thickness ratio based on deflection from Table 7 to 11 based on laying condition type',
          ),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            't2 = (Dn/(Dn/t2)) -service allowance = ${t_deflection.toStringAsFixed(3)} in.',
          ),
          pw.Text('Net thickness (t) for deflection design'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            't = max (t1, t2) = ${t_bending_deflection.toStringAsFixed(3)} in.',
          ),
        ],
      ),
    );

    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Text(
        'Net thickness is the maximum of bending stress and deflection design',
      ),
    );
    pageContent.add(pw.SizedBox(height: 10));

    pageContent.add(pw.Container(height: 2, color: PdfColors.black));

    pageContent.add(pw.SizedBox(height: 10));

    pageContent.add(
      pw.Text(
        'Step 2:',
        style: pw.TextStyle(
          fontSize: 12, // Set appropriate font size
          fontWeight: pw.FontWeight.bold, // Make it bold
          // A professional dark shade
        ),
      ),
    );
    pageContent.add(pw.SizedBox(height: 10));
    pageContent.add(
      pw.Text(
        'Design for internal pressure : ',
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Pi = 2 * (Pw + Ps) = ${internal_pressure.toStringAsFixed(3)} psi',
          ),
          pw.Text('Internal Pressure'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            't_internal_pressure = (Pi * D) / (2 * S) = ${thickness_internalpressure.toStringAsFixed(3)} in.',
          ),
          pw.Text('Net thickness for internal pressure'),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));

    pageContent.add(pw.Container(height: 2, color: PdfColors.black));

    pageContent.add(pw.SizedBox(height: 10));
    pageContent.add(
      pw.Text(
        'Step 3:',
        style: pw.TextStyle(
          fontSize: 12, // Set appropriate font size
          fontWeight: pw.FontWeight.bold, // Make it bold
          // A professional dark shade
        ),
      ),
    );
    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Text(
        'Provided thickness is the maximum of (bending stress thickness, internal pressure, deflection design) with addition of allowances:',
        style: pw.TextStyle(
          fontSize: 12, // Set appropriate font size
          fontWeight: pw.FontWeight.bold, // Make it bold
          // A professional dark shade
        ),
      ),
    );

    pageContent.add(pw.SizedBox(height: 5));
    pageContent.add(
      pw.Wrap(
        children: [
          pw.Text(
            'Provided thickness, t = ${net_thickness.toStringAsFixed(3)} in.',
          ),
          pw.Text(
            ' where, service allowance is $service_allowance_Value in. and casting allowance is $casting_allowance_Value in.',
          ),
        ],
      ),
    );
    pageContent.add(pw.SizedBox(height: 20));

    pageContent.add(
      pw.Container(
        padding: pw.EdgeInsets.all(5),
        width: 550,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(
            color: PdfColors.black,
            width: 2,
          ), // Black border
          borderRadius: pw.BorderRadius.circular(12.0), // Rounded corners
          boxShadow: [pw.BoxShadow(color: PdfColors.grey, blurRadius: 6)],
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,

          children: [
            pw.Text(
              'Conclusion',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue,
              ),
            ),

            pw.SizedBox(height: 2),
            pw.Divider(
              thickness: 1,
              color: PdfColors.black,
            ), // Black divider line
            pw.SizedBox(height: 2),
            pw.Text(
              'Provide ${RxpipeSize.value} inch pipe with ${thickness.value} inch thick pipe and pressure class = ${pressureClass.value} psi.',
              style: pw.TextStyle(
                fontSize: 12, // Set appropriate font size
                fontWeight: pw.FontWeight.bold, // Make it bold
                // A professional dark shade
              ),
            ),
          ],
        ),
      ),
    );
    //
    // final pageFormat = PdfPageFormat.a4.copyWith(

    //   marginLeft: 20,
    //   marginRight: 20,
    //   marginTop: 20,
    //   marginBottom: 20,
    //

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(30),
        pageFormat: PdfPageFormat.a4,

        build: (pw.Context context) {
          List<pw.Widget> widgets = [];
          widgets.addAll(pageContent);

          return widgets;
        },
      ),
    );
    // return pdf.save();
    pdfBytes.value = await pdf.save();

    return pdf.save();
  }
}

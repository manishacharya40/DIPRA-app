import 'dart:async';

import 'package:dipra_app/app/consts/constants.dart';
import 'package:dipra_app/app/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../controllers/dipra_controller.dart';

class DipraView extends GetView<DipraController> {
  DipraView({super.key});

  final loginFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thickness of Ductile-Iron Pipe (DIPRA)',
          style: TextStyle(
            fontSize: 24, // Larger font size
            fontWeight: FontWeight.bold, // Bold font
            color: Colors.white, // Text color
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700], // AppBar background color
        elevation: 4, // Slight shadow under the AppBar
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.white), // Hamburger icon
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open the drawer
              },
            );
          },
        ),
      ),
      drawerScrimColor: Colors.transparent,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[700]),
              child: Text(
                'DIPRA Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Navigate to home or another screen
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Navigate to settings or another screen
              },
            ),
            // Add more items to the drawer as needed
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                // width:
                //     MediaQuery.of(context).size.width /
                //     4, // Set container width to 1/3 of screen width
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue[50], // Light blue background color
                  borderRadius: BorderRadius.circular(12.0), // Rounded corners
                  border: Border.all(
                    color: Colors.black, // Border color
                    width: 2, // Border width
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.1,
                      ), // Light shadow color
                      blurRadius: 8, // Shadow blur radius
                      offset: Offset(
                        0,
                        4,
                      ), // Shadow offset, giving a slight elevation effect
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16.0),
                child: Container(
                  color: Colors.blue[50],
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: loginFormKey,
                        child: Column(
                          children: [
                            // Dropdown for Pipe Size
                            Obx(
                              () => Column(
                                children: [
                                  Text(
                                    'Input Values: ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width / 3,

                                      child: DropdownButtonFormField<int>(
                                        value: controller.pipeSize.value,
                                        items:
                                            pipeSize
                                                .map(
                                                  (e) => DropdownMenuItem(
                                                    value: e,
                                                    child: Text(e.toString()),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged:
                                            (value) =>
                                                controller.pipeSize.value =
                                                    value!,
                                        decoration: InputDecoration(
                                          labelText:
                                              'Select Pipe Size (inches):',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                          ),

                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 10,
                                          ),
                                        ),
                                        style: TextStyle(fontSize: 14),

                                        isExpanded:
                                            true, // Ensures proper dropdown width
                                        menuMaxHeight: 150,
                                        alignment: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),

                            _buildTextField(
                              context: context,
                              label: 'Working Pressure (psi):',
                              controller: controller.workingpressureController,
                              validator: Validators.workingpressureValidator,
                            ),
                            _buildTextField(
                              context: context,
                              label: 'Surge Allowance (psi):',
                              controller: controller.surgeallowanceController,
                              validator: Validators.surgeallowanceValidator,
                            ),
                            _buildTextField(
                              context: context,
                              label: 'Depth of Cover (ft):',
                              controller: controller.depthofcoverController,
                              validator: Validators.depthofcoverValidator,
                            ),

                            // Dropdown for Trench Type
                            Obx(
                              () => Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: DropdownButtonFormField<String>(
                                    value: controller.trenchType.value,
                                    items:
                                        trenchType
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e.toString()),
                                              ),
                                            )
                                            .toList(),
                                    onChanged:
                                        (value) =>
                                            controller.trenchType.value =
                                                value!,
                                    decoration: InputDecoration(
                                      labelText: 'Select Trench Type:',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 10,
                                      ),
                                    ),
                                    style: TextStyle(fontSize: 14),
                                    isExpanded: true,
                                    menuMaxHeight: 150,
                                    alignment: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: MediaQuery.of(context).size.width / 4,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      12.0,
                                    ), // Rounded corners
                                  ),
                                  elevation:
                                      4, // Slight shadow for a floating effect
                                  margin: EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ), // Spacing around the card
                                  color:
                                      Colors
                                          .blue[50], // Background color of the card
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      8.0,
                                    ), // Padding inside the card
                                    child: Text(
                                      'Default Values from Section 4.4 ANSI/AWWA :',
                                      style: TextStyle(
                                        fontSize: 16, // Larger font size
                                        fontWeight: FontWeight.bold,

                                        // Bold text
                                        color: Colors.red[700],
                                        // Text color to match theme
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildTextField(
                              context: context,
                              label: 'Density of soil (pcf):',
                              controller: controller.densityController,
                              validator: Validators.densityValidator,
                            ),

                            _buildTextField(
                              context: context,
                              label: 'Impact Factor:',
                              controller: controller.impactfactorController,
                              validator: Validators.impactfactorValidator,
                            ),
                            _buildTextField(
                              context: context,
                              label: 'constant B:',
                              controller: controller.bvalueController,
                              validator: Validators.bvalueValidator,
                            ),
                            _buildTextField(
                              context: context,
                              label: 'Wheel load (lbf):',
                              controller: controller.wheelloadController,
                              validator: Validators.wheelloadValidator,
                            ),
                            _buildTextField(
                              context: context,
                              label: 'Effective pipe length (in.):',
                              controller: controller.pipelengthController,
                              validator: Validators.pipelengthValidator,
                            ),
                            _buildTextField(
                              context: context,
                              label: 'Minimum Yield strength in tension (psi):',
                              controller: controller.yieldstrengthController,
                              validator: Validators.yieldstrengthValidator,
                            ),
                            _buildTextField(
                              context: context,
                              label:
                                  'Minimum Modulus of elasticity of pipe (psi):',
                              controller: controller.modulusController,
                              validator: Validators.modulusValidator,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // SizedBox(width: 10),

            // Calculate Button
            Container(
              // width: MediaQuery.of(context).size.width / 3.5,
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (loginFormKey.currentState!.validate()) {
                                controller.calculateThickness(
                                  controller.pipeSize.value,
                                  double.parse(
                                    controller.workingpressureController.text,
                                  ),
                                  double.parse(
                                    controller.surgeallowanceController.text,
                                  ),
                                  double.parse(
                                    controller.depthofcoverController.text,
                                  ),
                                  double.parse(
                                    controller.densityController.text,
                                  ),
                                  controller.trenchType.value,
                                  double.parse(
                                    controller.impactfactorController.text,
                                  ),
                                  double.parse(
                                    controller.bvalueController.text,
                                  ),
                                  double.parse(
                                    controller.wheelloadController.text,
                                  ),
                                  double.parse(
                                    controller.pipelengthController.text,
                                  ),
                                  double.parse(
                                    controller.yieldstrengthController.text,
                                  ),
                                  double.parse(
                                    controller.modulusController.text,
                                  ),
                                );
                                // await controller.generatePDFBytes();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blue[700], // Button background color
                              foregroundColor: Colors.white, // Text color
                              elevation: 8, // Shadow effect
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12.0,
                                ), // Rounded corners
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 32.0,
                                vertical: 16.0,
                              ), // Larger padding for a bigger button
                            ),
                            child: Text(
                              'Calculate',
                              style: TextStyle(
                                fontSize: 18, // Bigger text
                                fontWeight: FontWeight.bold, // Bold text
                                letterSpacing:
                                    1.2, // Slight spacing between letters for a more elegant look
                              ),
                            ),
                          ),

                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              controller.clearUserInput();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blue[700], // Button background color
                              foregroundColor: Colors.white, // Text color
                              elevation: 8, // Shadow effect
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12.0,
                                ), // Rounded corners
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 32.0,
                                vertical: 16.0,
                              ), // Larger padding for a bigger button
                            ),
                            child: Text(
                              'Clear',
                              style: TextStyle(
                                fontSize: 18, // Bigger text
                                fontWeight: FontWeight.bold, // Bold text
                                letterSpacing:
                                    1.2, // Slight spacing between letters for a more elegant look
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              controller.saveUserInput();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blue[700], // Button background color
                              foregroundColor: Colors.white, // Text color
                              elevation: 8, // Shadow effect
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12.0,
                                ), // Rounded corners
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 32.0,
                                vertical: 16.0,
                              ), // Larger padding for a bigger button
                            ),
                            child: Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 18, // Bigger text
                                fontWeight: FontWeight.bold, // Bold text
                                letterSpacing:
                                    1.2, // Slight spacing between letters for a more elegant look
                              ),
                            ),
                          ),
                          SizedBox(height: 60),
                        ],
                      ),

                      // Display results
                      // Display the calculated thickness
                      Obx(
                        () => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 20.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Container(
                            width: 450, // Increase width to full screen
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 20.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ), // Black border
                              borderRadius: BorderRadius.circular(
                                12.0,
                              ), // Rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    'Calculation Results',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Divider(
                                  thickness: 1,
                                  color: Colors.black,
                                ), // Black divider line
                                SizedBox(height: 16),

                                Text(
                                  'Pipe Size: ${controller.pipeSize.value} inches',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                                SizedBox(height: 8),

                                Text(
                                  'Thickness: ${controller.thickness.value} inches',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                                SizedBox(height: 8),

                                Text(
                                  'Pressure Class: ${controller.pressureClass.value}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueGrey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Image.asset(
                        'lib/app/data/images/types.png',
                        width: 500,
                        height: 270,
                      ),
                      SizedBox(height: 16),
                      Image.asset(
                        'lib/app/data/images/text_type.png',
                        width: 500,
                        height: 300,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            //display to the right side
            Container(
              width: MediaQuery.of(context).size.width / 2.3,
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Generating PDF...',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (controller.pdfBytes.value != null) {
                  return Expanded(
                    child: Container(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: PdfPreview(
                          build: (format) => controller.pdfBytes.value!,
                          allowPrinting: true,
                          allowSharing: true,

                          initialPageFormat: PdfPageFormat.a4,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf, size: 200),
                        Text(
                          'No PDF generated yet. Please calculate.',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for building text fields
  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: MediaQuery.of(context).size.width / 4, // Half the screen width
          child: TextFormField(
            decoration: InputDecoration(
              labelText: label,
              filled: true,
              fillColor: Colors.blue[50],
              prefixIcon: Icon(Icons.keyboard, color: Colors.blue),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.blue, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.blue[700]!, width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.blue[200]!, width: 1.5),
              ),
              labelStyle: TextStyle(color: Colors.blue[700]),
            ),
            validator: validator,
            controller: controller,
          ),
        ),
      ),
    );
  }

  // Calculate function
  void _calculate() {
    if (loginFormKey.currentState!.validate()) {
      double _working_pressure =
          double.tryParse(controller.workingpressureController.text) ?? 0.0;
      double _surge_allowance =
          double.tryParse(controller.surgeallowanceController.text) ?? 0.0;
      double _depth_of_cover =
          double.tryParse(controller.depthofcoverController.text) ?? 0.0;
      double _density_soil =
          double.tryParse(controller.densityController.text) ?? 0.0;
      double _impact_factor =
          double.tryParse(controller.impactfactorController.text) ?? 0.0;
      double _bvalue = double.tryParse(controller.bvalueController.text) ?? 0.0;
      double _wheel_load =
          double.tryParse(controller.wheelloadController.text) ?? 0.0;
      double _pipe_length =
          double.tryParse(controller.pipelengthController.text) ?? 0.0;
      double _yield_strength =
          double.tryParse(controller.yieldstrengthController.text) ?? 0.0;
      double _modulusofelasticity =
          double.tryParse(controller.modulusController.text) ?? 0.0;

      controller.calculateThickness(
        controller.pipeSize.value,
        _working_pressure,
        _surge_allowance,
        _depth_of_cover,
        _density_soil,
        controller.trenchType.value,
        _impact_factor,
        _bvalue,
        _wheel_load,
        _pipe_length,
        _yield_strength,
        _modulusofelasticity,
      );
    }
  }
}

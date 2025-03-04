import 'package:dipra_app/app/consts/constants.dart';
import 'package:dipra_app/app/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dipra_controller.dart';

class DipraView extends GetView<DipraController> {
  DipraView({super.key});

  final loginFormKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thickness of Ductile-Iron Pipe (DIPRA)'),
        centerTitle: true,
      ),
      body: Form(
        key: loginFormKey,
        child: Column(
          children: [
            //drop down menu with values from constants.dart
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Obx(
                    () => DropdownButtonFormField<int>(
                      value: controller.pipeSize.value,
                      isExpanded:
                          false, // To make the dropdown take the available width
                      menuMaxHeight: 200, // Adjust the factor as needed
                      items:
                          pipeSize
                              .map(
                                // Use pipeSize directly
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.toString()),
                                ),
                              )
                              .toList(),
                      focusNode: _focusNode,
                      onChanged: (value) {
                        controller.pipeSize.value = value!;
                        _focusNode.unfocus();
                        // Close the menu after selection
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Pipe Size (inches): ',
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Working Pressure (psi):',
                filled: true,
                fillColor: Colors.blue,
                prefixIcon: const Icon(Icons.keyboard),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),

              validator: Validators.workingpressureValidator,
              controller: Get.find<DipraController>().workingpressureController,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Surge Allowance (psi):',
                filled: true,
                fillColor: Colors.blue,
                prefixIcon: const Icon(Icons.keyboard),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),

              validator: Validators.surgeallowanceValidator,
              controller: Get.find<DipraController>().surgeallowanceController,
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Depth of cover (ft):',

                filled: true,
                fillColor: Colors.blue,
                prefixIcon: const Icon(Icons.keyboard),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator:
                  Validators
                      .depthofcoverValidator, // Moved outside the decoration
              controller:
                  Get.find<DipraController>()
                      .depthofcoverController, // Moved outside the decoration
            ),
            SizedBox(height: 16),
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Obx(
                    () => DropdownButtonFormField<String>(
                      value: controller.trenchType.value,
                      isExpanded:
                          false, // To make the dropdown take the available width
                      menuMaxHeight: 200, // Adjust the factor as needed
                      items:
                          trenchType
                              .map(
                                // Use pipeSize directly
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.toString()),
                                ),
                              )
                              .toList(),
                      focusNode: _focusNode,
                      onChanged: (value) {
                        controller.trenchType.value = value!;
                        _focusNode.unfocus();
                        // Close the menu after selection
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Pipe Size (inches): ',
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                if (loginFormKey.currentState!.validate()) {
                  // Handle form submission
                }
              },
              child: Text('Calculate'),
            ),
            SizedBox(height: 16),
            Text('''
References:

1. American National Standard for THICKNESS DESIGN OF DUCTILE-IRON PIPE
    ANSI/AWWA C150/A21.50-96'''),
          ],
        ),
      ),
    );
  }
}

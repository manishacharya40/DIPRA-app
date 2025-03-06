import 'package:get/get.dart';

class Validators {
  static String? workingpressureValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Working pressure is required';
    }
    if (double.tryParse(value) == null) {
      return 'Working pressure must be a number';
    }
    if (double.tryParse(value)! < 0) {
      return 'Working pressure must be a positive number';
    }
  }

  static String? surgeallowanceValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '!Surge Allowance is required';
    }
    if (double.tryParse(value) == null) {
      return 'Surge Allowance must be a number';
    }
    if (double.tryParse(value)! < 0) {
      return 'Surge Allowance must be a positive number';
    }
  }

  static String? depthofcoverValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Depth of cover is required';
    }
    if (double.tryParse(value) == null) {
      return 'Depth of cover must be a number';
    }
    if (double.tryParse(value)! < 0) {
      return 'Depth of cover must be a positive number';
    }
  }

  static String? densityValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'density is required';
    }
    if (double.tryParse(value) == null) {
      return 'density must be a number';
    }
    if (double.tryParse(value)! < 0) {
      return 'Density must be a positive number';
    }
  }

  static String? impactfactorValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Impact Factor is required';
    }
    if (double.tryParse(value) == null) {
      return 'Impact Factor must be a number';
    }
    if (double.tryParse(value)! < 0) {
      return 'Impact Factor must be a positive number';
    }
  }

  static String? bvalueValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'B value is required';
    }
    if (double.tryParse(value) == null) {
      return 'B value must be a number';
    }
    if (double.tryParse(value)! < 0) {
      return 'B value must be a positive number';
    }
  }

  static String? wheelloadValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Wheel load value is required';
    }
    if (double.tryParse(value) == null) {
      return 'Wheel load must be a number';
    }
    if (double.tryParse(value)! < 0) {
      return 'Wheel load must be a positive number';
    }
  }

  static String? pipelengthValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pipe length is required';
    }
    if (double.tryParse(value) == null) {
      return 'Pipe length must be a number';
    }
    if (double.tryParse(value)! < 0) {
      return 'Pipe length must be a positive number';
    }
  }

  static String? yieldstrengthValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'yield strength value is required';
    }
    if (double.tryParse(value) == null) {
      return 'Yield strength must be a number';
    }
    if (double.tryParse(value)! < 0) {
      return 'Yield strength must be a positive number';
    }
  }

  static String? modulusValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Modulus of elasticity is required';
    }
    if (double.tryParse(value) == null) {
      return 'Modulus of elasticity must be a number';
    }
    if (double.tryParse(value)! < 0) {
      return 'Modulus of elasticity must be a positive number';
    }
  }

  static String? confirmPasswordValidator(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? phoneNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 10) {
      return 'Invalid phone number';
    }
    return null;
  }

  static String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (!GetUtils.isAlphabetOnly(value)) {
      return 'Name must contain only letters';
    }
    return null;
  }

  static String? usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    return null;
  }
}

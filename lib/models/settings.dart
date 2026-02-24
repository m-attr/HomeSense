class Settings {
  Settings._privateConstructor();
  static final Settings instance = Settings._privateConstructor();

  // unit
  String energyUnit = 'kWh (Kilowatt-hour)';
  String waterUnit = 'Litres (L)';
  String temperatureUnit = '°C (Celsius)';

  // default thresholds
  double electricityThreshold = 10.0; // kWh
  double waterThreshold = 150.0; // L
  double temperatureThreshold = 22.0; // °C (example default)

  void setEnergyUnit(String unit) {
    final old = energyUnit;
    if (old != unit) {
      electricityThreshold = _convertEnergy(electricityThreshold, from: old, to: unit);
      energyUnit = unit;
    }
  }

  void setWaterUnit(String unit) {
    final old = waterUnit;
    if (old != unit) {
      waterThreshold = _convertWater(waterThreshold, from: old, to: unit);
      waterUnit = unit;
    }
  }

  void setTemperatureUnit(String unit) {
    final old = temperatureUnit;
    if (old != unit) {
      temperatureThreshold = _convertTemperature(temperatureThreshold, from: old, to: unit);
      temperatureUnit = unit;
    }
  }

  // Conversion helpers - results rounded to 1 decimal place
  double _round1(double v) => (v * 10).roundToDouble() / 10.0;

  double _convertEnergy(double value, {required String from, required String to}) {
    final f = from.split(' ').first;
    final t = to.split(' ').first;
    double out = value;
    if (f == 'kWh' && t == 'Wh') out = value * 1000.0;
    else if (f == 'Wh' && t == 'kWh') out = value / 1000.0;
    return _round1(out);
  }

  double _convertWater(double value, {required String from, required String to}) {
    double out = value;
    // Litres <-> m³ (1 m³ = 1000 L)
    if (from.contains('Litres') && to.contains('m³')) {
      // Litres -> m³
      out = value / 1000.0;
    } else if (from.contains('m³') && to.contains('Litres')) {
      out = value * 1000.0;
    }
    return _round1(out);
  }

  double _convertTemperature(double value, {required String from, required String to}) {
    double out = value;
    if (from.contains('°C') && to.contains('°F')) {
      out = value * 9.0 / 5.0 + 32.0;
    } else if (from.contains('°F') && to.contains('°C')) {
      out = (value - 32.0) * 5.0 / 9.0;
    }
    return _round1(out);
  }

// set threshold 
  void setElectricityThresholdFromLabel(String label, {double? customValue}) {
    if (label == 'Custom' && customValue != null) {
      electricityThreshold = customValue;
      return;
    }
    final v = _extractLeadingNumber(label);
    if (v != null) electricityThreshold = v;
  }

  void setWaterThresholdFromLabel(String label, {double? customValue}) {
    if (label == 'Custom' && customValue != null) {
      waterThreshold = customValue;
      return;
    }
    final v = _extractLeadingNumber(label);
    if (v != null) waterThreshold = v;
  }

  void setTemperatureThreshold(double value) => temperatureThreshold = value;

  // parse input
  double? _extractLeadingNumber(String s) {
    final reg = RegExp(r'[0-9]+(?:\.[0-9]+)?');
    final m = reg.firstMatch(s);
    if (m == null) return null;
    return double.tryParse(m.group(0)!);
  }
}

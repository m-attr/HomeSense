class Settings {
  Settings._privateConstructor();
  static final Settings instance = Settings._privateConstructor();

  // Units
  String energyUnit = 'kWh (Kilowatt-hour)';
  String waterUnit = 'Litres (L)';
  String temperatureUnit = '°C (Celsius)';

  // Numeric thresholds (comfort targets). These are the values used to
  // assess whether readings are within comfort ranges. Defaults match the
  // dropdown defaults in the Settings UI.
  double electricityThreshold = 10.0; // kWh
  double waterThreshold = 150.0; // L
  double temperatureThreshold = 22.0; // °C (example default)

  // Helpers to update settings from the selection strings used in the UI.
  void setEnergyUnit(String unit) => energyUnit = unit;
  void setWaterUnit(String unit) => waterUnit = unit;
  void setTemperatureUnit(String unit) => temperatureUnit = unit;

  // Set threshold by parsing a selection string that contains a leading
  // numeric value, e.g. "10 kWh (Average)" or a plain numeric string.
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

  double? _extractLeadingNumber(String s) {
    final reg = RegExp(r'[0-9]+(?:\.[0-9]+)?');
    final m = reg.firstMatch(s);
    if (m == null) return null;
    return double.tryParse(m.group(0)!);
  }
}

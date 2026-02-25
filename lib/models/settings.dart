class Settings {
  Settings._privateConstructor();
  static final Settings instance = Settings._privateConstructor();

  // unit
  String energyUnit = 'kWh (Kilowatt-hour)';
  String waterUnit = 'Litres (L)';
  String temperatureUnit = '°C (Celsius)';

  // Monthly targets (base units: kWh, Litres)
  double electricityMonthlyTarget = 300.0; // kWh per month
  double waterMonthlyTarget = 4500.0; // Litres per month
  double temperatureThreshold = 22.0; // °C (comfort ideal)

  // Computed daily targets (monthly / days in current month)
  double get electricityThreshold {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return _round1(electricityMonthlyTarget / daysInMonth);
  }

  double get waterThreshold {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return _round1(waterMonthlyTarget / daysInMonth);
  }

  int get daysInCurrentMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0).day;
  }

  void setEnergyUnit(String unit) {
    final old = energyUnit;
    if (old != unit) {
      electricityMonthlyTarget = _convertEnergy(
        electricityMonthlyTarget,
        from: old,
        to: unit,
      );
      energyUnit = unit;
    }
  }

  void setWaterUnit(String unit) {
    final old = waterUnit;
    if (old != unit) {
      waterMonthlyTarget = _convertWater(
        waterMonthlyTarget,
        from: old,
        to: unit,
      );
      waterUnit = unit;
    }
  }

  void setTemperatureUnit(String unit) {
    final old = temperatureUnit;
    if (old != unit) {
      temperatureThreshold = _convertTemperature(
        temperatureThreshold,
        from: old,
        to: unit,
      );
      temperatureUnit = unit;
    }
  }

  // Conversion helpers - results rounded to 1 decimal place
  double _round1(double v) => (v * 10).roundToDouble() / 10.0;

  double _convertEnergy(
    double value, {
    required String from,
    required String to,
  }) {
    final f = from.split(' ').first;
    final t = to.split(' ').first;
    double out = value;
    if (f == 'kWh' && t == 'Wh')
      out = value * 1000.0;
    else if (f == 'Wh' && t == 'kWh')
      out = value / 1000.0;
    return _round1(out);
  }

  double _convertWater(
    double value, {
    required String from,
    required String to,
  }) {
    double out = value;
    // Litres <-> mL (1 L = 1000 mL)
    if (from.contains('Litres') && to.contains('mL')) {
      out = value * 1000.0;
    } else if (from.contains('mL') && to.contains('Litres')) {
      out = value / 1000.0;
    }
    return _round1(out);
  }

  double _convertTemperature(
    double value, {
    required String from,
    required String to,
  }) {
    double out = value;
    if (from.contains('°C') && to.contains('°F')) {
      out = value * 9.0 / 5.0 + 32.0;
    } else if (from.contains('°F') && to.contains('°C')) {
      out = (value - 32.0) * 5.0 / 9.0;
    }
    return _round1(out);
  }

  // set monthly targets
  void setElectricityMonthlyTarget(String label, {double? customValue}) {
    if (label == 'Custom' && customValue != null) {
      electricityMonthlyTarget = customValue;
      return;
    }
    final v = _extractLeadingNumber(label);
    if (v != null) electricityMonthlyTarget = v;
  }

  void setWaterMonthlyTarget(String label, {double? customValue}) {
    if (label == 'Custom' && customValue != null) {
      waterMonthlyTarget = customValue;
      return;
    }
    final v = _extractLeadingNumber(label);
    if (v != null) waterMonthlyTarget = v;
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

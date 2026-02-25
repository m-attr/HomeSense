import 'package:flutter/material.dart';
import '../models/settings.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  UNIFIED QUALITY THRESHOLD HELPERS
//
//  Every screen (dashboard, quality cards, quality detail sections) MUST use
//  these functions so that a given reading always appears in the same colour
//  and with the same status label/icon/description everywhere.
//
//  Ranges are always expressed as a *fraction of the user's threshold*:
//
//    Electricity & Water (lower is better — consumption):
//      fraction < 0.60  → green  (Excellent / Low Usage)
//      fraction < 0.80  → amber  (Moderate)
//      fraction < 1.00  → orange (High / Near Limit)
//      fraction >= 1.00 → red    (Critical / Exceeded)
//
//    Temperature (comfort band — distance from ideal):
//      within ±2 °C of threshold → green  (Comfortable)
//      within ±5 °C              → amber  (Slightly Off)
//      within ±8 °C              → orange (Uncomfortable)
//      beyond ±8 °C              → red    (Critical)
// ═══════════════════════════════════════════════════════════════════════════

// ── Colour palette ──────────────────────────────────────────────────────

const Color kStatusGreen = Color(0xFF1EAA83);
const Color kStatusAmber = Color(0xFFFFC107);
const Color kStatusOrange = Color(0xFFFF9800);
const Color kStatusRed = Color(0xFFF44336);
const Color kStatusBlue = Color(0xFF2196F3);
const Color kStatusCyan = Color(0xFF00BCD4);

// ── Quality theme colours (per-quality accent) ──────────────────────────

const Color kElectricityColor = Color(0xFFF5A623);
const Color kWaterColor = Color(0xFF42A5F5);
const Color kTemperatureColor = Color(0xFFEF6C57);

// ─────────────────────────────────────────────────────────────────────────
//  ELECTRICITY  —  value in kWh, threshold from Settings
// ─────────────────────────────────────────────────────────────────────────

double electricityFraction(double value) {
  final t = Settings.instance.electricityThreshold;
  if (t <= 0) return 0;
  return value / t;
}

Color electricityStatusColor(double value) {
  final f = electricityFraction(value);
  if (f < 0.60) return kStatusGreen;
  if (f < 0.80) return kStatusAmber;
  if (f < 1.00) return kStatusOrange;
  return kStatusRed;
}

String electricityStatusLabel(double value) {
  final f = electricityFraction(value);
  if (f < 0.60) return 'Low Usage';
  if (f < 0.80) return 'Moderate';
  if (f < 1.00) return 'Near Limit';
  return 'Exceeded';
}

IconData electricityStatusIcon(double value) {
  final f = electricityFraction(value);
  if (f < 0.60) return Icons.check_circle_outline;
  if (f < 0.80) return Icons.trending_up_rounded;
  if (f < 1.00) return Icons.warning_amber_rounded;
  return Icons.dangerous_outlined;
}

String electricityStatusDescription(double value) {
  final f = electricityFraction(value);
  if (f < 0.60) return 'Energy consumption is well within your target.';
  if (f < 0.80) return 'Energy consumption is moderate — keep monitoring.';
  if (f < 1.00) return 'Approaching your daily electricity limit.';
  return 'You\'ve exceeded your daily electricity target.';
}

// ─────────────────────────────────────────────────────────────────────────
//  WATER  —  value in litres, threshold from Settings
// ─────────────────────────────────────────────────────────────────────────

double waterFraction(double value) {
  final t = Settings.instance.waterThreshold;
  if (t <= 0) return 0;
  return value / t;
}

Color waterStatusColor(double value) {
  final f = waterFraction(value);
  if (f < 0.60) return kStatusGreen;
  if (f < 0.80) return kStatusAmber;
  if (f < 1.00) return kStatusOrange;
  return kStatusRed;
}

String waterStatusLabel(double value) {
  final f = waterFraction(value);
  if (f < 0.60) return 'Low Usage';
  if (f < 0.80) return 'Moderate';
  if (f < 1.00) return 'Near Limit';
  return 'Goal Exceeded';
}

IconData waterStatusIcon(double value) {
  final f = waterFraction(value);
  if (f < 0.60) return Icons.check_circle_outline;
  if (f < 0.80) return Icons.trending_up_rounded;
  if (f < 1.00) return Icons.warning_amber_rounded;
  return Icons.dangerous_outlined;
}

String waterStatusDescription(double value) {
  final f = waterFraction(value);
  if (f < 0.60) return 'Water consumption is well within your target.';
  if (f < 0.80) return 'Water consumption is moderate — keep monitoring.';
  if (f < 1.00) return 'Approaching your daily water goal.';
  return 'You\'ve exceeded your daily water goal.';
}

// ─────────────────────────────────────────────────────────────────────────
//  TEMPERATURE  —  value in °C, ideal = Settings threshold
//  Distance from ideal determines status.
// ─────────────────────────────────────────────────────────────────────────

double temperatureDeviation(double value) {
  return (value - Settings.instance.temperatureThreshold).abs();
}

Color temperatureStatusColor(double value) {
  final d = temperatureDeviation(value);
  if (d <= 2) return kStatusGreen;
  if (d <= 5) return kStatusAmber;
  if (d <= 8) return kStatusOrange;
  return kStatusRed;
}

String temperatureStatusLabel(double value) {
  final d = temperatureDeviation(value);
  if (d <= 2) return 'Comfortable';
  if (d <= 5) return 'Slightly Off';
  if (d <= 8) return 'Uncomfortable';
  return 'Critical';
}

IconData temperatureStatusIcon(double value) {
  final ideal = Settings.instance.temperatureThreshold;
  final d = (value - ideal).abs();
  if (d <= 2) return Icons.check_circle_outline;
  if (d <= 5) return value < ideal ? Icons.air : Icons.wb_sunny_outlined;
  if (d <= 8) {
    return value < ideal ? Icons.ac_unit : Icons.local_fire_department;
  }
  return Icons.dangerous_outlined;
}

String temperatureStatusDescription(double value) {
  final d = temperatureDeviation(value);
  if (d <= 2) return 'Temperature is within the ideal comfort range.';
  if (d <= 5) return 'Temperature is slightly outside preferred range.';
  if (d <= 8) return 'Temperature is getting uncomfortable.';
  return 'Temperature is critically outside the comfort zone.';
}

// ─────────────────────────────────────────────────────────────────────────
//  GENERIC helper: given quality name + raw value → colour
//  Used by dashboard _colorForValue, QualityCard, etc.
// ─────────────────────────────────────────────────────────────────────────

/// Returns the status colour for a quality reading.
/// [quality] is one of 'electricity', 'water', 'temperature' (case-insensitive).
/// [value] is the raw reading in base units (kWh / L / °C).
/// Returns `null` if the reading is in the green (no override needed by cards).
Color? qualityColor(String quality, double value) {
  final q = quality.toLowerCase();
  Color c;
  if (q.contains('electric')) {
    c = electricityStatusColor(value);
  } else if (q.contains('water')) {
    c = waterStatusColor(value);
  } else {
    c = temperatureStatusColor(value);
  }
  return c == kStatusGreen ? null : c;
}

/// Returns the status colour (never null — green for healthy).
Color qualityStatusColor(String quality, double value) {
  final q = quality.toLowerCase();
  if (q.contains('electric')) return electricityStatusColor(value);
  if (q.contains('water')) return waterStatusColor(value);
  return temperatureStatusColor(value);
}

String qualityStatusLabel(String quality, double value) {
  final q = quality.toLowerCase();
  if (q.contains('electric')) return electricityStatusLabel(value);
  if (q.contains('water')) return waterStatusLabel(value);
  return temperatureStatusLabel(value);
}

IconData qualityStatusIconFor(String quality, double value) {
  final q = quality.toLowerCase();
  if (q.contains('electric')) return electricityStatusIcon(value);
  if (q.contains('water')) return waterStatusIcon(value);
  return temperatureStatusIcon(value);
}

String qualityStatusDescription(String quality, double value) {
  final q = quality.toLowerCase();
  if (q.contains('electric')) return electricityStatusDescription(value);
  if (q.contains('water')) return waterStatusDescription(value);
  return temperatureStatusDescription(value);
}

// ─────────────────────────────────────────────────────────────────────────
//  UNIT CONVERSION — convert raw base-unit values to current display unit
//  Base units:  electricity → kWh,  water → L,  temperature → °C
// ─────────────────────────────────────────────────────────────────────────

double convertElectricity(double kWh) {
  final unit = Settings.instance.energyUnit;
  if (unit.contains('Wh') && !unit.contains('kWh')) return kWh * 1000;
  return kWh;
}

double convertWater(double litres) {
  final unit = Settings.instance.waterUnit;
  if (unit.contains('m³')) return litres / 1000;
  return litres;
}

double convertTemperature(double celsius) {
  final unit = Settings.instance.temperatureUnit;
  if (unit.contains('°F')) return celsius * 9 / 5 + 32;
  return celsius;
}

/// Short unit label for display (e.g. 'kWh', 'L', '°C')
String electricityUnitLabel() => Settings.instance.energyUnit.split(' ').first;
String waterUnitLabel() => Settings.instance.waterUnit.split(' ').first;
String temperatureUnitLabel() =>
    Settings.instance.temperatureUnit.split(' ').first;

/// Format an electricity value for display
String formatElectricity(double kWh) {
  final v = convertElectricity(kWh);
  return v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

/// Format a water value for display
String formatWater(double litres) {
  final v = convertWater(litres);
  final unit = Settings.instance.waterUnit;
  if (unit.contains('m³')) return v.toStringAsFixed(3);
  if (v >= 100) return v.toStringAsFixed(0);
  return v.toStringAsFixed(1);
}

/// Format a temperature value for display
String formatTemperature(double celsius) {
  final v = convertTemperature(celsius);
  return v.toStringAsFixed(1);
}

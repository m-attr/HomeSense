/// Preset room data model.
/// Each room has a name, which qualities it monitors, and realistic
/// current-day readings plus historical data for charts.
class RoomData {
  final String name;
  final Set<String> qualities;

  // Current readings (today's totals / current reading)
  final double electricity; // kWh — today's consumption so far
  final double water; // Litres — today's consumption so far
  final double temperature; // °C — current reading

  // --- Daily chart data (24 hourly values) ---
  final List<double> elecHourly;
  final List<double> waterHourly;
  final List<double> tempHourly;

  // --- Period chart data ---
  // Week: 7 daily values (Mon–Sun)
  final List<double> elecWeek;
  final List<double> waterWeek;
  final List<double> tempWeek;

  // Month: 4 weekly averages
  final List<double> elecMonth;
  final List<double> waterMonth;
  final List<double> tempMonth;

  // Year: 12 monthly values
  final List<double> elecYear;
  final List<double> waterYear;
  final List<double> tempYear;

  const RoomData({
    required this.name,
    required this.qualities,
    this.electricity = 0,
    this.water = 0,
    this.temperature = 22,
    this.elecHourly = const [],
    this.waterHourly = const [],
    this.tempHourly = const [],
    this.elecWeek = const [],
    this.waterWeek = const [],
    this.tempWeek = const [],
    this.elecMonth = const [],
    this.waterMonth = const [],
    this.tempMonth = const [],
    this.elecYear = const [],
    this.waterYear = const [],
    this.tempYear = const [],
  });
}

// ════════════════════════════════════════════════════════════════════════════
//  PRESET ROOMS with realistic data
// ════════════════════════════════════════════════════════════════════════════

final List<RoomData> presetRooms = [
  // ── Living Room ──────────────────────────────────────────────────────
  // Monitors: Electricity + Temperature
  // Typical living room: TV, lights, AC/heater, charging devices
  // Today's electricity so far: 3.8 kWh (moderate usage by afternoon)
  // Temperature: 23.5 °C (slightly warm)
  RoomData(
    name: 'Living Room',
    qualities: {'Electricity', 'Temperature'},
    electricity: 3.8,
    water: 0,
    temperature: 23.5,
    // Hourly electricity (kWh per hour, sums to ~3.8 by current hour ~2pm)
    elecHourly: [
      0.05, 0.04, 0.03, 0.03, 0.04, 0.08, // 12a–5a (standby)
      0.15, 0.25, 0.20, 0.18, 0.22, 0.30, // 6a–11a (morning activity)
      0.35, 0.40, 0.45, 0.50, 0.55, 0.60, // 12p–5p (afternoon, TV on)
      0.48, 0.42, 0.35, 0.25, 0.15, 0.08, // 6p–11p (evening wind down)
    ],
    // Hourly temperature (°C)
    tempHourly: [
      21.0,
      20.8,
      20.5,
      20.3,
      20.2,
      20.5,
      21.0,
      21.8,
      22.5,
      23.0,
      23.5,
      24.0,
      24.2,
      24.5,
      24.3,
      24.0,
      23.5,
      23.0,
      22.5,
      22.2,
      22.0,
      21.5,
      21.2,
      21.0,
    ],
    // Week (kWh per day, today ~3.8)
    elecWeek: [4.2, 3.5, 4.8, 3.9, 4.1, 5.2, 3.8],
    tempWeek: [23.0, 23.5, 22.8, 24.0, 23.2, 22.5, 23.5],
    // Month (weekly totals)
    elecMonth: [27.5, 29.0, 26.8, 28.5],
    tempMonth: [23.0, 23.5, 22.8, 23.2],
    // Year (monthly kWh)
    elecYear: [95, 88, 82, 78, 85, 110, 125, 120, 105, 90, 85, 92],
    tempYear: [
      20.0,
      20.5,
      22.0,
      24.0,
      26.5,
      28.0,
      29.5,
      29.0,
      27.0,
      24.5,
      22.0,
      20.5,
    ],
  ),

  // ── Kitchen ──────────────────────────────────────────────────────────
  // Monitors: Electricity + Water + Temperature
  // Typical kitchen: fridge, oven, dishwasher, kettle, tap water, cooking
  // Today's electricity: 5.2 kWh (heaviest room — cooking appliances)
  // Today's water: 85 L (dishwashing, cooking, drinking)
  // Temperature: 25.0 °C (warm from cooking)
  RoomData(
    name: 'Kitchen',
    qualities: {'Electricity', 'Water', 'Temperature'},
    electricity: 5.2,
    water: 85,
    temperature: 25.0,
    // Hourly electricity
    elecHourly: [
      0.12, 0.12, 0.12, 0.12, 0.12, 0.15, // 12a–5a (fridge baseline)
      0.30, 0.55, 0.40, 0.25, 0.20, 0.35, // 6a–11a (breakfast, kettle)
      0.60, 0.45, 0.30, 0.25, 0.35, 0.65, // 12p–5p (lunch, oven)
      0.50, 0.35, 0.20, 0.15, 0.12, 0.12, // 6p–11p (dinner, cleanup)
    ],
    // Hourly water (litres per hour)
    waterHourly: [
      0,
      0,
      0,
      0,
      0,
      1,
      5,
      8,
      4,
      2,
      3,
      6,
      10,
      8,
      3,
      2,
      4,
      12,
      10,
      5,
      2,
      1,
      0,
      0,
    ],
    // Hourly temperature
    tempHourly: [
      22.0,
      21.8,
      21.5,
      21.5,
      21.5,
      22.0,
      23.0,
      24.5,
      25.0,
      24.0,
      23.5,
      24.0,
      26.0,
      27.0,
      26.0,
      25.0,
      25.5,
      27.5,
      26.5,
      25.0,
      24.0,
      23.0,
      22.5,
      22.0,
    ],
    // Week
    elecWeek: [5.8, 4.9, 6.2, 5.5, 5.0, 7.1, 5.2],
    waterWeek: [90, 75, 95, 88, 82, 110, 85],
    tempWeek: [24.5, 25.0, 24.0, 25.5, 24.8, 23.5, 25.0],
    // Month
    elecMonth: [38.0, 41.5, 36.8, 39.2],
    waterMonth: [580, 620, 560, 600],
    tempMonth: [24.5, 25.0, 24.2, 24.8],
    // Year
    elecYear: [155, 145, 140, 135, 142, 160, 175, 170, 158, 148, 142, 150],
    waterYear: [
      2400,
      2300,
      2200,
      2350,
      2500,
      2700,
      2800,
      2750,
      2600,
      2450,
      2350,
      2400,
    ],
    tempYear: [
      21.0,
      21.5,
      23.0,
      25.0,
      27.0,
      28.5,
      30.0,
      29.5,
      27.5,
      25.0,
      23.0,
      21.5,
    ],
  ),

  // ── Bedroom ──────────────────────────────────────────────────────────
  // Monitors: Electricity + Temperature
  // Typical bedroom: lights, chargers, AC/fan, alarm clock
  // Today's electricity: 1.9 kWh (lightest room)
  // Temperature: 22.0 °C (comfortable, AC regulated)
  RoomData(
    name: 'Bedroom',
    qualities: {'Electricity', 'Temperature'},
    electricity: 1.9,
    water: 0,
    temperature: 22.0,
    // Hourly electricity
    elecHourly: [
      0.10, 0.10, 0.08, 0.08, 0.08, 0.05, // 12a–5a (fan/AC overnight)
      0.03, 0.02, 0.02, 0.02, 0.02, 0.02, // 6a–11a (mostly empty)
      0.02, 0.02, 0.02, 0.02, 0.03, 0.05, // 12p–5p (light usage)
      0.08, 0.12, 0.15, 0.20, 0.18, 0.12, // 6p–11p (evening, charging)
    ],
    // Hourly temperature
    tempHourly: [
      21.5,
      21.2,
      21.0,
      20.8,
      20.5,
      20.8,
      21.0,
      21.5,
      22.0,
      22.5,
      23.0,
      23.2,
      23.5,
      23.5,
      23.2,
      23.0,
      22.8,
      22.5,
      22.2,
      22.0,
      21.8,
      21.5,
      21.5,
      21.5,
    ],
    // Week
    elecWeek: [2.1, 1.8, 2.3, 1.7, 2.0, 2.5, 1.9],
    tempWeek: [22.0, 22.5, 21.5, 22.0, 21.8, 22.2, 22.0],
    // Month
    elecMonth: [14.0, 15.2, 13.5, 14.8],
    tempMonth: [22.0, 22.5, 21.8, 22.2],
    // Year
    elecYear: [55, 52, 48, 45, 50, 65, 72, 70, 62, 55, 50, 54],
    tempYear: [
      20.0,
      20.5,
      21.5,
      23.0,
      25.0,
      26.5,
      27.5,
      27.0,
      25.5,
      23.5,
      21.5,
      20.5,
    ],
  ),
];

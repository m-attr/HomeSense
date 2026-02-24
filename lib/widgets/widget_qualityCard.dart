import 'package:flutter/material.dart';

class QualityCard extends StatelessWidget {
  final String qualityName;
  final IconData qualityIcon;
  final String qualityUnit;
  final String qualityValue;
  final Color? valueColor;
  final VoidCallback? onViewDetails;
  final double? threshold;
  final Color? cardColor;

  const QualityCard({
    super.key,
    required this.qualityName,
    required this.qualityIcon,
    required this.qualityUnit,
    required this.qualityValue,
    this.valueColor,
    this.onViewDetails,
    this.threshold,
    this.cardColor,
  });

  // ── helpers ──────────────────────────────────────────

  static const Color _green = Color(0xFF1EAA83);
  static const Color _dark = Color(0xFF2D3142);

  String _statusLabel(Color c) {
    if (c == Colors.red) return 'High';
    if (c == Colors.amber) return 'Moderate';
    return 'Normal';
  }

  IconData _statusIcon(Color c) {
    if (c == Colors.red) return Icons.warning_amber_rounded;
    if (c == Colors.amber) return Icons.trending_up_rounded;
    return Icons.check_circle_outline;
  }

  Color _effectiveColor() => valueColor ?? _green;

  double _progressFraction() {
    if (threshold == null || threshold! <= 0) return 0.45;
    final v = double.tryParse(qualityValue) ?? 0;
    return (v / threshold!).clamp(0.0, 1.0);
  }

  // ── build ────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final Color accent = _effectiveColor();
    final Color iconColor = cardColor ?? accent;
    final String status = _statusLabel(accent);
    final IconData sIcon = _statusIcon(accent);
    final double frac = _progressFraction();
    final bool noData = qualityValue == '-';

    return GestureDetector(
      onTap: onViewDetails,
      child: Container(
        width: 172,
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon + name row
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(qualityIcon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      qualityName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _dark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Big value
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    qualityValue,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: noData ? Colors.grey.shade400 : accent,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      qualityUnit,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Progress bar
              if (!noData) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 5,
                    child: LinearProgressIndicator(
                      value: frac,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(accent),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              if (noData) const SizedBox(height: 15),

              // Status chip
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (noData ? Colors.grey : accent).withOpacity(0.09),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          noData ? Icons.remove_circle_outline : sIcon,
                          size: 13,
                          color: noData ? Colors.grey : accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          noData ? 'No data' : status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: noData ? Colors.grey : accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // View Details button
              SizedBox(
                width: double.infinity,
                height: 32,
                child: ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

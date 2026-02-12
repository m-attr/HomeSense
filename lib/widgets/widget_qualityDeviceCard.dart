import 'package:flutter/material.dart';

class QualityDeviceCard extends StatelessWidget {
  final IconData leftIcon;
  final IconData rightIcon;
  final String deviceName;
  final String deviceCountText;
  final String valueText;
  final String unitText;
  final VoidCallback? onTap;

  const QualityDeviceCard({
    super.key,
    required this.leftIcon,
    this.rightIcon = Icons.device_hub,
    required this.deviceName,
    required this.deviceCountText,
    required this.valueText,
    required this.unitText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFF1EAA83);
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Row 1: two icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(leftIcon, size: 28, color: accent),
                    Icon(rightIcon, size: 20, color: Colors.grey.shade600),
                  ],
                ),
                const SizedBox(height: 8),

                // Row 2: device name and count
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        deviceName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      deviceCountText,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 3: big value and unit
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        valueText,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accent),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      unitText,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

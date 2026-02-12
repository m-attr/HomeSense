import 'package:flutter/material.dart';

class QualityCard extends StatelessWidget {
  final String qualityName;
  final IconData qualityIcon;
  final String qualityUnit;
  final String qualityValue; // big display value
  final VoidCallback? onViewDetails;

  const QualityCard({
    super.key,
    required this.qualityName,
    required this.qualityIcon,
    required this.qualityUnit,
    required this.qualityValue,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 110,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Icon + name stacked
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          qualityIcon,
                          size: 34,
                          color: const Color(0xFF1EAA83),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 90,
                          child: Text(
                            qualityName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Value and unit on the right
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          qualityValue,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          qualityUnit,
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // View Details button bottom-right
              Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: onViewDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1EAA83),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('View Details', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
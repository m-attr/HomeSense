import 'package:flutter/material.dart';

class QualityCard extends StatelessWidget {
  final String qualityName;
  final IconData qualityIcon;
  final String qualityUnit;

  const QualityCard({
    super.key,
    required this.qualityName,
    required this.qualityIcon,
    required this.qualityUnit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              qualityName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Icon(
              qualityIcon,
              size: 40,
              color: Color(0xFF1EAA83),
            ),
            SizedBox(height: 8),
            Text(
              qualityUnit,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ),
    );
    
    
    
  }
}
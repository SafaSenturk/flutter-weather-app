import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../../../core/widgets/glass.dart';
import '../../../../core/widgets/weather_icon.dart';
import '../../../../data/models/forecast.dart';

/// Next 24 hours: a smooth temperature curve with icons and rain chances.
class HourlyCard extends StatelessWidget {
  const HourlyCard({super.key, required this.hours});

  final List<HourlyForecast> hours;

  static const _itemWidth = 62.0;
  static const _curveTop = 92.0;
  static const _curveHeight = 46.0;

  @override
  Widget build(BuildContext context) {
    final temps = hours.map((h) => h.temperature).toList();
    final minT = temps.reduce((a, b) => a < b ? a : b);
    final maxT = temps.reduce((a, b) => a > b ? a : b);
    double yFor(double t) =>
        _curveTop + _curveHeight * (1 - (maxT == minT ? .5 : (t - minT) / (maxT - minT)));

    return GlassCard(
      title: context.l.hourlyForecast,
      icon: Icons.schedule_rounded,
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 12),
      child: SizedBox(
        height: 172,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: 12),
          children: [
            SizedBox(
              width: hours.length * _itemWidth,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _CurvePainter(
                        points: [
                          for (var i = 0; i < hours.length; i++)
                            Offset(_itemWidth * i + _itemWidth / 2, yFor(hours[i].temperature)),
                        ],
                      ),
                    ),
                  ),
                  for (var i = 0; i < hours.length; i++)
                    Positioned(
                      left: i * _itemWidth,
                      width: _itemWidth,
                      top: 0,
                      bottom: 0,
                      child: _HourItem(
                        hour: hours[i],
                        isNow: i == 0,
                        tempTop: yFor(hours[i].temperature) - 30,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HourItem extends StatelessWidget {
  const _HourItem({required this.hour, required this.isNow, required this.tempTop});

  final HourlyForecast hour;
  final bool isNow;
  final double tempTop;

  @override
  Widget build(BuildContext context) {
    const label = TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14);
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: 0,
          child: Text(
            isNow ? context.l.now : context.hourOnly(hour.time),
            style: label.copyWith(fontWeight: isNow ? FontWeight.w800 : FontWeight.w600),
          ),
        ),
        Positioned(
          top: 24,
          child: WeatherIcon(condition: hour.condition, isDay: hour.isDay, size: 30),
        ),
        Positioned(
          top: 56,
          child: Text(
            hour.precipitationChance >= 10 ? '${hour.precipitationChance}%' : '',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ),
        Positioned(
          top: tempTop,
          child: Text(context.temp(hour.temperature), style: label.copyWith(fontSize: 15)),
        ),
      ],
    );
  }
}

class _CurvePainter extends CustomPainter {
  _CurvePainter({required this.points});

  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final mid = (p0.dx + p1.dx) / 2;
      path.cubicTo(mid, p0.dy, mid, p1.dy, p1.dx, p1.dy);
    }

    final fill = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: .22), Colors.white.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: .85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    for (final (i, p) in points.indexed) {
      canvas.drawCircle(p, i == 0 ? 5 : 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_CurvePainter old) => old.points != points;
}

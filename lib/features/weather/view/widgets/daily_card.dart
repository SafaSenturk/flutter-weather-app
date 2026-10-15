import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../../../core/widgets/glass.dart';
import '../../../../core/widgets/weather_icon.dart';
import '../../../../data/models/forecast.dart';

/// Ten days with a min–max bar placed on the period's overall range.
class DailyCard extends StatelessWidget {
  const DailyCard({super.key, required this.forecast});

  final Forecast forecast;

  @override
  Widget build(BuildContext context) {
    final (lo, hi) = forecast.temperatureBounds;
    return GlassCard(
      title: context.l.dailyForecast,
      icon: Icons.calendar_month_rounded,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Column(
        children: [
          for (final (i, day) in forecast.daily.indexed) ...[
            if (i > 0) Divider(height: 1, color: Colors.white.withValues(alpha: .14)),
            _DayRow(
              day: day,
              label: i == 0 ? context.l.today : context.weekday(day.date),
              lo: lo,
              hi: hi,
              current: i == 0 ? forecast.current.temperature : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.label,
    required this.lo,
    required this.hi,
    this.current,
  });

  final DailyForecast day;
  final String label;
  final double lo;
  final double hi;
  final double? current;

  @override
  Widget build(BuildContext context) {
    const text = TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600);
    return SizedBox(
      height: 54,
      child: Row(
        children: [
          SizedBox(width: 62, child: Text(label, style: text, overflow: TextOverflow.ellipsis)),
          SizedBox(
            width: 46,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WeatherIcon(condition: day.condition, size: 26),
                if (day.precipitationChance >= 20)
                  Text(
                    '${day.precipitationChance}%',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              context.temp(day.min),
              textAlign: TextAlign.right,
              style: text.copyWith(color: Colors.white.withValues(alpha: .6)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: _RangeBar(min: day.min, max: day.max, lo: lo, hi: hi, current: current)),
          const SizedBox(width: 10),
          SizedBox(width: 38, child: Text(context.temp(day.max), style: text)),
        ],
      ),
    );
  }
}

class _RangeBar extends StatelessWidget {
  const _RangeBar({required this.min, required this.max, required this.lo, required this.hi, this.current});

  final double min;
  final double max;
  final double lo;
  final double hi;
  final double? current;

  /// Cold blue → warm orange, so the bar shows how warm each day is.
  static Color _colorFor(double t) {
    const stops = [(-10.0, Color(0xFF6E8BFF)), (5.0, Color(0xFF5FD3F3)), (15.0, Color(0xFF9BE15D)), (25.0, Color(0xFFFFC83D)), (35.0, Color(0xFFFF6B3D))];
    if (t <= stops.first.$1) return stops.first.$2;
    for (var i = 0; i < stops.length - 1; i++) {
      final (a, ca) = stops[i];
      final (b, cb) = stops[i + 1];
      if (t <= b) return Color.lerp(ca, cb, (t - a) / (b - a))!;
    }
    return stops.last.$2;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final span = (hi - lo).abs() < .1 ? 1 : hi - lo;
        final start = (min - lo) / span * c.maxWidth;
        final end = (max - lo) / span * c.maxWidth;
        return SizedBox(
          height: 6,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Positioned(
                left: start,
                width: (end - start).clamp(6, c.maxWidth),
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(colors: [_colorFor(min), _colorFor(max)]),
                  ),
                ),
              ),
              if (current != null)
                Positioned(
                  left: ((current! - lo) / span * c.maxWidth).clamp(0, c.maxWidth) - 5,
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black.withValues(alpha: .25), width: 2),
                    ),
                  ),
                ),
            ],
          ),
        );
      });
}

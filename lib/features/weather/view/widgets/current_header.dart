import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../../../core/widgets/weather_icon.dart';
import '../../../../data/models/city.dart';
import '../../../../data/models/forecast.dart';

/// City name, big temperature, condition and today's range.
class CurrentHeader extends StatelessWidget {
  const CurrentHeader({super.key, required this.city, required this.forecast});

  final City city;
  final Forecast forecast;

  @override
  Widget build(BuildContext context) {
    final c = forecast.current;
    final shadow = [Shadow(color: Colors.black.withValues(alpha: .18), blurRadius: 12)];
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 30 * (1 - t)), child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 72, 24, 28),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (city.isCurrentLocation) ...[
                  const Icon(Icons.near_me_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    city.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      shadows: shadow,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              context.l.localTime(context.hourMinute(forecast.cityNow())),
              style: TextStyle(color: Colors.white.withValues(alpha: .75), fontWeight: FontWeight.w600),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Text(
                    context.temp(c.temperature),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 112,
                      fontWeight: FontWeight.w200,
                      height: 1.15,
                      letterSpacing: -4,
                      shadows: shadow,
                    ),
                  ),
                ),
                WeatherIcon(condition: c.condition, isDay: c.isDay, size: 64),
              ],
            ),
            Text(
              context.condition(c.condition),
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                shadows: shadow,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.l.highLow(context.temp(forecast.today.max), context.temp(forecast.today.min)),
              style: TextStyle(color: Colors.white.withValues(alpha: .9), fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              context.l.feelsLike(context.temp(c.feelsLike)),
              style: TextStyle(color: Colors.white.withValues(alpha: .75), fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

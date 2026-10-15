import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../../../core/widgets/glass.dart';
import '../../../../data/models/forecast.dart';

const _big = TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500, height: 1.1);
final _small = TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 13, fontWeight: FontWeight.w600);

/// Two-column grid of the "detail" tiles.
class DetailGrid extends StatelessWidget {
  const DetailGrid({super.key, required this.forecast});

  final Forecast forecast;

  @override
  Widget build(BuildContext context) {
    final c = forecast.current;
    final today = forecast.today;
    final aq = forecast.airQuality;
    final tiles = <Widget>[
      _WindTile(speed: c.windSpeed, direction: c.windDirection),
      _SunTile(day: today, now: forecast.cityNow()),
      _UvTile(uv: today.uvIndexMax),
      _HumidityTile(humidity: c.humidity),
      if (aq != null) _AirTile(aq: aq),
      _SimpleTile(
        title: context.l.precipitation,
        icon: Icons.water_drop_rounded,
        value: '${today.precipitationChance}%',
        caption: context.l.precipitationToday(c.precipitation.toStringAsFixed(1)),
      ),
      _SimpleTile(
        title: context.l.pressure,
        icon: Icons.speed_rounded,
        value: '${c.pressure.round()}',
        unit: 'hPa',
        caption: switch (c.pressure) {
          > 1020 => context.l.pressureHigh,
          < 1005 => context.l.pressureLow,
          _ => context.l.pressureNormal,
        },
      ),
      _SimpleTile(
        title: context.l.visibility,
        icon: Icons.visibility_rounded,
        value: (forecast.currentVisibility / 1000).toStringAsFixed(forecast.currentVisibility < 10000 ? 1 : 0),
        unit: 'km',
        caption: switch (forecast.currentVisibility) {
          >= 10000 => context.l.visibilityClear,
          >= 4000 => context.l.visibilityHazy,
          _ => context.l.visibilityPoor,
        },
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final w = (constraints.maxWidth - 12) / 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [for (final t in tiles) SizedBox(width: w, height: w * .95, child: t)],
      );
    });
  }
}

class _SimpleTile extends StatelessWidget {
  const _SimpleTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.caption,
    this.unit,
  });

  final String title;
  final IconData icon;
  final String value;
  final String? unit;
  final String caption;

  @override
  Widget build(BuildContext context) => GlassCard(
        title: title,
        icon: icon,
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(TextSpan(children: [
                TextSpan(text: value, style: _big),
                if (unit != null) TextSpan(text: ' $unit', style: _small),
              ])),
              const Spacer(),
              Text(caption, style: _small, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );
}

class _WindTile extends StatelessWidget {
  const _WindTile({required this.speed, required this.direction});

  final double speed;
  final int direction;

  @override
  Widget build(BuildContext context) => GlassCard(
        title: context.l.wind,
        icon: Icons.air_rounded,
        child: Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(child: Text(context.wind(speed), style: _big.copyWith(fontSize: 24))),
                    const Spacer(),
                    Text(context.l.windFrom(context.compass(direction)), style: _small),
                  ],
                ),
              ),
              AspectRatio(
                aspectRatio: 1,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: direction.toDouble()),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutBack,
                  builder: (_, deg, _) => CustomPaint(
                    painter: _CompassPainter(deg, context.l.compass.split(',').first),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _CompassPainter extends CustomPainter {
  _CompassPainter(this.degrees, this.north);

  final double degrees;
  final String north;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final ring = Paint()
      ..color = Colors.white.withValues(alpha: .35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(c, r - 2, ring);
    for (var i = 0; i < 36; i++) {
      final a = i * pi / 18;
      final len = i % 9 == 0 ? 7.0 : 3.5;
      final d = Offset(sin(a), -cos(a));
      canvas.drawLine(c + d * (r - 4), c + d * (r - 4 - len), ring);
    }
    final tp = TextPainter(
      text: TextSpan(text: north, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - r + 12));

    // The arrow points where the wind blows to (opposite of where it comes from).
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate((degrees + 180) * pi / 180);
    final arrow = Path()
      ..moveTo(0, -r * .62)
      ..lineTo(r * .16, -r * .3)
      ..lineTo(r * .05, -r * .32)
      ..lineTo(r * .05, r * .55)
      ..lineTo(-r * .05, r * .55)
      ..lineTo(-r * .05, -r * .32)
      ..lineTo(-r * .16, -r * .3)
      ..close();
    canvas.drawPath(arrow, Paint()..color = Colors.white);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CompassPainter old) => old.degrees != degrees;
}

class _SunTile extends StatelessWidget {
  const _SunTile({required this.day, required this.now});

  final DailyForecast day;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final total = day.sunset.difference(day.sunrise).inMinutes;
    final progress = total <= 0 ? 0.0 : (now.difference(day.sunrise).inMinutes / total).clamp(-0.1, 1.1);
    final beforeSunset = now.isBefore(day.sunset);
    return GlassCard(
      title: beforeSunset ? context.l.sunset : context.l.sunrise,
      icon: beforeSunset ? Icons.wb_twilight_rounded : Icons.wb_sunny_outlined,
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.hourMinute(beforeSunset ? day.sunset : day.sunrise), style: _big),
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress.toDouble()),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutCubic,
                builder: (_, p, _) => CustomPaint(size: Size.infinite, painter: _SunArcPainter(p)),
              ),
            ),
            Text(
              '${context.l.sunrise} ${context.hourMinute(day.sunrise)}',
              style: _small,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SunArcPainter extends CustomPainter {
  _SunArcPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final base = size.height * .85;
    final rect = Rect.fromLTRB(4, base - size.height * 1.3, size.width - 4, base + size.height * 1.3);
    final arc = Paint()
      ..color = Colors.white.withValues(alpha: .35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(rect, pi, pi, false, arc);
    canvas.drawLine(Offset(0, base), Offset(size.width, base), arc..strokeWidth = 1);
    final p = progress.clamp(0.0, 1.0);
    final a = pi + pi * p;
    final sun = Offset(rect.center.dx + cos(a) * rect.width / 2, rect.center.dy + sin(a) * rect.height / 2);
    if (progress > 0 && progress < 1) {
      canvas.drawCircle(sun, 12, Paint()..color = const Color(0xFFFFD25A).withValues(alpha: .3));
      canvas.drawCircle(sun, 6, Paint()..color = const Color(0xFFFFD25A));
    }
  }

  @override
  bool shouldRepaint(_SunArcPainter old) => old.progress != progress;
}

/// Coloured scale with a marker, used by UV, humidity and air quality.
class _ScaleBar extends StatelessWidget {
  const _ScaleBar({required this.value, required this.colors});

  /// 0..1 position of the marker.
  final double value;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) => SizedBox(
          height: 8,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(colors: colors),
                ),
                child: const SizedBox.expand(),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value.clamp(0, 1)),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => Positioned(
                  left: v * c.maxWidth - 6,
                  top: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .3), blurRadius: 4)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _UvTile extends StatelessWidget {
  const _UvTile({required this.uv});

  final double uv;

  @override
  Widget build(BuildContext context) => GlassCard(
        title: context.l.uvIndex,
        icon: Icons.wb_sunny_rounded,
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(uv.round().toString(), style: _big),
              Text(context.uvLabel(uv), style: _small.copyWith(fontSize: 16, color: Colors.white)),
              const Spacer(),
              _ScaleBar(
                value: uv / 11,
                colors: const [Color(0xFF6BD36B), Color(0xFFF5DD3B), Color(0xFFFF9C2A), Color(0xFFFF4B3E), Color(0xFFB45CFF)],
              ),
            ],
          ),
        ),
      );
}

class _HumidityTile extends StatelessWidget {
  const _HumidityTile({required this.humidity});

  final int humidity;

  @override
  Widget build(BuildContext context) => GlassCard(
        title: context.l.humidity,
        icon: Icons.opacity_rounded,
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$humidity%', style: _big),
              Text(
                switch (humidity) {
                  >= 70 => context.l.dewHumid,
                  <= 30 => context.l.dewDry,
                  _ => context.l.dewComfortable,
                },
                style: _small.copyWith(fontSize: 16, color: Colors.white),
              ),
              const Spacer(),
              _ScaleBar(
                value: humidity / 100,
                colors: const [Color(0xFFFFD08A), Color(0xFF8EE3C8), Color(0xFF4DA8FF)],
              ),
            ],
          ),
        ),
      );
}

class _AirTile extends StatelessWidget {
  const _AirTile({required this.aq});

  final AirQuality aq;

  @override
  Widget build(BuildContext context) => GlassCard(
        title: context.l.airQuality,
        icon: Icons.masks_rounded,
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${aq.europeanAqi}', style: _big),
              Text(context.aqiLabel(aq.level), style: _small.copyWith(fontSize: 16, color: Colors.white)),
              const Spacer(),
              Text('PM2.5 ${aq.pm25.toStringAsFixed(0)} · PM10 ${aq.pm10.toStringAsFixed(0)}', style: _small),
              const SizedBox(height: 8),
              _ScaleBar(
                value: aq.europeanAqi / 120,
                colors: const [Color(0xFF50F0E6), Color(0xFF50CCAA), Color(0xFFF0E641), Color(0xFFFF5050), Color(0xFF960032), Color(0xFF7D2181)],
              ),
            ],
          ),
        ),
      );
}

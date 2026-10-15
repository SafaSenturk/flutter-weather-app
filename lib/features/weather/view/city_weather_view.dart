import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/format.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/sky_background.dart';
import '../../../data/api/weather_api.dart';
import '../../../data/models/city.dart';
import '../../../data/models/weather_condition.dart';
import '../../../data/repositories/weather_repository.dart';
import '../bloc/weather_bloc.dart';
import 'widgets/current_header.dart';
import 'widgets/daily_card.dart';
import 'widgets/detail_cards.dart';
import 'widgets/hourly_card.dart';

/// One page of the home carousel: its own [WeatherBloc] and animated sky.
class CityWeatherView extends StatelessWidget {
  const CityWeatherView({super.key, required this.city});

  final City city;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => WeatherBloc(city: city, repository: context.read<WeatherRepository>())
          ..add(const WeatherStarted()),
        child: _CityWeatherBody(city: city),
      );
}

class _CityWeatherBody extends StatelessWidget {
  const _CityWeatherBody({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        final forecast = state.forecast;
        final sky = forecast?.current.condition.sky ?? Sky.cloudy;
        final isDay = forecast?.current.isDay ?? true;

        return Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                child: SkyBackground(key: ValueKey((sky, isDay)), sky: sky, isDay: isDay),
              ),
            ),
            switch (state.status) {
              WeatherStatus.initial || WeatherStatus.loading => _Loading(city: city),
              WeatherStatus.failure => _Failure(failure: state.failure!),
              WeatherStatus.success => RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                  onRefresh: () {
                    final bloc = context.read<WeatherBloc>()..add(const WeatherRefreshed());
                    return bloc.stream.firstWhere((s) => !s.isRefreshing);
                  },
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      SliverToBoxAdapter(child: CurrentHeader(city: city, forecast: forecast!)),
                      if (state.isStale)
                        SliverToBoxAdapter(
                          child: _OfflineBanner(fetchedAt: forecast.fetchedAt.add(forecast.utcOffset)),
                        ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                        sliver: SliverList.list(children: [
                          HourlyCard(hours: forecast.upcomingHours()),
                          const SizedBox(height: 12),
                          DailyCard(forecast: forecast),
                          const SizedBox(height: 12),
                          DetailGrid(forecast: forecast),
                          const SizedBox(height: 20),
                          Text(
                            '${context.l.updatedAt(context.hourMinute(forecast.fetchedAt.toLocal()))}\n${context.l.dataSource}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withValues(alpha: .6), fontSize: 12, height: 1.6),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
            },
          ],
        );
      },
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.fetchedAt});

  final DateTime fetchedAt;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          color: const Color(0xFFFFB84D).withValues(alpha: .9),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.read<WeatherBloc>().add(const WeatherRefreshed()),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.cloud_off_rounded, color: Color(0xFF3B2600), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.l.offlineBanner(context.hourMinute(fetchedAt)),
                      style: const TextStyle(color: Color(0xFF3B2600), fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Icon(Icons.refresh_rounded, color: Color(0xFF3B2600), size: 20),
                ],
              ),
            ),
          ),
        ),
      );
}

/// Placeholder shapes with a gentle pulse while the first forecast loads.
class _Loading extends StatefulWidget {
  const _Loading({required this.city});

  final City city;

  @override
  State<_Loading> createState() => _LoadingState();
}

class _LoadingState extends State<_Loading> with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget block(double w, double h, {double r = 14}) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .25), borderRadius: BorderRadius.circular(r)),
        );
    return FadeTransition(
      opacity: Tween(begin: .45, end: 1.0).animate(_pulse),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 72, 16, 0),
        children: [
          Center(
            child: Text(
              widget.city.name,
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 18),
          Center(child: block(150, 100, r: 24)),
          const SizedBox(height: 16),
          Center(child: block(120, 22)),
          const SizedBox(height: 10),
          Center(child: block(180, 16)),
          const SizedBox(height: 40),
          block(double.infinity, 170, r: 24),
          const SizedBox(height: 12),
          block(double.infinity, 300, r: 24),
        ],
      ),
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({required this.failure});

  final WeatherFailure failure;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  failure.kind == FailureKind.offline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 14),
                Text(
                  context.l.errorTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  context.failure(failure),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: .85), height: 1.4),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87),
                  onPressed: () => context.read<WeatherBloc>().add(const WeatherRefreshed()),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(context.l.retry),
                ),
              ],
            ),
          ),
        ),
      );
}
